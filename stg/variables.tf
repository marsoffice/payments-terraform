variable "env" {
  type    = string
  default = "stg"
}

variable "app_name" {
  type    = string
  default = "payments"
}


variable "short_app_name" {
  type    = string
  default = "pay"
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "zohoclientid" {
  type = string
}

variable "zohoclientsecret" {
  type = string
}

variable "zohoemail" {
  type = string
}

variable "zohopassword" {
  type = string
}
variable "zohort" {
  type = string
}

variable "zohoscopes" {
  type = string
}
variable "zohoorgid" {
  type = string
}
variable "zohoapiurl" {
  type = string
}
variable "zohoauthurl" {
  type = string
}