resource "azurerm_user_assigned_identity" "aks_user_assigned_identity" {
  name     = local.aks_identity_name
  location = var.location

  resource_group_name = coalesce(var.aks_user_assigned_identity_resource_group_name, var.resource_group_name)

  tags = local.aks_uai_tags
}

resource "azurerm_role_assignment" "aks_uai_private_dns_zone_contributor" {
  count = local.is_custom_dns_private_cluster && var.private_dns_zone_role_assignment_enabled ? 1 : 0

  scope                = var.private_dns_zone_id
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity.principal_id
  role_definition_name = "Private DNS Zone Contributor"
}

resource "azurerm_role_assignment" "aks_uai_subnets_network_contributor" {
  for_each = toset(local.subnet_ids)

  scope                = each.key
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity.principal_id
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "aks_uai_route_table_contributor" {
  count = local.is_kubenet && var.outbound_type == "userDefinedRouting" ? 1 : 0

  scope                = var.aks_route_table_id
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity.principal_id
  role_definition_name = "Contributor"
}

# Allow Kubelet Identity to manage AKS items in nodes RG
resource "azurerm_role_assignment" "aks_kubelet_uai_nodes_rg_contributor" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.aks.node_resource_group)
  role_definition_name = "Contributor"
}

# Allow Kubelet Identity to authenticate with Azure Container Registry (ACR)
resource "azurerm_role_assignment" "aks_kubelet_uai_acr_pull" {
  count = length(var.container_registries_ids)

  scope                = var.container_registries_ids[count.index]
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
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
  principal_id         = data.azuread_service_principal.aci_identity[0].id
  role_definition_name = "Network Contributor"
}
