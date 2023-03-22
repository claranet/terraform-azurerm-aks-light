resource "azurerm_user_assigned_identity" "aks_user_assigned_identity" {
  name                = local.aks_identity_name
  resource_group_name = coalesce(var.aks_user_assigned_identity_resource_group_name, var.resource_group_name)
  location            = var.location

  tags = merge(local.default_tags, var.aks_user_assigned_identity_tags)
}

resource "azurerm_role_assignment" "aks_uai_private_dns_zone_contributor" {
  count = local.is_custom_dns_private_cluster && var.private_dns_zone_role_assignment_enabled ? 1 : 0

  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity.principal_id
}

resource "azurerm_role_assignment" "aks_uai_vnet_network_contributor" {
  count = local.is_custom_dns_private_cluster ? 1 : 0

  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity.principal_id
}

resource "azurerm_role_assignment" "aks_kubelet_uai_vnet_network_contributor" {
  count = local.is_custom_dns_private_cluster ? 1 : 0

  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# Role assignment for ACI, if ACI is enabled
data "azuread_service_principal" "aci_identity" {
  count        = var.aci_subnet_id != null ? 1 : 0
  display_name = "aciconnectorlinux-${coalesce(var.custom_aks_name, local.aks_name)}"
  depends_on   = [azurerm_kubernetes_cluster.aks]
}

resource "azurerm_role_assignment" "aci_assignment" {
  count                = var.aci_subnet_id != null ? 1 : 0
  scope                = var.aci_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.aci_identity[0].id
}
