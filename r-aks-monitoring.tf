resource "azurerm_monitor_data_collection_rule" "main" {
  count = var.data_collection_rule.enabled ? 1 : 0

  name                = local.dcr_name
  location            = var.location
  resource_group_name = var.resource_group_name

  destinations {
    log_analytics {
      name                  = "default-workspace"
      workspace_resource_id = coalesce(var.data_collection_rule.custom_log_analytics_workspace_id, local.default_log_analytics)
    }

    dynamic "event_hub" {
      for_each = lookup(var.data_collection_rule, "custom_event_hub_id", local.default_event_hub)[*]
      content {
        name         = "default-eventhub"
        event_hub_id = event_hub.value
      }
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

moved {
  from = azurerm_monitor_data_collection_rule.dcr
  to   = azurerm_monitor_data_collection_rule.main
}

resource "azurerm_monitor_data_collection_rule_association" "main" {
  count = var.data_collection_rule.enabled ? 1 : 0

  name                    = azurerm_kubernetes_cluster.main.name
  target_resource_id      = azurerm_kubernetes_cluster.main.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.main[0].id
}

moved {
  from = azurerm_monitor_data_collection_rule_association.dcr
  to   = azurerm_monitor_data_collection_rule_association.main
}
