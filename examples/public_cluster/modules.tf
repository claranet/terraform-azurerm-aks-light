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

  client_name    = var.client_name
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  monitoring_function_enabled = false
}

# This must either be created in a separated stack, or targeted with
# `terraform apply -target module.acr.azurerm_container_registry.registry`
# as list output must be known by aks module
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

data "http" "my_ip" {
  url = "https://ip4.clara.net"
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

  private_cluster_enabled         = false
  api_server_authorized_ip_ranges = ["${chomp(data.http.my_ip.response_body)}/32"]

  node_pools = [
    {
      name            = "pool1"
      count           = 1
      vm_size         = "Standard_DS2_v2"
      os_disk_type    = "Ephemeral"
      os_disk_size_gb = 30
      vnet_subnet_id  = module.nodes_subnet.subnet_id
    },
    {
      name                = "bigpool1"
      vm_size             = "Standard_F8s_v2"
      os_disk_size_gb     = 30
      vnet_subnet_id      = module.nodes_subnet.subnet_id
      enable_auto_scaling = true
      min_count           = 3
      max_count           = 9
    },
  ]

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
