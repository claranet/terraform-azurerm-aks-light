data "azurerm_subscription" "current" {}

data "azurerm_subnet" "nodes_subnet" {
  name                 = reverse(split("/", var.nodes_subnet_id))[0]
  resource_group_name  = split("/", var.nodes_subnet_id)[4]
  virtual_network_name = split("/", var.nodes_subnet_id)[8]
}

data "azurerm_kubernetes_service_versions" "versions" {
  location = var.location

  include_preview = false
}
