variable "default_tags_enabled" {
  description = "Option to enable or disable default tags."
  type        = bool
  default     = true
}

variable "extra_tags" {
  description = "Additional tags to add on resources."
  type        = map(string)
  default     = {}
}

variable "default_node_pool_tags" {
  description = "Specific tags for default node pool"
  type        = map(string)
  default     = {}
}

variable "node_pool_tags" {
  description = "Specific tags for node pool"
  type        = map(string)
  default     = {}
}

variable "aks_user_assigned_identity_tags" {
  description = "Tags to add to AKS MSI"
  type        = map(string)
  default     = {}
}
