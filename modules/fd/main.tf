terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_frontdoor" "front_door" {
  name                                         = var.name
  resource_group_name                          = var.resource_group
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "redirectHttpHttps"
    accepted_protocols = ["Http"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["appFrontend"]
    redirect_configuration {
      redirect_protocol = "HttpsOnly"
      redirect_type     = "Found"
    }
  }


  routing_rule {
    name               = "opaRoute"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/opa/*"]
    frontend_endpoints = ["appFrontend"]
    forwarding_configuration {
      forwarding_protocol           = "HttpsOnly"
      backend_pool_name             = "opaBackendPool"
      cache_enabled                 = true
      cache_use_dynamic_compression = true
    }
  }




  backend_pool_load_balancing {
    name = "opaBackendPoolLoadBalancingSetting"
  }
  backend_pool_health_probe {
    name                = "opaBackendPoolHealthProbeSetting"
    path                = "/healthcheck"
    protocol            = "Https"
    interval_in_seconds = var.health_probe_interval
  }
  backend_pool {
    name = "opaBackendPool"
    dynamic "backend" {
      for_each = toset(var.opa_hostnames)
      content {
        enabled     = true
        host_header = backend.value
        address     = backend.value
        http_port   = 80
        https_port  = 443
      }
    }
    load_balancing_name = "opaBackendPoolLoadBalancingSetting"
    health_probe_name   = "opaBackendPoolHealthProbeSetting"
  }



  frontend_endpoint {
    name                     = "fdFrontend"
    host_name                = "${var.name}.azurefd.net"
    session_affinity_enabled = true
  }

  frontend_endpoint {
    name                     = "appFrontend"
    host_name                = var.cname
    session_affinity_enabled = true
  }
}

resource "azurerm_frontdoor_custom_https_configuration" "fd_ssl" {
  frontend_endpoint_id              = azurerm_frontdoor.front_door.frontend_endpoints["appFrontend"]
  custom_https_provisioning_enabled = true
  custom_https_configuration {
    certificate_source = "FrontDoor"
  }
}
