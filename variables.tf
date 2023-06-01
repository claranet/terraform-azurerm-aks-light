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
<<<<<<< HEAD
  description = "Short string for Azure location."
=======
  description = "Short name of the Azure region to use."
>>>>>>> f86a485 (AZ-1027: Various improvements #2)
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
