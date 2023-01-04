variable "resource_group_name" {
  type    = string
  default = "rg-p-docmgmt-001"
}

variable "azure_sql_database_name" {
  type    = string
  default = "DocumentManagement"
}

variable "resource_group_names" {
  type    = string
  default = "rg-p-mgmt-001"
}

variable "azurerm_cosmosdb_sql_database" {
  type    = string
  default = "DocumentManagement"
}

variable "azurerm_cosmosdb_sql_container" {
  type    = string
  default = "DownloadDocument"
}

variable "azurerm_cosmosdb_sql_containers" {
  type    = string
  default = "UploadDocument"
}

variable "azurerm_storage_account" {
  type    = string
  default = "stpdocmgmtfunc001"
}

variable "azurerm_service_plan" {
  type    = string
  default = "asp-ussc-p-DocMgmtUploadDocument"
}

variable "azurerm_windows_function_app" {
  type    = string
  default = "func-ussc-p-DocMgmtUploadDocument-001"
}

variable "azurerm_service_plans" {
  type    = string
  default = "asp-ussc-p-DocMgmtDownloadDocument"
}

variable "azurerm_windows_function_apps" {
  type    = string
  default = "func-ussc-p-DocMgmtDownloadDocument-001"
}

variable "resource_group_location" {
  type    = string
  default = "East US"
}