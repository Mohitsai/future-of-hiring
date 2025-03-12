# variables.tf
# This file declares input variables that parameterize the Terraform configuration.
# It makes the configuration more modular, reusable, and configurable without 
# modifying the core code directly.


variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID."
}

variable "location" {
  type        = string
  description = "Azure region in which to create resources."
  default     = "centralus"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group."
}

variable "storage_account_name" {
  type        = string
  description = "Name of the Storage Account."
}

variable "container_name" {
  type        = string
  description = "Name of the container (Data Lake Gen2 filesystem)."
}

variable "cont_folder_list" {
  type        = list(string)
  description = "List of folder paths to create within the container."
}

variable "data_factory_name" {
  type        = string
  description = "Name of the Azure Data Factory."
}

variable "databricks_workspace_name" {
  type        = string
  description = "Name of the Azure Databricks Workspace."
}

variable "key_vault_name" {
  type        = string
  description = "Name of the Azure Key Vault."
}

variable "azure_function_key_secret_name" {
  type        = string
  description = "Secret name in Azure Key Vault for the Azure function key"
}

variable "databricks_cluster_token_secret_name" {
  type        = string
  description = "Secret name in Azure Key Vault for the Databricks cluster access token"
}

variable "app_client_id_secret_name" {
  type        = string
  description = "Secret name in Azure Key Vault for the service principal client id"
}

variable "app_client_secret_secret_name" {
  type        = string
  description = "Secret name in Azure Key Vault for the service principal client secret"
}

variable "app_tenant_id_secret_name" {
  type        = string
  description = "Secret name in Azure Key Vault for the service principal tenant id"
}

variable "storage_account_access_key_secret_name" {
  type        = string
  description = "Secret name in Azure Key Vault for the service account access key"
}