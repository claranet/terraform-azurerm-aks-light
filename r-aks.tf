#tfsec:ignore:azure-container-use-rbac-permissions
#tfsec:ignore:azure-container-limit-authorized-ips
#tfsec:ignore:azure-container-logging
resource "azurerm_kubernetes_cluster" "main" {
  name     = local.name
  location = var.location

  resource_group_name = var.resource_group_name

  dns_prefix = replace(local.name, "/[\\W_]/", "-")

  # Cluster config
  kubernetes_version               = coalesce(var.kubernetes_version, data.azurerm_kubernetes_service_versions.main.latest_version)
  automatic_upgrade_channel        = var.automatic_upgrade_channel
  sku_tier                         = var.sku_tier
  node_resource_group              = local.nodes_rg_name
  http_application_routing_enabled = var.http_application_routing_enabled
  oidc_issuer_enabled              = var.oidc_issuer_enabled
  workload_identity_enabled        = var.workload_identity_enabled

  # Network config
  private_cluster_enabled             = var.private_cluster_enabled
  private_cluster_public_fqdn_enabled = var.private_cluster_enabled == true ? var.private_cluster_public_fqdn_enabled : null
  private_dns_zone_id                 = var.private_cluster_enabled ? local.private_dns_zone : null

  image_cleaner_enabled        = var.image_cleaner_configuration.enabled
  image_cleaner_interval_hours = var.image_cleaner_configuration.interval_hours

  dynamic "api_server_access_profile" {
    for_each = !var.private_cluster_enabled ? [0] : []
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  network_profile {
    network_plugin      = var.network_plugin.name
    network_plugin_mode = local.is_network_cni && lower(var.network_plugin.cni_mode) == "overlay" ? "overlay" : null
    network_policy      = var.network_policy
    network_mode        = local.is_network_cni ? var.network_mode : null
    dns_service_ip      = cidrhost(var.service_cidr, 10)
    service_cidr        = var.service_cidr
    outbound_type       = var.outbound_type
    pod_cidr            = var.pod_cidr
    load_balancer_sku   = "standard"
  }

  dynamic "http_proxy_config" {
    for_each = var.http_proxy_settings[*]
    content {
      https_proxy = http_proxy_config.value.https_proxy_url
      http_proxy  = http_proxy_config.value.http_proxy_url
      trusted_ca  = http_proxy_config.value.trusted_ca
      no_proxy = distinct(compact(concat(
        local.default_no_proxy_list,
        http_proxy_config.value.no_proxy_list,
      )))
    }
  }

  # Azure integration config
  azure_policy_enabled  = var.azure_policy_enabled
  cost_analysis_enabled = var.cost_analysis_enabled

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  dynamic "oms_agent" {
    for_each = var.oms_agent[*]
    content {
      log_analytics_workspace_id      = coalesce(oms_agent.value.log_analytics_workspace_id, local.default_log_analytics)
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
    for_each = var.aci_subnet != null && var.network_plugin != "kubenet" ? [true] : []
    content {
      subnet_name = local.parsed_aci_subnet_id.name
    }
  }

  # Default Node Pool config
  default_node_pool {
    name                        = local.default_node_pool.name
    type                        = local.default_node_pool.type
    vm_size                     = local.default_node_pool.vm_size
    os_disk_type                = local.default_node_pool.os_disk_type
    auto_scaling_enabled        = local.default_node_pool.auto_scaling_enabled
    node_count                  = local.default_node_pool.auto_scaling_enabled ? null : local.default_node_pool.node_count
    min_count                   = local.default_node_pool.auto_scaling_enabled ? local.default_node_pool.min_count : null
    max_count                   = local.default_node_pool.auto_scaling_enabled ? local.default_node_pool.max_count : null
    node_labels                 = local.default_node_pool.node_labels
    host_encryption_enabled     = local.default_node_pool.host_encryption_enabled
    node_public_ip_enabled      = local.default_node_pool.node_public_ip_enabled
    vnet_subnet_id              = local.default_node_pool.vnet_subnet_id
    pod_subnet_id               = local.default_node_pool.pod_subnet_id
    orchestrator_version        = local.default_node_pool.orchestrator_version
    zones                       = local.default_node_pool.zones
    tags                        = local.default_node_pool_tags
    temporary_name_for_rotation = coalesce(local.default_node_pool.temporary_name_for_rotation, format("%stmp", substr(local.default_node_pool.name, 0, 9)))
    upgrade_settings {
      max_surge = local.default_node_pool.upgrade_settings.max_surge
    }

    dynamic "linux_os_config" {
      for_each = local.default_node_pool.linux_os_config[*]
      content {
        swap_file_size_mb             = linux_os_config.value.swap_file_size_mb
        transparent_huge_page_enabled = linux_os_config.value.transparent_huge_page_enabled
        transparent_huge_page_defrag  = linux_os_config.value.transparent_huge_page_defrag
        dynamic "sysctl_config" {
          for_each = linux_os_config.value.sysctl_config[*]
          content {
            fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
            fs_file_max                        = sysctl_config.value.fs_file_max
            fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
            fs_nr_open                         = sysctl_config.value.fs_nr_open
            kernel_threads_max                 = sysctl_config.value.kernel_threads_max
            net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
            net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
            net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
            net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
            net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
            net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
            net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
            net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
            net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
            net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
            net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
            net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
            net_ipv4_tcp_fin_timeout           = sysctl_config.value.net_ipv4_tcp_fin_timeout
            net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
            net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
            net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
            net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
            net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
            net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
            net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
            net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
            vm_max_map_count                   = sysctl_config.value.vm_max_map_count
            vm_swappiness                      = sysctl_config.value.vm_swappiness
            vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
          }
        }
      }
    }

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

  dynamic "storage_profile" {
    for_each = var.storage_profile[*]
    content {
      blob_driver_enabled         = var.storage_profile.blob_driver_enabled
      disk_driver_enabled         = var.storage_profile.disk_driver_enabled
      file_driver_enabled         = var.storage_profile.file_driver_enabled
      snapshot_controller_enabled = var.storage_profile.snapshot_controller_enabled
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_active_directory_rbac[*]
    content {
      tenant_id              = var.azure_active_directory_rbac.service_principal_azure_tenant_id
      admin_group_object_ids = var.azure_active_directory_rbac.admin_group_object_ids
      azure_rbac_enabled     = var.azure_active_directory_rbac.azure_rbac_enabled
    }
  }

  dynamic "monitor_metrics" {
    for_each = var.monitor_metrics[*]
    content {
      annotations_allowed = var.monitor_metrics.annotations_allowed
      labels_allowed      = var.monitor_metrics.labels_allowed
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window[*]
    content {
      dynamic "allowed" {
        for_each = maintenance_window.value.allowed[*]
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }
      dynamic "not_allowed" {
        for_each = maintenance_window.value.not_allowed[*]
        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }

  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.maintenance_window_auto_upgrade[*]
    content {
      frequency    = maintenance_window_auto_upgrade.value.frequency
      interval     = maintenance_window_auto_upgrade.value.interval
      duration     = maintenance_window_auto_upgrade.value.duration
      day_of_week  = maintenance_window_auto_upgrade.value.day_of_week
      day_of_month = maintenance_window_auto_upgrade.value.day_of_month
      week_index   = maintenance_window_auto_upgrade.value.week_index
      start_time   = maintenance_window_auto_upgrade.value.start_time
      utc_offset   = maintenance_window_auto_upgrade.value.utc_offset
      start_date   = maintenance_window_auto_upgrade.value.start_date
      dynamic "not_allowed" {
        for_each = maintenance_window_auto_upgrade.value.not_allowed[*]
        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender[*]
    content {
      log_analytics_workspace_id = microsoft_defender.value.log_analytics_workspace_id
    }
  }

  tags = merge(local.default_tags, var.extra_tags)

  depends_on = [
    azurerm_role_assignment.uai_private_dns_zone_contributor,
  ]

  lifecycle {
    ignore_changes = [kubernetes_version]

    precondition {
      condition     = !var.workload_identity_enabled || var.oidc_issuer_enabled
      error_message = "var.oidc_issuer_enabled must be true when Workload Identity is enabled."
    }
    precondition {
      condition     = local.is_network_cni && lower(var.network_plugin.cni_mode) == "cilium" ? var.pods_subnet != {} : true
      error_message = "var.pods_subnet must be set when using Azure CNI Cilium network."
    }
    precondition {
      condition     = try(data.azapi_resource.subnet_delegation[0].output.properties.delegations[0].properties.serviceName, null) == "Microsoft.ContainerInstance/containerGroups" || var.aci_subnet == null
      error_message = "ACI subnet should be delegated to Microsoft.ContainerInstance/containerGroups"
    }

    precondition {
      condition = var.azure_active_directory_rbac == null || try(alltrue([
        var.azure_active_directory_rbac.azure_rbac_enabled,
        length(var.azure_active_directory_rbac.admin_group_object_ids) > 0,
      ]), false)
      error_message = "Please specify `admin_group_object_ids` when `azure_rbac_enabled = true`."
    }
  }
}

moved {
  from = azurerm_kubernetes_cluster.aks
  to   = azurerm_kubernetes_cluster.main
}

# Taken from https://github.com/Azure/terraform-azurerm-aks
resource "null_resource" "kubernetes_version_keeper" {
  triggers = {
    version = var.kubernetes_version
  }
}

resource "azapi_update_resource" "aks_kubernetes_version" {
  type        = "Microsoft.ContainerService/managedClusters@2024-10-02-preview"
  resource_id = azurerm_kubernetes_cluster.main.id

  body = {
    properties = {
      kubernetesVersion = coalesce(var.kubernetes_version, data.azurerm_kubernetes_service_versions.main.latest_version)
    }
  }

  depends_on = [
    azurerm_kubernetes_cluster_node_pool.main,
  ]

  lifecycle {
    ignore_changes       = all
    replace_triggered_by = [null_resource.kubernetes_version_keeper.id]
  }
}
