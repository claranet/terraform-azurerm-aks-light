output "aks_light" {
  description = "AKS output object"
  value       = azurerm_kubernetes_cluster.aks_light
}

output "id" {
  description = "AKS ID"
  value       = azurerm_kubernetes_cluster.aks_light.id
}

output "name" {
  description = "AKS name"
  value       = azurerm_kubernetes_cluster.aks_light.name
}

output "identity_principal_id" {
  description = "AKS system identity principal ID"
  value       = try(azurerm_kubernetes_cluster.aks_light.identity[0].principal_id, null)
}
