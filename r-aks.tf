#tfsec:ignore:azure-container-use-rbac-permissions
#tfsec:ignore:azure-container-limit-authorized-ips
#tfsec:ignore:azure-container-logging
resource "azurerm_kubernetes_cluster" "aks" {
  name     = local.aks_name
  location = var.location

  resource_group_name = var.resource_group_name

  dns_prefix = replace(local.aks_name, "/[\\W_]/", "-")

  # Cluster config
  kubernetes_version               = coalesce(var.kubernetes_version, data.azurerm_kubernetes_service_versions.versions.latest_version)
  sku_tier                         = var.aks_sku_tier
  node_resource_group              = local.aks_nodes_rg_name
  http_application_routing_enabled = var.http_application_routing_enabled
  oidc_issuer_enabled              = var.oidc_issuer_enabled
  workload_identity_enabled        = var.workload_identity_enabled

  # Network config
  private_cluster_enabled             = var.private_cluster_enabled
  private_cluster_public_fqdn_enabled = var.private_cluster_enabled == true ? var.private_cluster_public_fqdn_enabled : null
  private_dns_zone_id                 = var.private_cluster_enabled ? local.private_dns_zone : null

  api_server_access_profile {
    authorized_ip_ranges     = var.private_cluster_enabled ? null : var.api_server_authorized_ip_ranges
    vnet_integration_enabled = var.vnet_integration.enabled
    subnet_id                = var.vnet_integration.subnet_id
  }

  network_profile {
    network_plugin      = var.aks_network_plugin.name
    network_plugin_mode = local.is_network_cni && lower(var.aks_network_plugin.cni_mode) == "overlay" ? "overlay" : null
    network_policy      = var.aks_network_policy
    network_mode        = local.is_network_cni ? var.aks_network_mode : null
    dns_service_ip      = cidrhost(var.service_cidr, 10)
    service_cidr        = var.service_cidr
    outbound_type       = var.outbound_type
    pod_cidr            = var.aks_pod_cidr
    ebpf_data_plane     = local.is_network_cni && lower(var.aks_network_plugin.cni_mode) == "cilium" ? "cilium" : null
    load_balancer_sku   = "standard"
  }

  dynamic "http_proxy_config" {
    for_each = var.aks_http_proxy_settings[*]
    content {
      https_proxy = http_proxy_config.value.https_proxy_url
      http_proxy  = http_proxy_config.value.http_proxy_url
      trusted_ca  = http_proxy_config.value.trusted_ca
      no_proxy = distinct(concat(
        local.default_no_proxy_list,
        http_proxy_config.value.no_proxy_list,
      ))
    }
  }

  # Azure integration config
  azure_policy_enabled = var.azure_policy_enabled

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_user_assigned_identity.id]
  }

  dynamic "oms_agent" {
    for_each = var.oms_agent[*]
    content {
      log_analytics_workspace_id      = oms_agent.value.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = oms_agent.value.msi_auth_for_monitoring_enabled
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider[*]
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }

  dynamic "aci_connector_linux" {
    for_each = var.aci_subnet_id != null && var.aks_network_plugin != "kubenet" ? [true] : []
    content {
      subnet_name = element(split("/", var.aci_subnet_id), length(split("/", var.aci_subnet_id)) - 1)
    }
  }

  # Default Node Pool config
  default_node_pool {
    name                   = local.default_node_pool.name
    type                   = local.default_node_pool.type
    vm_size                = local.default_node_pool.vm_size
    os_disk_type           = local.default_node_pool.os_disk_type
    enable_auto_scaling    = local.default_node_pool.enable_auto_scaling
    node_count             = local.default_node_pool.enable_auto_scaling ? null : local.default_node_pool.node_count
    min_count              = local.default_node_pool.enable_auto_scaling ? local.default_node_pool.min_count : null
    max_count              = local.default_node_pool.enable_auto_scaling ? local.default_node_pool.max_count : null
    node_labels            = local.default_node_pool.node_labels
    node_taints            = local.default_node_pool.node_taints
    enable_host_encryption = local.default_node_pool.enable_host_encryption
    enable_node_public_ip  = local.default_node_pool.enable_node_public_ip
    vnet_subnet_id         = local.default_node_pool.vnet_subnet_id
    pod_subnet_id          = local.default_node_pool.pod_subnet_id
    orchestrator_version   = local.default_node_pool.orchestrator_version
    zones                  = local.default_node_pool.zones
    tags                   = local.default_node_pool_tags

    os_sku          = local.default_node_pool.os_sku
    os_disk_size_gb = coalesce(local.default_node_pool.os_disk_size_gb, can(regex("^Windows", local.default_node_pool.os_sku)) ? local.default_node_profile["windows"].os_disk_size_gb : local.default_node_profile["linux"].os_disk_size_gb)
    max_pods        = coalesce(local.default_node_pool.max_pods, can(regex("^Windows", local.default_node_pool.os_sku)) ? local.default_node_profile["windows"].max_pods : local.default_node_profile["linux"].max_pods)
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile[*]
    content {
      balance_similar_node_groups      = auto_scaler_profile.value.balance_similar_node_groups
      expander                         = auto_scaler_profile.value.expander
      max_graceful_termination_sec     = auto_scaler_profile.value.max_graceful_termination_sec
      max_node_provisioning_time       = auto_scaler_profile.value.max_node_provisioning_time
      max_unready_nodes                = auto_scaler_profile.value.max_unready_nodes
      max_unready_percentage           = auto_scaler_profile.value.max_unready_percentage
      new_pod_scale_up_delay           = auto_scaler_profile.value.new_pod_scale_up_delay
      scale_down_delay_after_add       = auto_scaler_profile.value.scale_down_delay_after_add
      scale_down_delay_after_delete    = auto_scaler_profile.value.scale_down_delay_after_delete
      scale_down_delay_after_failure   = auto_scaler_profile.value.scale_down_delay_after_failure
      scan_interval                    = auto_scaler_profile.value.scan_interval
      scale_down_unneeded              = auto_scaler_profile.value.scale_down_unneeded
      scale_down_unready               = auto_scaler_profile.value.scale_down_unready
      scale_down_utilization_threshold = auto_scaler_profile.value.scale_down_utilization_threshold
      empty_bulk_delete_max            = auto_scaler_profile.value.empty_bulk_delete_max
      skip_nodes_with_local_storage    = auto_scaler_profile.value.skip_nodes_with_local_storage
      skip_nodes_with_system_pods      = auto_scaler_profile.value.skip_nodes_with_system_pods
    }
  }

  dynamic "linux_profile" {
    for_each = var.linux_profile[*]
    content {
      admin_username = linux_profile.value.username
      ssh_key {
        key_data = linux_profile.value.ssh_key
      }
    }
  }

  tags = merge(local.default_tags, var.extra_tags)

  depends_on = [
    azurerm_role_assignment.aks_uai_private_dns_zone_contributor,
  ]

  lifecycle {
    ignore_changes = [kubernetes_version]

    precondition {
      condition     = !var.workload_identity_enabled || var.oidc_issuer_enabled
      error_message = "var.oidc_issuer_enabled must be true when Workload Identity is enabled."
    }
    precondition {
      condition     = local.is_network_cni && lower(var.aks_network_plugin.cni_mode) == "cilium" ? var.pods_subnet != {} : true
      error_message = "var.pods_subnet must be set when using Azure CNI Cilium network."
    }
  }
}

# Taken from https://github.com/Azure/terraform-azurerm-aks
resource "null_resource" "kubernetes_version_keeper" {
  triggers = {
    version = var.kubernetes_version
  }
}

resource "azapi_update_resource" "aks_kubernetes_version" {
  type        = "Microsoft.ContainerService/managedClusters@2023-01-02-preview"
  resource_id = azurerm_kubernetes_cluster.aks.id

  body = jsonencode({
    properties = {
      kubernetesVersion = coalesce(var.kubernetes_version, data.azurerm_kubernetes_service_versions.versions.latest_version)
    }
  })

  depends_on = [
    azurerm_kubernetes_cluster_node_pool.node_pools,
  ]

  lifecycle {
    ignore_changes       = all
    replace_triggered_by = [null_resource.kubernetes_version_keeper.id]
  }
}
