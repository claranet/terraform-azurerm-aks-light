data "azurerm_subscription" "current" {}

data "azurerm_subnet" "subnets" {
  for_each = toset(var.aks_http_proxy_settings != null ? local.subnet_ids : [])

  name                 = reverse(split("/", each.key))[0]
  resource_group_name  = split("/", each.key)[4]
  virtual_network_name = split("/", each.key)[8]
}

data "azurerm_kubernetes_service_versions" "versions" {
  location        = var.location
  include_preview = false
}
