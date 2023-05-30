locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  aks_name          = coalesce(var.custom_aks_name, data.azurecaf_name.aks.result)
  aks_identity_name = coalesce(var.aks_user_assigned_identity_custom_name, data.azurecaf_name.aks_identity.result)

  aks_node_rg_name = coalesce(var.nodes_resource_group_name, data.azurecaf_name.aks_node_rg.result)
}
