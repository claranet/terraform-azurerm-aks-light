locals {
  default_node_profile = {
    # Defaults for Linux profile
    # Generally smaller images so can run more pods and require smaller HD
    "Linux" = {
      os_sku          = "Ubuntu"
      os_disk_size_gb = 128
      max_pods        = 110
    }
    # Defaults for Windows profile
    # Do not want to run same number of pods and some images can be quite large
    "Windows" = {
      os_sku          = "Windows2022"
      os_disk_size_gb = 256
      max_pods        = 60
    }
  }

  default_node_pool = merge(
    var.default_node_pool,
    {
      vnet_subnet_id = coalesce(var.default_node_pool.vnet_subnet_id, var.nodes_subnet_id)
      pod_subnet_id  = try(coalesce(var.default_node_pool.pod_subnet_id, var.pods_subnet_id), null)
    },
  )

  node_pools = [
    for np in var.node_pools : merge(
      np,
      {
        vnet_subnet_id = coalesce(np.vnet_subnet_id, var.nodes_subnet_id)
        pod_subnet_id  = try(coalesce(np.pod_subnet_id, var.pods_subnet_id), null)
      },
    )
  ]

  subnet_ids = distinct(compact(concat(
    var.node_pools[*].vnet_subnet_id,
    var.node_pools[*].pod_subnet_id,
    [
      local.default_node_pool.vnet_subnet_id,
      local.default_node_pool.pod_subnet_id,
    ],
  )))

  private_dns_zone              = var.private_dns_zone_type == "Custom" ? var.private_dns_zone_id : var.private_dns_zone_type
  is_custom_dns_private_cluster = var.private_dns_zone_type == "Custom" && var.private_cluster_enabled
  is_network_cni                = var.aks_network_plugin.name == "azure"
  is_kubenet                    = var.aks_network_plugin.name == "kubenet"

  default_no_proxy_url_list = [
    values(data.azurerm_subnet.subnets)[*].address_prefixes,
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
}
