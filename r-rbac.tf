resource "azurerm_user_assigned_identity" "main" {
  count    = var.user_assigned_identity != null ? 0 : 1
  name     = local.identity_name
  location = var.location

  resource_group_name = coalesce(var.user_assigned_identity_resource_group_name, var.resource_group_name)

  tags = local.uai_tags
}

moved {
  from = azurerm_user_assigned_identity.aks_user_assigned_identity
  to   = azurerm_user_assigned_identity.main[0]
}

moved {
  from = azurerm_user_assigned_identity.main
  to   = azurerm_user_assigned_identity.main[0]
}

resource "azurerm_role_assignment" "uai_private_dns_zone_contributor" {
  count                = var.user_assigned_identity_role_assignment_enabled && local.is_custom_dns_private_cluster && var.private_dns_zone_role_assignment_enabled ? 1 : 0
  scope                = var.private_dns_zone_id
  principal_id         = azurerm_user_assigned_identity.main[0].principal_id
  role_definition_name = "Private DNS Zone Contributor"
}

resource "azurerm_role_assignment" "uai_subnets_network_contributor" {
  for_each             = var.user_assigned_identity_role_assignment_enabled && var.private_dns_zone_type != "Custom" ? toset(local.subnet_ids) : []
  scope                = each.key
  principal_id         = azurerm_user_assigned_identity.main[0].principal_id
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "uai_vnet_network_contributor" {
  for_each             = var.user_assigned_identity_role_assignment_enabled && var.private_dns_zone_type == "Custom" ? toset(local.vnet_ids) : []
  scope                = each.key
  principal_id         = azurerm_user_assigned_identity.main[0].principal_id
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "uai_route_table_contributor" {
  count                = var.user_assigned_identity_role_assignment_enabled && local.is_kubenet && var.outbound_type == "userDefinedRouting" ? 1 : 0
  scope                = var.route_table_id
  principal_id         = azurerm_user_assigned_identity.main[0].principal_id
  role_definition_name = "Contributor"
}

# Allow Kubelet Identity to manage AKS items in nodes RG
resource "azurerm_role_assignment" "kubelet_uai_nodes_rg_contributor" {
  count                = var.user_assigned_identity_role_assignment_enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.main.node_resource_group)
  role_definition_name = "Contributor"
}

moved {
  from = azurerm_role_assignment.kubelet_uai_nodes_rg_contributor
  to   = azurerm_role_assignment.kubelet_uai_nodes_rg_contributor[0]
}

# Allow Kubelet Identity to authenticate with Azure Container Registry (ACR)
resource "azurerm_role_assignment" "kubelet_uai_acr_pull" {
  count = var.user_assigned_identity_role_assignment_enabled ? length(var.container_registry_id[*]) : 0

  scope                = var.container_registry_id
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"

  lifecycle {
    create_before_destroy = true
  }
}

# Role assignment for ACI, if ACI is enabled
data "azuread_service_principal" "aci_identity" {
  count = length(var.aci_subnet[*])

  display_name = "aciconnectorlinux-${local.name}"
  depends_on   = [azurerm_kubernetes_cluster.main]
}

resource "azurerm_role_assignment" "aci_assignment" {
  count = length(var.aci_subnet[*])

  scope                = var.aci_subnet.id
  principal_id         = data.azuread_service_principal.aci_identity[0].id
  role_definition_name = "Network Contributor"
}
