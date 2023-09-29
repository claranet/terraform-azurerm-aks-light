data "azurerm_subscription" "current" {}

data "azurerm_kubernetes_service_versions" "versions" {
  location        = var.location
  include_preview = false
}

data "azapi_resource" "subnet_delegation" {
  name      = element(split("/", var.aci_subnet_id), 10)
  parent_id = trimsuffix(var.aci_subnet_id, format("/subnets/%s", element(split("/", var.aci_subnet_id), 10)))
  type      = "Microsoft.Network/virtualNetworks/subnets@2023-05-01"

  response_export_values = ["properties.delegations"]
}
