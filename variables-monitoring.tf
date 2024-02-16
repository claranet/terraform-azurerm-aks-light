variable "logs_kube_audit_enabled" {
  description = "Whether to include `kube-audit` and `kube-audit-admin` logs from diagnostics settings collection. Enabling this can increase your Azure billing."
  type        = bool
  default     = false
}

variable "data_collection_rule" {
  description = "AKS Data Collection Rule configuration."
  type = object({
    enabled                           = optional(bool, true)
    custom_log_analytics_workspace_id = optional(string)
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
