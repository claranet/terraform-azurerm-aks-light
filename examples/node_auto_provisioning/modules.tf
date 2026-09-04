module "vnet" {
  source  = "claranet/vnet/azurerm"
  version = "x.x.x"

  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  resource_group_name = module.rg.name

  cidrs = ["10.0.0.0/19"]
}

module "nodes_subnet" {
  source  = "claranet/subnet/azurerm"
  version = "x.x.x"

  location_short      = module.azure_region.location_short
  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  resource_group_name = module.rg.name

  name_suffix = "nodes"

  virtual_network_name = module.vnet.name

  cidrs             = ["10.0.0.0/20"]
  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

module "private_dns_zone" {
  source  = "claranet/private-endpoint/azurerm//modules/private-dns-zone"
  version = "x.x.x"

  environment         = var.environment
  stack               = var.stack
  resource_group_name = module.rg.name

  name                = "privatelink.${module.azure_region.location_cli}.azmk8s.io"
  virtual_network_ids = [module.vnet.id]
}

module "aks" {
  source  = "claranet/aks-light/azurerm"
  version = "x.x.x"

  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  resource_group_name = module.rg.name

  service_cidr = "10.0.16.0/22"
  pod_cidr     = "192.168.0.0/16"

  # Node Auto-Provisioning supports Azure CNI, Azure CNI Overlay and Azure CNI
  # Overlay powered by Cilium. The Calico network policy is not supported.
  network_plugin = {
    name     = "azure"
    cni_mode = "overlay"
  }
  network_policy     = "cilium"
  network_data_plane = "cilium"

  nodes_subnet = {
    name                 = module.nodes_subnet.name
    virtual_network_name = module.vnet.name
  }

  private_cluster_enabled = true
  private_dns_zone_type   = "Custom"
  private_dns_zone_id     = module.private_dns_zone.id

  # A "System" mode node pool is still required, Node Auto-Provisioning only
  # manages the additional nodes needed by the workloads.
  default_node_pool = {
    vm_size         = "Standard_D2s_v5"
    os_disk_size_gb = 64
  }

  # Node Auto-Provisioning (Karpenter) replaces the manually defined node pools,
  # hence no `node_pools` here. `default_node_pools = "Auto"` lets AKS create the
  # `default` and `system-surge` Karpenter node pools, set it to "None" to
  # provide your own `NodePool` custom resources.
  node_provisioning_profile = {
    mode               = "Auto"
    default_node_pools = "Auto"
  }

  oms_agent = {
    log_analytics_workspace_id = module.run.log_analytics_workspace_id
  }

  logs_destinations_ids = [module.run.log_analytics_workspace_id]
}
