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
  for_each = toset(local.is_network_cni ? compact(concat([var.nodes_subnet_id, var.pod_subnet_id], flatten(concat(var.nodes_pools[*].vnet_subnet_id, var.nodes_pools[*].pod_subnet_id)))) : [])

  scope                = each.value
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity.principal_id
}

# Role assignment for ACI, if ACI is enabled
data "azuread_service_principal" "aci_identity" {
  count = length(var.aci_subnet_id[*])

  display_name = "aciconnectorlinux-${local.aks_name}"
  depends_on   = [azurerm_kubernetes_cluster.aks]
}

resource "azurerm_role_assignment" "aci_assignment" {
  count = length(var.aci_subnet_id[*])

  scope                = var.aci_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.aci_identity[0].id
}

# Allow user assigned identity to manage AKS items in MC_xxx RG
resource "azurerm_role_assignment" "aks_user_assigned" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.aks.node_resource_group)
  role_definition_name = "Contributor"
}
