resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each = {
    for np in local.node_pools : np.name => np
  }

  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id

  name                   = each.value.name
  vm_size                = each.value.vm_size
  os_disk_type           = each.value.os_disk_type
  enable_auto_scaling    = each.value.enable_auto_scaling
  node_count             = each.value.enable_auto_scaling ? null : each.value.node_count
  min_count              = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count              = each.value.enable_auto_scaling ? each.value.max_count : null
  node_labels            = each.value.node_labels
  node_taints            = each.value.node_taints
  enable_host_encryption = each.value.enable_host_encryption
  enable_node_public_ip  = each.value.enable_node_public_ip
  vnet_subnet_id         = each.value.vnet_subnet_id
  pod_subnet_id          = each.value.pod_subnet_id
  priority               = each.value.priority
  eviction_policy        = each.value.eviction_policy
  orchestrator_version   = each.value.orchestrator_version
  zones                  = each.value.zones
  upgrade_settings {
    max_surge = each.value.upgrade_settings.max_surge
  }

  os_sku          = each.value.os_sku
  os_type         = can(regex("^Windows", each.value.os_sku)) ? "Windows" : "Linux"
  os_disk_size_gb = coalesce(each.value.os_disk_size_gb, can(regex("^Windows", each.value.os_sku)) ? local.default_node_profile["windows"].os_disk_size_gb : local.default_node_profile["linux"].os_disk_size_gb)
  max_pods        = coalesce(each.value.max_pods, can(regex("^Windows", each.value.os_sku)) ? local.default_node_profile["windows"].max_pods : local.default_node_profile["linux"].max_pods)

  dynamic "linux_os_config" {
    for_each = each.value.linux_os_config[*]
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

  tags = merge(local.default_tags, var.extra_tags, each.value.tags)
}

moved {
  from = azurerm_kubernetes_cluster_node_pool.node_pools
  to   = azurerm_kubernetes_cluster_node_pool.main
}
