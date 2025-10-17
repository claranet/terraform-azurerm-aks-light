data "azurecaf_name" "aks" {
  name          = var.stack
  resource_type = "azurerm_kubernetes_cluster"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix])
  use_slug      = true
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "aks_identity" {
  count         = var.user_assigned_identity != null ? 0 : 1
  name          = var.stack
  resource_type = "azurerm_user_assigned_identity"
  prefixes      = compact(["aks", local.name_prefix])
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix])
  use_slug      = true
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "aks_nodes_rg" {
  name          = local.name
  resource_type = "azurerm_resource_group"
  suffixes      = ["nodes"]
  use_slug      = true
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "dcr" {
  name          = var.stack
  resource_type = "azurerm_resource_group"
  prefixes      = compact([local.name_prefix, "dcr"])
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix])
  use_slug      = false
  clean_input   = true
  separator     = "-"
}
