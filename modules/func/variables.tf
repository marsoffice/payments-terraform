variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group" {
  type = string
}


variable "storage_account_name" {
  type = string
}

variable "storage_account_access_key" {
  type = string
}

variable "app_service_plan_id" {
  type = string
}

variable "kvl_id" {
  type = string
}

variable "app_configs" {
  type = map(string)
}

variable "appi_instrumentation_key" {
  type = string
}

variable "func_env" {
  type = string
}

variable "runtime" {
  type = string
}

variable "roles" {
  type = list(string)
}
