locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  aks_light_name = coalesce(var.custom_name, data.azurecaf_name.aks_light.result)
}
