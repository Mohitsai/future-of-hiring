# terraform.tfvars
# This file sets values for the variables declared in the Terraform configuration.
# Rename this file from "terraform.tfvars.example" to "terraform.tfvars"
# and correct the values as per your project requirements
# so Terraform automatically loads these values.

# Azure Subscription ID where resources will be created
subscription_id = "34fbe5db-9342-447a-8e8e-b3cf319614f6"

# Azure region (location) for resource deployment
location = "centralus"

# Name of the Resource Group to create or use
resource_group_name = "rg_name"

# Name of the Storage Account
storage_account_name = "jobmarketstorage"

# Name of the Data Lake Gen2 container (filesystem)
container_name = "raw-data"

# List of folders to create inside the Data Lake container
cont_folder_list = [
  "json",
  "processed"
]

# Name of the Azure Data Factory instance
data_factory_name = "df-job-market"

# Name of the Azure Databricks workspace
databricks_workspace_name = "job-market-databricks-ws"

# Name of the Azure Key Vault
key_vault_name = "kv-job-market"

# Secret name in Key Vault to store/retrieve the Azure Function key
azure_function_key_secret_name = "adzuna-extract-azure-function-key"

# Secret name in Key Vault for the Databricks cluster access token
databricks_cluster_token_secret_name = "adzuna-project-dbcluster-acc-token"

# Secret name in Key Vault for the service principal client ID
app_client_id_secret_name = "adzuna-project-app-client-id"

# Secret name in Key Vault for the service principal client secret
app_client_secret_secret_name = "adzuna-project-app-client-secret"

# Secret name in Key Vault for the service principal tenant ID
app_tenant_id_secret_name = "adzuna-project-app-tenant-id"

# Secret name in Key Vault for the primary access key of the Storage Account
storage_account_access_key_secret_name = "adzuna-project-storage-acc-access-key"