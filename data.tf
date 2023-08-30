data "azurerm_subscription" "current" {}

data "azurerm_kubernetes_service_versions" "versions" {
  location        = var.location
  include_preview = false
}
