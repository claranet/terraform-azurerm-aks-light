#### Common variables
variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region to use."
  type        = string
  nullable    = false
}

variable "location_short" {
  description = "Short string for Azure location."
  type        = string
  nullable    = false
}

variable "client_name" {
  description = "Client name/account used in naming."
  type        = string
  nullable    = false
}

variable "environment" {
  description = "Project environment."
  type        = string
  nullable    = false
}

variable "stack" {
  description = "Project stack name."
  type        = string
  nullable    = false
}
