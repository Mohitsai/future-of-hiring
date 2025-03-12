# -------------------------------------------------------------------
# main.tf
# This is the primary Terraform configuration file where you define
# providers and resources to build your Azure infrastructure.
# -------------------------------------------------------------------


# Configure the Azure provider and Terraform version requirements
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

# Initialize the AzureRM provider with default features
provider "azurerm" {
  features {}
}


# Resource Group
# Creates an Azure Resource Group to hold all resources
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}


# Client Configuration Data
# Retrieves info about the current Azure client (tenant, object ID)
# used for configuring access policies and other resources
data "azurerm_client_config" "current" {}

# Azure AD Application & Credentials
# Creates an Azure AD App Registration, a client secret, 
# and a corresponding Service Principal for programmatic access
resource "azuread_application_registration" "adzuna_project_app" {
  display_name = "adzuna-project-app"
}

# Generates a Client Secret for the Application
resource "azuread_application_password" "adzuna_project_app_secret" {
  application_id = azuread_application_registration.adzuna_project_app.id
  display_name   = "default-secret"
}

# Generates a Service Principal for the Application
resource "azuread_service_principal" "adzuna_project_app_sp" {
  client_id = azuread_application_registration.adzuna_project_app.client_id
}


# Storage Account (Data Lake Gen2)
# Creates a Storage Account with hierarchical namespace (HNS) enabled
# for Data Lake Gen2 features
resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  account_kind              = "StorageV2"
  enable_https_traffic_only = true
  is_hns_enabled            = true # Enables Data Lake Gen2
}


# Data Lake Gen2 Filesystem (Container)
# Creates a container (filesystem) in the Storage Account
resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  name               = var.container_name
  storage_account_id = azurerm_storage_account.this.id
}

# Data Lake Gen2 Folders
# Creates subdirectories in the filesystem
resource "azurerm_storage_data_lake_gen2_path" "folders" {
  for_each = toset(var.cont_folder_list)

  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.this.name
  storage_account_id = azurerm_storage_account.this.id
  path               = each.value
  resource           = "directory"
}


# Azure Data Factory
# Creates a Data Factory for orchestrating data workflows
resource "azurerm_data_factory" "this" {
  name                = var.data_factory_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "Terraform"
  }
}


# Azure Databricks Workspace
# Creates a Databricks workspace for big data processing and analytics
resource "azurerm_databricks_workspace" "this" {
  name                = var.databricks_workspace_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "standard" # or "premium" depending on your needs
}


# Azure Key Vault
# Creates a Key Vault to securely store secrets
resource "azurerm_key_vault" "this" {
  name                     = var.key_vault_name
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = false
}

# Key Vault Secrets
# Stores various secrets in Key Vault (e.g., client ID, secrets, tokens)
resource "azurerm_key_vault_secret" "databricks_cluster_token" {
  name         = var.databricks_cluster_token_secret_name
  value        = ""
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_key_vault_secret" "app-client-id" {
  name         = var.app_client_id_secret_name
  value        = azuread_application_registration.adzuna_project_app.client_id
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_key_vault_secret" "app-client-secret" {
  name         = var.app_client_secret_secret_name
  value        = azuread_application_password.adzuna_project_app_secret.value
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_key_vault_secret" "app-tenant-id" {
  name         = var.app_tenant_id_secret_name
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_key_vault_secret" "storage_account_access_key" {
  name         = var.storage_account_access_key_secret_name
  value        = azurerm_storage_account.this.primary_access_key
  key_vault_id = azurerm_key_vault.this.id
}

# Key Vault Access Policies
# Grants appropriate permissions to the current user and the Service Principal
resource "azurerm_key_vault_access_policy" "admin_policy" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}

resource "azurerm_key_vault_access_policy" "adzuna_project_app_policy" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_service_principal.adzuna_project_app_sp.object_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# Role Assignment: Storage Blob Data Contributor
# Grants the Service Principal permissions to manage blob data in the Storage Account
resource "azurerm_role_assignment" "adzuna_storage_blob_data_contributor" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.adzuna_project_app_sp.object_id
}


# Azure Function App Service Plan
# Creates a consumption-based App Service Plan for the Function App
resource "azurerm_service_plan" "azure_func_app_service_plan" {
  name                = "adzuna-func-app-consumption-plan"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "Y1" # use the Consumption pricing tier
}


# Azure Linux Function App
# Creates a Function App to run serverless Python functions
resource "azurerm_linux_function_app" "adzuna_extract_function_app" {
  name                = "adzuna-extract-function-app"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  service_plan_id            = azurerm_service_plan.azure_func_app_service_plan.id

  site_config {
    application_stack {
      python_version = 3.9 #FUNCTIONS_WORKER_RUNTIME        
    }
  }

}

# Data Source: Function App Host Keys
# Retrieves the host keys (e.g., default function key) from the Function App
data "azurerm_function_app_host_keys" "extract_function_keys" {
  name                = azurerm_linux_function_app.adzuna_extract_function_app.name
  resource_group_name = azurerm_linux_function_app.adzuna_extract_function_app.resource_group_name
}

# Key Vault Secret for Azure Function Key
# Stores the Function App's default function key in Key Vault
resource "azurerm_key_vault_secret" "azure_function_key" {
  name         = var.azure_function_key_secret_name
  value        = data.azurerm_function_app_host_keys.extract_function_keys.default_function_key
  key_vault_id = azurerm_key_vault.this.id
}