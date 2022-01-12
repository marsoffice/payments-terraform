variable "location" {
  type = string
}

variable "env" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "app_name" {
  type = string
}


variable "secrets" {
  type = map(string)
}

variable "configs" {
  type = map(string)
}

variable "is_main" {
  type = bool
}

variable "appi_retention" {
  type = number
}
variable "appi_sku" {
  type = string
}

variable "graph_api_object_id" {
  type = string
}

variable "graph_api_app_roles_ids" {
  type = map(string)
}
