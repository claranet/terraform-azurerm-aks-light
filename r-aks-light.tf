resource "azurerm_kubernetes_cluster" "aks_light" {
  name = local.aks_light_name

  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(local.default_tags, var.extra_tags)
}
