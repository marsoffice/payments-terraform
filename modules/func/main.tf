terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group
  app_service_plan_id        = var.app_service_plan_id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  os_type                    = "linux"
  version                    = "~4"
  enabled = var.enabled

  identity {
    type = "SystemAssigned"
  }

  site_config {
    dotnet_framework_version  = "v6.0"
    use_32_bit_worker_process = false
  }

  auth_settings {
    enabled = false
  }

  app_settings = merge(var.app_configs, tomap({
    AzureWebJobsDisableHomepage       = "true",
    APPINSIGHTS_INSTRUMENTATIONKEY    = "${var.appi_instrumentation_key}",
    FUNCTIONS_WORKER_RUNTIME          = var.runtime,
    AZURE_FUNCTIONS_ENVIRONMENT       = var.func_env,
    "WEBSITE_RUN_FROM_PACKAGE"        = "",
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE" = "true"
  }))

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"],
    ]
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "key_vault_access_policy" {
  key_vault_id = var.kvl_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_function_app.function_app.identity[0].principal_id

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
  ]
}

module "role_assignment" {
  source       = "../ad-sp-app-role-assignment"
  principal_id = azurerm_function_app.function_app.identity[0].principal_id
  resource_id  = split(",", each.value)[0]
  app_role_id  = split(",", each.value)[1]
  msi_id       = azurerm_function_app.function_app.identity[0].principal_id
  for_each     = toset(var.roles)
}
