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
    opatoken = var.opatoken,
    zohort = var.zohort,
    zohoscopes = var.zohoscopes,
    zohoorgid = var.zohoorgid,
    zohoapiurl = var.zohoapiurl,
    zohoauthurl = var.zohoauthurl
  })
  configs = tomap({
  })
}

module "graph_api_sp" {
  source             = "../modules/data-ad-sp"
  name               = "Microsoft Graph"
  allowed_role_names = ["User.ReadWrite.All", "Group.ReadWrite.All", "Application.Read.All", "AppRoleAssignment.ReadWrite.All"]
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
  graph_api_object_id             = module.graph_api_sp.object_id
  graph_api_app_roles_ids         = module.graph_api_sp.app_roles_ids
}