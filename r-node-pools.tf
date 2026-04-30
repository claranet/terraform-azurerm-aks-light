resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each = {
    for np in local.node_pools : np.name => np
  }

  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id

  name                 = each.value.name
  vm_size              = each.value.vm_size
  os_disk_type         = each.value.os_disk_type
  kubelet_disk_type    = each.value.kubelet_disk_type
  auto_scaling_enabled = each.value.auto_scaling_enabled
  node_count           = each.value.auto_scaling_enabled ? null : each.value.node_count
  min_count            = each.value.auto_scaling_enabled ? each.value.min_count : null
  max_count            = each.value.auto_scaling_enabled ? each.value.max_count : null
  node_labels          = each.value.node_labels
  node_taints          = each.value.node_taints

  gpu_instance = each.value.gpu_instance
  gpu_driver   = each.value.gpu_driver

  workload_runtime  = each.value.workload_runtime
  mode              = each.value.mode
  scale_down_mode   = each.value.scale_down_mode
  ultra_ssd_enabled = each.value.ultra_ssd_enabled
  spot_max_price    = each.value.spot_max_price

  host_encryption_enabled     = each.value.host_encryption_enabled
  node_public_ip_enabled      = each.value.node_public_ip_enabled
  vnet_subnet_id              = each.value.vnet_subnet_id
  pod_subnet_id               = each.value.pod_subnet_id
  priority                    = each.value.priority
  eviction_policy             = each.value.eviction_policy
  orchestrator_version        = each.value.orchestrator_version
  fips_enabled                = each.value.fips_enabled
  temporary_name_for_rotation = coalesce(each.value.temporary_name_for_rotation, format("%stmp", substr(each.value.name, 0, 9)))
  zones                       = each.value.zones

  dynamic "upgrade_settings" {
    for_each = each.value.upgrade_settings[*]
    content {
      drain_timeout_in_minutes      = upgrade_settings.value.drain_timeout_in_minutes
      node_soak_duration_in_minutes = upgrade_settings.value.node_soak_duration_in_minutes
      max_surge                     = upgrade_settings.value.max_surge
      max_unavailable               = upgrade_settings.value.max_unavailable
      undrainable_node_behavior     = upgrade_settings.value.undrainable_node_behavior
    }
  }

  os_sku          = each.value.os_sku
  os_type         = can(regex("^Windows", each.value.os_sku)) ? "Windows" : "Linux"
  os_disk_size_gb = coalesce(each.value.os_disk_size_gb, can(regex("^Windows", each.value.os_sku)) ? local.default_node_profile["windows"].os_disk_size_gb : local.default_node_profile["linux"].os_disk_size_gb)
  max_pods        = coalesce(each.value.max_pods, can(regex("^Windows", each.value.os_sku)) ? local.default_node_profile["windows"].max_pods : local.default_node_profile["linux"].max_pods)

  dynamic "kubelet_config" {
    for_each = each.value.kubelet_config[*]
    content {
      allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
      container_log_max_line    = kubelet_config.value.container_log_max_line
      container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
      cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
      cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
      cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
      image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
      image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
      pod_max_pid               = kubelet_config.value.pod_max_pid
      topology_manager_policy   = kubelet_config.value.topology_manager_policy
    }
  }

  dynamic "node_network_profile" {
    for_each = each.value.node_network_profile[*]
    content {
      dynamic "allowed_host_ports" {
        for_each = node_network_profile.value.allowed_host_ports != null ? node_network_profile.value.allowed_host_ports : []
        content {
          port_start = allowed_host_ports.value.port_start
          port_end   = allowed_host_ports.value.port_end
          protocol   = allowed_host_ports.value.protocol
        }
      }
      application_security_group_ids = node_network_profile.value.application_security_group_ids
      node_public_ip_tags            = node_network_profile.value.node_public_ip_tags
    }
  }

  dynamic "windows_profile" {
    for_each = each.value.windows_profile[*]
    content {
      outbound_nat_enabled = windows_profile.value.outbound_nat_enabled
    }
  }

  dynamic "linux_os_config" {
    for_each = each.value.linux_os_config[*]
    content {
      swap_file_size_mb            = linux_os_config.value.swap_file_size_mb
      transparent_huge_page        = linux_os_config.value.transparent_huge_page
      transparent_huge_page_defrag = linux_os_config.value.transparent_huge_page_defrag
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

  tags = merge(local.default_tags, var.extra_tags, each.value.tags)
}

moved {
  from = azurerm_kubernetes_cluster_node_pool.node_pools
  to   = azurerm_kubernetes_cluster_node_pool.main
}
