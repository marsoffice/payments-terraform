terraform {
  backend "azurerm" {
    resource_group_name  = "rg-marsoffice"
    storage_account_name = "samarsoffice"
    container_name       = "tfstates"
    key                  = "payments.stg.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.90"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.14.0"
    }
  }
}

provider "azurerm" {
  features {}
}


locals {
  secrets = tomap({
    zohoclientid = var.zohoclientid,
    zohoclientsecret = var.zohoclientsecret,
    zohoemail = var.zohoemail,
    zohopassword = var.zohopassword
  })
  configs = tomap({
  })
}




module "rg" {
  source   = "../modules/rg"
  name     = "rg-${var.app_name}-${var.env}"
  location = var.location
}


module "graph_api_sp" {
  source             = "../modules/data-ad-sp"
  name               = "Microsoft Graph"
  allowed_role_names = ["User.Read.All", "Group.Read.All", "Application.Read.All", "AppRoleAssignment.ReadWrite.All"]
}

