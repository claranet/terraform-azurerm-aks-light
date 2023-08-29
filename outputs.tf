output "aks" {
  description = "AKS output object."
  value       = azurerm_kubernetes_cluster.aks
}

output "identity_principal_id" {
  description = "AKS System Managed Identity principal ID."
  value       = try(azurerm_kubernetes_cluster.aks.identity[0].principal_id, null)
}

output "id" {
  description = "ID of the Azure Kubernetes Service."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "name" {
  description = "Name of the Azure Kubernetes Service."
  value       = local.aks_name
}

output "nodes_resource_group_name" {
  description = "Name of the Resource Group in which Azure Kubernetes Service nodes are deployed."
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "portal_fqdn" {
  description = "Portal FQDN of the Azure Kubernetes Service."
  value       = azurerm_kubernetes_cluster.aks.portal_fqdn
}

output "public_fqdn" {
  description = "Public FQDN of the Azure Kubernetes Service."
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "private_fqdn" {
  description = "Private FQDNs of the Azure Kubernetes Service."
  value       = azurerm_kubernetes_cluster.aks.private_fqdn
}

output "kubernetes_version" {
  description = "Azure Kubernetes Service Kubernetes version."
  value       = azurerm_kubernetes_cluster.aks.kubernetes_version
}

output "node_pools" {
  description = "Map of Azure Kubernetes Service Node Pools attributes."
  value = {
    for np in azurerm_kubernetes_cluster_node_pool.node_pools : np.name => np
  }
}

output "kube_config_raw" {
  description = "Raw kubeconfig to be used by kubectl command."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kube_config" {
  description = "Kube configuration of the Azure Kubernetes Service."
  value       = azurerm_kubernetes_cluster.aks.kube_config
  sensitive   = true
}

output "user_managed_identity" {
  description = "The User Managed Identity used by the Azure Kubernetes Service."
  value       = azurerm_user_assigned_identity.aks_user_assigned_identity
}

output "kubelet_user_managed_identity" {
  description = "The Kubelet User Managed Identity used by the Azure Kubernetes Service."
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0]
}

output "key_vault_secrets_provider_identity" {
  description = "The User Managed Identity used by the Key Vault secrets provider."
  value       = try(azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0], null)
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the Azure Kubernetes Service."
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "managed_private_dns_zone_id" {
  description = "ID of the AKS' managed Private DNS Zone."
  value       = local.managed_private_dns_zone_id
}

output "managed_private_dns_zone_name" {
  description = "Name of the AKS' managed Private DNS Zone."
  value       = local.managed_private_dns_zone_name
}

output "managed_private_dns_zone_resource_group_name" {
  description = "Resource Group name of the AKS' managed Private DNS Zone."
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}
