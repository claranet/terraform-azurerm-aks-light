resource "azurerm_monitor_data_collection_rule" "dcr" {
  for_each = var.data_collection_rule_enabled ? toset(["enabled"]) : []

  name                = local.dcr_name
  location            = var.location
  resource_group_name = var.resource_group_name

  destinations {
    log_analytics {
      name                  = "default-workspace"
      workspace_resource_id = coalesce(var.data_collection_rule.custom_log_analytics_workspace_id, local.default_log_analytics)
    }
  }

  data_flow {
    destinations = ["default-workspace"]
    streams      = var.data_collection_rule.data_streams
  }

  data_sources {
    extension {
      name           = "ContainerInsightsExtension"
      extension_name = "ContainerInsights"
      streams        = var.data_collection_rule.data_streams
      extension_json = jsonencode({
        dataCollectionSettings = {
          enableContainerLogV2   = var.data_collection_rule.container_log_v2_enabled
          interval               = var.data_collection_rule.data_collection_interval
          namespaceFilteringMode = var.data_collection_rule.namespace_filtering_mode
          namespaces             = var.data_collection_rule.namespaces_filter
        }
      })
    }
  }

  tags = merge(local.default_tags, var.extra_tags)
}

resource "azurerm_monitor_data_collection_rule_association" "dcr" {
  for_each                = var.data_collection_rule_enabled ? toset(["enabled"]) : []
  name                    = azurerm_kubernetes_cluster.aks.name
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr["enabled"].id
}
