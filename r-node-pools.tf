resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  for_each = { for np in local.nodes_pools_with_defaults : np.name => np }

  kubernetes_cluster_id  = azurerm_kubernetes_cluster.aks.id
  name                   = each.value.name
  vm_size                = each.value.vm_size
  os_type                = each.value.os_type
  orchestrator_version   = each.value.orchestrator_version
  os_disk_type           = each.value.os_disk_type
  priority               = each.value.priority
  vnet_subnet_id         = each.value.vnet_subnet_id
  pod_subnet_id          = each.value.pod_subnet_id
  enable_host_encryption = each.value.enable_host_encryption
  eviction_policy        = each.value.eviction_policy
  enable_auto_scaling    = each.value.enable_auto_scaling
  node_count             = each.value.enable_auto_scaling ? null : each.value.node_count
  min_count              = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count              = each.value.enable_auto_scaling ? each.value.max_count : null
  node_labels            = each.value.node_labels
  node_taints            = each.value.node_taints
  enable_node_public_ip  = each.value.enable_node_public_ip
  zones                  = each.value.zones

  # Handle default value depending on os_type
  max_pods        = coalesce(each.value.max_pods, local.default_node_profile[each.value.os_type].max_pods)
  os_disk_size_gb = coalesce(each.value.os_disk_size_gb, local.default_node_profile[each.value.os_type].os_disk_size_gb)

  tags = merge(local.default_tags, each.value.tags)
}
