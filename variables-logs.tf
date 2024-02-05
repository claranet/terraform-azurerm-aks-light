# Diag settings / logs parameters

variable "logs_destinations_ids" {
  type        = list(string)
  description = <<EOD
List of destination resources IDs for logs diagnostic destination.
Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.
If you want to specify an Azure EventHub to send logs and metrics to, you need to provide a formated string with both the EventHub Namespace authorization send ID and the EventHub name (name of the queue to use in the Namespace) separated by the `pipe` (\|) character.
EOD
}

variable "logs_categories" {
  type        = list(string)
  description = "Log categories to send to destinations."
  default     = null
}

variable "logs_metrics_categories" {
  type        = list(string)
  description = "Metrics categories to send to destinations."
  default     = null
}

variable "custom_diagnostic_settings_name" {
  description = "Custom name of the diagnostics settings, name will be 'default' if not set."
  type        = string
  default     = "default"
}

variable "logs_kube_audit_enabled" {
  description = "Whether to include `kube-audit` and `kube-audit-admin` logs from diagnostics settings collection. Enabling this can increase your Azure billing."
  type        = bool
  default     = false
}

variable "data_collection_rule" {
  description = "AKS Data Collection Rule configuration."
  type = object({
    log_analytics_workspace_id = optional(string)
    data_streams = optional(list(string), [
      "Microsoft-ContainerLog",
      "Microsoft-ContainerLogV2",
      "Microsoft-KubeEvents",
      "Microsoft-KubePodInventory",
      "Microsoft-InsightsMetrics",
      "Microsoft-ContainerInventory",
      "Microsoft-ContainerNodeInventory",
      "Microsoft-KubeNodeInventory",
      "Microsoft-KubeServices",
      "Microsoft-KubePVInventory"
    ])
    namespaces_filter = optional(list(string), [
      "kube-system",
      "gatekeeper-system",
      "kube-node-lease",
      "calico-system",
    ])
    namespace_filtering_mode = optional(string, "Exclude")
    data_collection_interval = optional(string, "5m")
    container_log_v2_enabled = optional(bool, true)

  })
  default  = {}
  nullable = false
}
>>>>>>> e518624 (AZ-1348: Add Data Collection Rule)
