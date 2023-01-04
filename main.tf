data "azurerm_resource_group" "this" {
    provider = azurerm.prod-sub
    name = "rg-use-p-hubeventdata"
}

data "azurerm_resource_group" "these" {
    provider = azurerm.sql-sub
    name = "SqlServerGeneral_RG"
}



data "azurerm_mssql_server" "sql" {
  provider            = azurerm.sql-sub
  name                = "sql-general-a"
  resource_group_name = data.azurerm_resource_group.these.name
}

data "azurerm_cosmosdb_account" "cosmodb" {
  provider            = azurerm.prod-sub
  name                = "cosmos-use-p-hubevent"
  resource_group_name = "rg-use-p-hubeventdata"
}


resource "azurerm_storage_account" "storage" {
  provider                 = azurerm.prod-sub
  name                     = "stusscpdocmgmtdocs001"
  resource_group_name      = azurerm_resource_group.RG.name
  location                 = azurerm_resource_group.RG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
    company     = "Signature Aviaition"
    Application = "Document Management Hub" 
  }
}

resource "azurerm_storage_container" "container1" {
    provider = azurerm.prod-sub
    name                  = "signet"
    storage_account_name  = azurerm_storage_account.storage.name
    container_access_type = "private"
}

resource "azurerm_storage_container" "container2" {
    provider = azurerm.prod-sub
    name                  = "blobchangefeed"
    storage_account_name  = azurerm_storage_account.storage.name
    container_access_type = "private"
}

resource "azurerm_storage_container" "container3" {
    provider = azurerm.prod-sub
    name                  = "logs"
    storage_account_name  = azurerm_storage_account.storage.name
    container_access_type = "private"
}

#This resource group is meant for the storage account alone
resource "azurerm_resource_group" "RG" {
  provider = azurerm.prod-sub
  name     = var.resource_group_name
  location = var.resource_group_location
   
 tags = {
    Environment = "Production "
    Company     = "Signature Aviation" 
    Application = "Document Management Hub"
  }
}

#this resource group is meant for the function apps alone
resource "azurerm_resource_group" "resouregroupf" {
  provider = azurerm.prod-sub
  name     = var.resource_group_names
  location = var.resource_group_location
   
 tags = {
    Environment = "Production "
    Company     = "Signature Aviation" 
    Application = "Document Management Hub"
  }
}

#Creating an SQL Database 

resource "azurerm_mssql_database" "sql" {
  provider            = azurerm.sql-sub
  name                = var.azure_sql_database_name
  server_id           = data.azurerm_mssql_server.sql.id
  license_type        = "LicenseIncluded"

  tags = {
    environment = "production"
    company     = "Signature Aviaition"
    Application = "Document Management Hub" 
  }
}
 #CREATION OF THE COSMO DB

resource "azurerm_cosmosdb_sql_database" "cosmo" {
  provider            = azurerm.prod-sub
  name                = var.azurerm_cosmosdb_sql_database
  resource_group_name = data.azurerm_cosmosdb_account.cosmodb.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmodb.name
}

resource "azurerm_cosmosdb_sql_container" "cosmocon1" {
  provider              = azurerm.prod-sub
  name                  = var.azurerm_cosmosdb_sql_container
  resource_group_name   = data.azurerm_cosmosdb_account.cosmodb.resource_group_name
  account_name          = data.azurerm_cosmosdb_account.cosmodb.name
  database_name         = azurerm_cosmosdb_sql_database.cosmo.name
  partition_key_path    = "/Request/id"
  partition_key_version = 1
  throughput            = 4000

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/included/?"
    }

    excluded_path {
      path = "/excluded/?"
    }
  }

  unique_key {
    paths = ["/definition/idlong", "/definition/idshort"]
  }
}

resource "azurerm_cosmosdb_sql_container" "cosmocon2" {
  provider              = azurerm.prod-sub
  name                  = var.azurerm_cosmosdb_sql_containers
  resource_group_name   = data.azurerm_cosmosdb_account.cosmodb.resource_group_name
  account_name          = data.azurerm_cosmosdb_account.cosmodb.name
  database_name         = azurerm_cosmosdb_sql_database.cosmo.name
  partition_key_path    = "/Request/id"
  partition_key_version = 1
  throughput            = 4000

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/included/?"
    }

    excluded_path {
      path = "/excluded/?"
    }
  }

  unique_key {
    paths = ["/definition/idlong", "/definition/idshort"]
  }
}

#Creation of Function Apps

#This is the creation of the storage account for the function apps
resource "azurerm_storage_account" "storagefunction" {
  provider                 = azurerm.prod-sub
  name                     = var.azurerm_storage_account
  resource_group_name      = azurerm_resource_group.resouregroupf.name
  location                 = azurerm_resource_group.resouregroupf.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "serviceup" {
  provider            = azurerm.prod-sub
  name                = var.azurerm_service_plan
  location            = azurerm_resource_group.resouregroupf.location
  resource_group_name = azurerm_resource_group.resouregroupf.name
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_windows_function_app" "functionup" {
  provider                   = azurerm.prod-sub
  name                       = var.azurerm_windows_function_app
  location                   = azurerm_resource_group.resouregroupf.location
  resource_group_name        = azurerm_resource_group.resouregroupf.name
  service_plan_id            = azurerm_service_plan.serviceup.id
  storage_account_name       = azurerm_storage_account.storagefunction.name
  
  site_config {}

tags = {
    environment = "production"
    company     = "Signature Aviaition"
    Application = "Document Management Hub" 
  }
}


# #this is the second service plan
resource "azurerm_service_plan" "servicedn" {
  provider            = azurerm.prod-sub
  name                = var.azurerm_service_plans
  location            = azurerm_resource_group.resouregroupf.location
  resource_group_name = azurerm_resource_group.resouregroupf.name
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_windows_function_app" "functiondn" {
  provider                   = azurerm.prod-sub
  name                       = var.azurerm_windows_function_apps
  location                   = azurerm_resource_group.resouregroupf.location
  resource_group_name        = azurerm_resource_group.resouregroupf.name
  service_plan_id            = azurerm_service_plan.servicedn.id
  storage_account_name       = azurerm_storage_account.storagefunction.name
  
  site_config {}

tags = {
    environment = "production"
    company     = "Signature Aviaition"
    Application = "Document Management Hub" 
  }
}

#Creation of Api Management

resource "azurerm_api_management" "apim" {
  provider            = azurerm.prod-sub
  name                = "signatureaviationapim"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  publisher_name      = "Signature Aviaiton"
  publisher_email     = "svc-az-saapi@bbaaviation.net"

  sku_name = "Standard_1"

   tags = {
    environment = "production"
    company     = "Signature Aviaition"
    Application = "Signature API" 
  }
}