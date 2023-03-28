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

output "aks_id" {
  description = "AKS resource id"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_name" {
  description = "Name of the AKS cluster"
  value       = local.aks_name
}

output "aks_nodes_rg" {
  description = "Name of the resource group in which AKS nodes are deployed"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "aks_nodes_pools_ids" {
  description = "Ids of AKS nodes pools"
  value       = azurerm_kubernetes_cluster_node_pool.node_pools[*].id
}

output "aks_nodes_pools_names" {
  description = "Names of AKS nodes pools"
  value       = azurerm_kubernetes_cluster_node_pool.node_pools[*].name
}

output "aks_kube_config_raw" {
  description = "Raw kube config to be used by kubectl command"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "aks_kube_config" {
  description = "Kube configuration of AKS Cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config
  sensitive   = true
}

output "aks_user_managed_identity" {
  value       = azurerm_user_assigned_identity.aks_user_assigned_identity
  description = "The User Managed Identity used by the AKS cluster."
}

output "aks_kubelet_user_managed_identity" {
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0]
  description = "The Kubelet User Managed Identity used by the AKS cluster."
}


output "aks_key_vault_secrets_provider_identity" {
  description = "The User Managed Identity used by the Key Vault secrets provider."
  value       = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0]
}

output "aks_oidc_issuer_url" {
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  description = "The OIDC issuer URL that is associated with the cluster."
}
