module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "run" {
  source  = "claranet/run/azurerm"
  version = "x.x.x"

  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  monitoring_function_enabled = false
}

module "acr" {
  source  = "claranet/acr/azurerm"
  version = "x.x.x"

  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  sku = "Standard"

  logs_destinations_ids = [module.run.log_analytics_workspace_id]
}

module "vnet" {
  source  = "claranet/vnet/azurerm"
  version = "x.x.x"

  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  vnet_cidr = ["10.0.0.0/19"]
}

module "nodes_subnet" {
  source  = "claranet/subnet/azurerm"
  version = "x.x.x"

  location_short = module.azure_region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  name_suffix = "nodes"

  virtual_network_name = module.vnet.virtual_network_name

  subnet_cidr_list  = ["10.0.0.0/20"]
  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

module "aks_private_dns_zone" {
  source  = "claranet/private-endpoint/azurerm//modules/private-dns-zone"
  version = "x.x.x"

  environment = var.environment
  stack       = var.stack

  resource_group_name = module.rg.resource_group_name

  private_dns_zone_name      = "privatelink.${module.azure_region.location_cli}.azmk8s.io"
  private_dns_zone_vnets_ids = [module.vnet.virtual_network_id]
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

module "aks" {
  source  = "claranet/aks-light/azurerm"
  version = "x.x.x"

  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  kubernetes_version = "1.27.3"
  service_cidr       = "10.0.16.0/22"

  nodes_subnet = {
    name                 = module.nodes_subnet.subnet_name
    virtual_network_name = module.vnet.virtual_network_name
  }

  private_cluster_enabled = true
  private_dns_zone_type   = "Custom"
  private_dns_zone_id     = module.aks_private_dns_zone.private_dns_zone_id

  default_node_pool = {
    vm_size         = "Standard_B4ms"
    os_disk_size_gb = 64
  }

  node_pools = [{
    name                = "nodepool1"
    vm_size             = "Standard_B4ms"
    os_disk_type        = "Ephemeral"
    os_disk_size_gb     = 100
    vnet_subnet_id      = module.nodes_subnet.subnet_id
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 10
  }]

  linux_profile = {
    username = "nodeadmin"
    ssh_key  = tls_private_key.key.public_key_openssh
  }

  container_registries_ids = [module.acr.acr_id]

  oms_agent = {
    log_analytics_workspace_id = module.run.log_analytics_workspace_id
  }

  logs_destinations_ids = [module.run.log_analytics_workspace_id]
}
