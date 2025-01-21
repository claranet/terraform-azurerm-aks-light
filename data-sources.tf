data "azurerm_subscription" "current" {}

data "azurerm_kubernetes_service_versions" "main" {
  location        = var.location
  include_preview = false
}

data "azapi_resource" "subnet_delegation" {
  count = length(var.aci_subnet[*])

  name      = local.parsed_aci_subnet_id.name
  parent_id = local.parsed_aci_subnet_id.parent_id
  type      = "Microsoft.Network/virtualNetworks/subnets@2023-05-01"

  response_export_values = ["properties.delegations"]
}
