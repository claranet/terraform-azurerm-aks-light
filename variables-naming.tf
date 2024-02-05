# Generic naming variables
variable "name_prefix" {
  description = "Optional prefix for the generated name."
  type        = string
  default     = ""
}

variable "name_suffix" {
  description = "Optional suffix for the generated name."
  type        = string
  default     = ""
}

# Custom naming override
variable "custom_name" {
  description = "Custom AKS, generated if not set."
  type        = string
  default     = ""
}

variable "aks_user_assigned_identity_custom_name" {
  description = "Custom name for the AKS user assigned identity resource."
  type        = string
  default     = null
}

variable "data_collection_rule_custom_name" {
  description = "Custom name for the AKS Data Collection Rule."
  type        = string
  default     = null
}
