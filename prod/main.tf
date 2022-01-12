terraform {
  backend "azurerm" {
    resource_group_name  = "rg-marsoffice"
    storage_account_name = "samarsoffice"
    container_name       = "tfstates"
    key                  = "payments.prod.tfstate"
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
    zohopassword = var.zohopassword,
    opaurl = var.opaurl,
    opatoken = var.opatoken
  })
  configs = tomap({
  })
}




module "rg" {
  source   = "../modules/rg"
  name     = "rg-${var.app_name}-${var.env}"
  location = var.location
}

module "zone_westeurope" {
  source                          = "../modules/zone"
  location                        = "West Europe"
  resource_group                  = module.rg.name
  app_name                        = var.app_name
  env                             = var.env
  secrets                         = local.secrets
  configs                         = local.configs
  is_main                         = true
  appi_retention                  = 30
  appi_sku                        = "PerGB2018"
  short_app_name = var.short_app_name
}