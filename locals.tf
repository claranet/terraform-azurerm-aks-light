locals {

  default_agent_profile = merge(var.default_node_pool, {
    vnet_subnet_id = var.nodes_subnet_id
  })

  default_node_profile = {
    # Defaults for Linux profile
    # Generally smaller images so can run more pods and require smaller HD
    "Linux" = {
      max_pods        = 110
      os_disk_size_gb = 128
    }
    # Defaults for Windows profile
    # Do not want to run same number of pods and some images can be quite large
    "Windows" = {
      max_pods        = 60
      os_disk_size_gb = 256
    }
  }

  default_node_pool         = merge(local.default_agent_profile, var.default_node_pool)
  nodes_pools_with_defaults = [for ap in var.nodes_pools : merge(local.default_agent_profile, ap)]

  private_dns_zone              = var.private_dns_zone_type == "Custom" ? var.private_dns_zone_id : var.private_dns_zone_type
  is_custom_dns_private_cluster = var.private_dns_zone_type == "Custom" && var.private_cluster_enabled
  is_network_cni                = var.aks_network_plugin.name == "azure"

  default_no_proxy_url_list = flatten([
    data.azurerm_subnet.nodes_subnet.address_prefixes,
    var.aks_pod_cidr,
    var.service_cidr,
    "localhost",
    "konnectivity",
    "127.0.0.1",       # Localhost
    "168.63.129.16",   # Azure platform global VIP (https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16)
    "169.254.169.254", # Azure Instance Metadata Service (IMDS)
  ])

  #tflint-ignore: terraform_naming_convention
  _managed_private_dns_zone_name = try(split(".", azurerm_kubernetes_cluster.aks.private_fqdn), null)
  managed_private_dns_zone_name  = try(join(".", [for x in local._managed_private_dns_zone_name : x if index(local._managed_private_dns_zone_name, x) > 0]), null)
  managed_private_dns_zone_id    = azurerm_kubernetes_cluster.aks.private_dns_zone_id == "System" ? format("%s/resourceGroups/%s/providers/Microsoft.Network/privateDnsZones/%s", data.azurerm_subscription.current.id, azurerm_kubernetes_cluster.aks.node_resource_group, local.managed_private_dns_zone_name) : null
}
