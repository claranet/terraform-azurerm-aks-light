resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  count = length(local.nodes_pools)

  kubernetes_cluster_id  = azurerm_kubernetes_cluster.aks.id
  name                   = local.nodes_pools[count.index].name
  vm_size                = local.nodes_pools[count.index].vm_size
  os_type                = local.nodes_pools[count.index].os_type
  orchestrator_version   = local.nodes_pools[count.index].orchestrator_version
  os_disk_type           = local.nodes_pools[count.index].os_disk_type
  os_disk_size_gb        = local.nodes_pools[count.index].os_disk_size_gb
  priority               = local.nodes_pools[count.index].priority
  vnet_subnet_id         = local.nodes_pools[count.index].vnet_subnet_id
  enable_host_encryption = local.nodes_pools[count.index].enable_host_encryption
  eviction_policy        = local.nodes_pools[count.index].eviction_policy
  enable_auto_scaling    = local.nodes_pools[count.index].enable_auto_scaling
  node_count             = local.nodes_pools[count.index].enable_auto_scaling ? null : local.nodes_pools[count.index].node_count
  min_count              = local.nodes_pools[count.index].enable_auto_scaling ? local.nodes_pools[count.index].min_count : null
  max_count              = local.nodes_pools[count.index].enable_auto_scaling ? local.nodes_pools[count.index].max_count : null
  max_pods               = local.nodes_pools[count.index].max_pods
  node_labels            = local.nodes_pools[count.index].node_labels
  node_taints            = local.nodes_pools[count.index].node_taints
  enable_node_public_ip  = local.nodes_pools[count.index].enable_node_public_ip
  zones                  = local.nodes_pools[count.index].zones
  tags                   = merge(local.default_tags, var.node_pool_tags)
}
