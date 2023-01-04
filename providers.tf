# This is the provider for the Azure #

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.3.0"
    }
  }
}

#this subscription is for general prod
provider "azurerm" {
  features {}
  alias           = "prod-sub"
  subscription_id = "6b6c23ac-12a7-4ddb-9a8e-043f53d430ff"
}

#this si the subscription for the sql server
provider "azurerm" {
  features {}
  alias           = "sql-sub"
  subscription_id = "52a56327-d767-4866-87c3-8b81ca5fcc22"
}

provider "azurerm" {
   features {}
}




  
