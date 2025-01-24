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

  resource_group_name = module.rg.name

  sku = "Standard"

  logs_destinations_ids = [module.run.log_analytics_workspace_id]
}

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

data "http" "my_ip" {
  url = "https://ip4.clara.net"
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
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

  kubernetes_version = "1.30.4"
  service_cidr       = "10.0.16.0/22"

  nodes_subnet = {
    name                 = module.nodes_subnet.name
    virtual_network_name = module.vnet.name
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
      vnet_subnet_id  = module.nodes_subnet.id
    },
    {
      name                = "bigpool1"
      vm_size             = "Standard_F8s_v2"
      os_disk_size_gb     = 30
      vnet_subnet_id      = module.nodes_subnet.id
      enable_auto_scaling = true
      min_count           = 3
      max_count           = 9
    },
  ]

  linux_profile = {
    username = "nodeadmin"
    ssh_key  = tls_private_key.main.public_key_openssh
  }

  container_registry_id = module.acr.id

  oms_agent = {
    log_analytics_workspace_id = module.run.log_analytics_workspace_id
  }

  logs_destinations_ids = [module.run.log_analytics_workspace_id]
}
