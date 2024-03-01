locals {
  default_node_profile = {
    # Defaults for Linux profile
    # Generally smaller images so can run more pods and require smaller HD
    linux = {
      os_disk_size_gb = 128
      max_pods        = 110
    }

    # Defaults for Windows profile
    # Do not want to run same number of pods and some images can be quite large
    windows = {
      os_disk_size_gb = 256
      max_pods        = 60
    }
  }

  default_node_pool = merge(
    var.default_node_pool,
    {
      vnet_subnet_id = format(
        "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s",
        data.azurerm_subscription.current.subscription_id,
        coalesce(var.nodes_subnet.resource_group_name, var.resource_group_name),
        var.nodes_subnet.virtual_network_name,
        var.nodes_subnet.name,
      )
      pod_subnet_id = try(format(
        "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s",
        data.azurerm_subscription.current.subscription_id,
        coalesce(var.pods_subnet.resource_group_name, var.resource_group_name),
        var.pods_subnet.virtual_network_name,
        var.pods_subnet.name,
      ), null)
    },
  )

  node_pools = [
    for np in var.node_pools : merge(
      np,
      {
        vnet_subnet_id = format(
          "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s",
          data.azurerm_subscription.current.subscription_id,
          coalesce(np.node_subnet.resource_group_name, var.nodes_subnet.resource_group_name, var.resource_group_name),
          coalesce(np.node_subnet.virtual_network_name, var.nodes_subnet.virtual_network_name),
          coalesce(np.node_subnet.name, var.nodes_subnet.name),
        )
        pod_subnet_id = try(format(
          "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s",
          data.azurerm_subscription.current.subscription_id,
          coalesce(np.pod_subnet.resource_group_name, var.pods_subnet.resource_group_name, var.resource_group_name),
          coalesce(np.pod_subnet.virtual_network_name, var.pods_subnet.virtual_network_name),
          coalesce(np.pod_subnet.name, var.pods_subnet.name),
        ), null)
      },
    )
  ]

  subnet_ids = distinct(compact(concat(
    local.node_pools[*].vnet_subnet_id,
    local.node_pools[*].pod_subnet_id,
    [
      local.default_node_pool.vnet_subnet_id,
      local.default_node_pool.pod_subnet_id,
    ],
  )))

  private_dns_zone              = var.private_dns_zone_type == "Custom" ? var.private_dns_zone_id : var.private_dns_zone_type
  is_custom_dns_private_cluster = var.private_dns_zone_type == "Custom" && var.private_cluster_enabled
  is_network_cni                = var.aks_network_plugin.name == "azure"
  is_kubenet                    = var.aks_network_plugin.name == "kubenet"

  default_no_proxy_list = [
    var.aks_pod_cidr,
    var.service_cidr,
    "localhost",
    "konnectivity",
    "127.0.0.1",       # Localhost
    "172.17.0.0/16",   # Default Docker bridge CIDR
    "168.63.129.16",   # Azure platform global VIP (https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16)
    "169.254.169.254", # Azure Instance Metadata Service (IMDS)
  ]

  #tflint-ignore: terraform_naming_convention
  _managed_private_dns_zone_name = try(split(".", azurerm_kubernetes_cluster.aks.private_fqdn), null)
  managed_private_dns_zone_name  = try(join(".", [for x in local._managed_private_dns_zone_name : x if index(local._managed_private_dns_zone_name, x) > 0]), null)
  managed_private_dns_zone_id    = azurerm_kubernetes_cluster.aks.private_dns_zone_id == "System" ? format("%s/resourceGroups/%s/providers/Microsoft.Network/privateDnsZones/%s", data.azurerm_subscription.current.id, azurerm_kubernetes_cluster.aks.node_resource_group, local.managed_private_dns_zone_name) : null
  default_log_analytics          = coalescelist([for r in var.logs_destinations_ids : r if contains(split("/", lower(r)), "microsoft.operationalinsights")], [null])[0]
}
