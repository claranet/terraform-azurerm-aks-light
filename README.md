# Azure Kubernetes Service
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-blue.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![OpenTofu Registry](https://img.shields.io/badge/opentofu-registry-yellow.svg)](https://search.opentofu.org/module/claranet/aks-light/azurerm/)

This Terraform module creates an [Azure Kubernetes Service](https://azure.microsoft.com/fr-fr/services/kubernetes-service/).

Non-exhaustive feature list, most of them can be overridden:

* Cluster created with [User Assigned identity](https://learn.microsoft.com/en-us/azure/aks/use-managed-identity#bring-your-own-control-plane-managed-identity), and related role assignments are managed, for better dependencies lifecycle management
* Default [latest stable Kubernetes version](https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#aks-kubernetes-release-calendar) used at creation
* [Cluster and containers logs](https://learn.microsoft.com/en-us/azure/aks/monitor-aks) sent to Log Analytics Workspace or Storage Account
* Kube audit logs disabled by default for cost purpose
* Cluster is [private](https://learn.microsoft.com/en-us/azure/aks/private-clusters) by default
* [Virtual Network integration](https://learn.microsoft.com/en-US/azure/aks/api-server-vnet-integration)
* Azure CNI Overlay network mode by default, support for Azure CNI, Cilium & Kubelet. More in the [Azure documentation](https://learn.microsoft.com/en-us/azure/aks/concepts-network#azure-virtual-networks)
* [Azure CSI KeyVault](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-identity-access) enabled by default
* [Azure Policies](https://learn.microsoft.com/en-us/azure/aks/use-azure-policy) enabled by default
* [Calico network policy](https://learn.microsoft.com/en-us/azure/aks/use-network-policies) enabled by default
* [Workload identities](https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity) enabled by default
* Additional node pools can be configured within the module
* Azure naming convention for all resources
* [Container Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview) enabled by default

# Why replacing the previous Claranet AKS module

This modules supersedes the previous [AKS module](https://search.opentofu.org/module/claranet/aks/azurerm).
We've built a new module to clean up the technical debt that piled up due to fast-moving AKS product and keep backwards
compatibility for existing users. Also, we've decided to remove all Kubernetes resources from this new module as a
[recommended best practice](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources)
and for better tooling responsibility segregation.

So this module does less, that why `light`, but it should do it better.

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | OpenTofu version | AzureRM version |
| -------------- | ----------------- | ---------------- | --------------- |
| >= 8.x.x       | **Unverified**    | 1.8.x            | >= 4.0          |
| >= 7.x.x       | 1.3.x             |                  | >= 3.0          |
| >= 6.x.x       | 1.x               |                  | >= 3.0          |
| >= 5.x.x       | 0.15.x            |                  | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   |                  | >= 2.0          |
| >= 3.x.x       | 0.12.x            |                  | >= 2.0          |
| >= 2.x.x       | 0.12.x            |                  | < 2.0           |
| <  2.x.x       | 0.11.x            |                  | < 2.0           |

## Contributing

If you want to contribute to this repository, feel free to use our [pre-commit](https://pre-commit.com/) git hook configuration
which will help you automatically update and format some files for you by enforcing our Terraform code module best-practices.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

⚠️ Since modules version v8.0.0, we do not maintain/check anymore the compatibility with
[Hashicorp Terraform](https://github.com/hashicorp/terraform/). Instead, we recommend to use [OpenTofu](https://github.com/opentofu/opentofu/).

```hcl
module "acr" {
  source  = "claranet/acr/azurerm"
  version = "x.x.x"

  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  resource_group_name = module.rg.name

  sku = "Standard"

  logs_destinations_ids = [module.run.log_analytics_workspace_id]
}

module "vnet" {
  source  = "claranet/vnet/azurerm"
  version = "x.x.x"

  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  resource_group_name = module.rg.name

  cidrs = ["10.0.0.0/19"]
}

module "nodes_subnet" {
  source  = "claranet/subnet/azurerm"
  version = "x.x.x"

  location_short      = module.azure_region.location_short
  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  resource_group_name = module.rg.name

  name_suffix = "nodes"

  virtual_network_name = module.vnet.name

  cidrs             = ["10.0.0.0/20"]
  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

module "private_dns_zone" {
  source  = "claranet/private-endpoint/azurerm//modules/private-dns-zone"
  version = "x.x.x"

  environment         = var.environment
  stack               = var.stack
  resource_group_name = module.rg.name

  name                = "privatelink.${module.azure_region.location_cli}.azmk8s.io"
  virtual_network_ids = [module.vnet.id]
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
}

module "containers_logs" {
  source  = "claranet/run/azurerm//modules/logs"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  stack               = var.stack
  resource_group_name = module.rg.name

  storage_account_enabled = true
  workspace_custom_name   = "log-aks-containers-${var.environment}-${module.azure_region.location_short}"
}

module "aks" {
  source  = "claranet/aks-light/azurerm"
  version = "x.x.x"

  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  resource_group_name = module.rg.name

  kubernetes_version = "1.30.4"
  service_cidr       = "10.0.16.0/22"

  nodes_subnet = {
    name                 = module.nodes_subnet.name
    virtual_network_name = module.vnet.name
  }

  private_cluster_enabled = true
  private_dns_zone_type   = "Custom"
  private_dns_zone_id     = module.private_dns_zone.id

  default_node_pool = {
    vm_size         = "Standard_B4ms"
    os_disk_size_gb = 64
  }

  node_pools = [
    {
      name                = "nodepool1"
      vm_size             = "Standard_B4ms"
      os_disk_type        = "Ephemeral"
      os_disk_size_gb     = 100
      vnet_subnet_id      = module.nodes_subnet.id
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 10
    }
  ]

  linux_profile = {
    username = "nodeadmin"
    ssh_key  = tls_private_key.main.public_key_openssh
  }

  container_registry_id = module.acr.id

  oms_agent = {
    log_analytics_workspace_id = module.run.log_analytics_workspace_id
  }

  data_collection_rule = {
    custom_log_analytics_workspace_id = module.containers_logs.id
  }

  maintenance_window = {
    allowed = [{
      day   = "Monday"
      hours = [10, 11, 12, 13, 14]
    }]
  }

  maintenance_window_auto_upgrade = {
    frequency   = "RelativeMonthly"
    interval    = 1
    duration    = 4
    week_index  = "First"
    day_of_week = "Monday"
    start_time  = "10:00"
    utc_offset  = "+02:00"
  }

  logs_destinations_ids = [module.run.log_analytics_workspace_id]
}
```

## Providers

| Name | Version |
|------|---------|
| azapi | ~> 2.0 |
| azuread | ~> 3.0 |
| azurecaf | ~> 1.2.28 |
| azurerm | ~> 4.21 |
| null | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| diagnostics | claranet/diagnostic-settings/azurerm | ~> 8.0.0 |

## Resources

| Name | Type |
|------|------|
| [azapi_update_resource.aks_kubernetes_version](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |
| [azurerm_kubernetes_cluster.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_monitor_data_collection_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_monitor_data_collection_rule_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_role_assignment.aci_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kubelet_uai_acr_pull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kubelet_uai_nodes_rg_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.uai_private_dns_zone_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.uai_route_table_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.uai_subnets_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.uai_vnet_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [null_resource.kubernetes_version_keeper](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azapi_resource.subnet_delegation](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource) | data source |
| [azuread_service_principal.aci_identity](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurecaf_name.aks](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.aks_identity](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.aks_nodes_rg](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.dcr](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurerm_kubernetes_service_versions.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_service_versions) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aci\_subnet | ID of the Subnet for ACI virtual-nodes. | <pre>object({<br/>    id = string<br/>  })</pre> | `null` | no |
| aks\_user\_assigned\_identity\_custom\_name | Custom name for the AKS user assigned identity resource. | `string` | `null` | no |
| api\_server\_authorized\_ip\_ranges | IP ranges allowed to interact with Kubernetes API for public clusters.<br/>See documentation about "0.0.0.0/32" default value :<br/>- https://learn.microsoft.com/en-us/azure/aks/api-server-authorized-ip-ranges#allow-only-the-outbound-public-ip-of-the-standard-sku-load-balancer<br/>- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#public_network_access_enabled<br/><br/>Set to `0.0.0.0/0` to wide open (not recommended) | `list(string)` | <pre>[<br/>  "0.0.0.0/32"<br/>]</pre> | no |
| auto\_scaler\_profile | Auto Scaler configuration. | <pre>object({<br/>    balance_similar_node_groups      = optional(bool, false)<br/>    expander                         = optional(string, "random")<br/>    max_graceful_termination_sec     = optional(number, 600)<br/>    max_node_provisioning_time       = optional(string, "15m")<br/>    max_unready_nodes                = optional(number, 3)<br/>    max_unready_percentage           = optional(number, 45)<br/>    new_pod_scale_up_delay           = optional(string, "10s")<br/>    scale_down_delay_after_add       = optional(string, "10m")<br/>    scale_down_delay_after_delete    = optional(string, "10s")<br/>    scale_down_delay_after_failure   = optional(string, "3m")<br/>    scan_interval                    = optional(string, "10s")<br/>    scale_down_unneeded              = optional(string, "10m")<br/>    scale_down_unready               = optional(string, "20m")<br/>    scale_down_utilization_threshold = optional(number, 0.5)<br/>    empty_bulk_delete_max            = optional(number, 10)<br/>    skip_nodes_with_local_storage    = optional(bool, true)<br/>    skip_nodes_with_system_pods      = optional(bool, true)<br/>  })</pre> | `null` | no |
| automatic\_upgrade\_channel | The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`. Setting this field to `null` sets this value to none. | `string` | `"patch"` | no |
| azure\_active\_directory\_rbac | Active Directory role based access control configuration. | <pre>object({<br/>    tenant_id              = optional(string, null)<br/>    admin_group_object_ids = optional(list(string), [])<br/>    azure_rbac_enabled     = optional(bool, true)<br/>  })</pre> | `null` | no |
| azure\_policy\_enabled | Option to enable Azure Policy add-on. | `bool` | `true` | no |
| client\_name | Client name/account used in naming. | `string` | n/a | yes |
| container\_registry\_id | Azure Container Registry ID where Azure Kubernetes Service needs pull access. | `string` | `null` | no |
| cost\_analysis\_enabled | Option to enable cost analysis in the Azure portal for this Kubernetes cluster. The `sku_tier` must be set to `Standard` or `Premium` to enable this feature. | `bool` | `false` | no |
| custom\_name | Custom AKS name, generated if not set. | `string` | `""` | no |
| data\_collection\_rule | AKS Data Collection Rule configuration. | <pre>object({<br/>    enabled                           = optional(bool, true)<br/>    custom_log_analytics_workspace_id = optional(string)<br/>    data_streams = optional(list(string), [<br/>      "Microsoft-ContainerLog",<br/>      "Microsoft-ContainerLogV2",<br/>      "Microsoft-KubeEvents",<br/>      "Microsoft-KubePodInventory",<br/>      "Microsoft-InsightsMetrics",<br/>      "Microsoft-ContainerInventory",<br/>      "Microsoft-ContainerNodeInventory",<br/>      "Microsoft-KubeNodeInventory",<br/>      "Microsoft-KubeServices",<br/>      "Microsoft-KubePVInventory"<br/>    ])<br/>    namespaces_filter = optional(list(string), [<br/>      "kube-system",<br/>      "gatekeeper-system",<br/>      "kube-node-lease",<br/>      "calico-system",<br/>    ])<br/>    namespace_filtering_mode = optional(string, "Exclude")<br/>    data_collection_interval = optional(string, "5m")<br/>    container_log_v2_enabled = optional(bool, true)<br/>  })</pre> | `{}` | no |
| data\_collection\_rule\_custom\_name | Custom name for the AKS Data Collection Rule. | `string` | `null` | no |
| default\_node\_pool | Default Node Pool configuration. | <pre>object({<br/>    name                        = optional(string, "default")<br/>    type                        = optional(string, "VirtualMachineScaleSets")<br/>    vm_size                     = optional(string, "Standard_D2_v3")<br/>    os_sku                      = optional(string, "Ubuntu")<br/>    os_disk_type                = optional(string, "Managed")<br/>    os_disk_size_gb             = optional(number)<br/>    auto_scaling_enabled        = optional(bool, false)<br/>    node_count                  = optional(number, 1)<br/>    min_count                   = optional(number, 1)<br/>    max_count                   = optional(number, 10)<br/>    max_pods                    = optional(number)<br/>    node_labels                 = optional(map(any))<br/>    node_taints                 = optional(list(any))<br/>    host_encryption_enabled     = optional(bool)<br/>    node_public_ip_enabled      = optional(bool, false)<br/>    orchestrator_version        = optional(string)<br/>    zones                       = optional(list(number), [1, 2, 3])<br/>    tags                        = optional(map(string), {})<br/>    temporary_name_for_rotation = optional(string)<br/>    upgrade_settings = optional(object({<br/>      max_surge = optional(string, "10%")<br/>    }), {})<br/>    linux_os_config = optional(object({<br/>      swap_file_size_mb             = optional(number)<br/>      transparent_huge_page_enabled = optional(string)<br/>      transparent_huge_page_defrag  = optional(string)<br/>      sysctl_config = optional(object({<br/>        fs_aio_max_nr                      = optional(number)<br/>        fs_file_max                        = optional(number)<br/>        fs_inotify_max_user_watches        = optional(number)<br/>        fs_nr_open                         = optional(number)<br/>        kernel_threads_max                 = optional(number)<br/>        net_core_netdev_max_backlog        = optional(number)<br/>        net_core_optmem_max                = optional(number)<br/>        net_core_rmem_default              = optional(number)<br/>        net_core_rmem_max                  = optional(number)<br/>        net_core_somaxconn                 = optional(number)<br/>        net_core_wmem_default              = optional(number)<br/>        net_core_wmem_max                  = optional(number)<br/>        net_ipv4_ip_local_port_range_max   = optional(number)<br/>        net_ipv4_ip_local_port_range_min   = optional(number)<br/>        net_ipv4_neigh_default_gc_thresh1  = optional(number)<br/>        net_ipv4_neigh_default_gc_thresh2  = optional(number)<br/>        net_ipv4_neigh_default_gc_thresh3  = optional(number)<br/>        net_ipv4_tcp_fin_timeout           = optional(number)<br/>        net_ipv4_tcp_keepalive_intvl       = optional(number)<br/>        net_ipv4_tcp_keepalive_probes      = optional(number)<br/>        net_ipv4_tcp_keepalive_time        = optional(number)<br/>        net_ipv4_tcp_max_syn_backlog       = optional(number)<br/>        net_ipv4_tcp_max_tw_buckets        = optional(number)<br/>        net_ipv4_tcp_tw_reuse              = optional(bool)<br/>        net_netfilter_nf_conntrack_buckets = optional(number)<br/>        net_netfilter_nf_conntrack_max     = optional(number)<br/>        vm_max_map_count                   = optional(number)<br/>        vm_swappiness                      = optional(number)<br/>        vm_vfs_cache_pressure              = optional(number)<br/>      }))<br/>    }))<br/>  })</pre> | `{}` | no |
| default\_tags\_enabled | Option to enable or disable default tags. | `bool` | `true` | no |
| diagnostic\_settings\_custom\_name | Custom name of the diagnostics settings, name will be 'default' if not set. | `string` | `"default"` | no |
| effective\_until | Effective until date for the upgrade override values. The date-time must be within the next 30 days. | `string` | `null` | no |
| environment | Project environment. | `string` | n/a | yes |
| extra\_tags | Additional tags to add on resources. | `map(string)` | `{}` | no |
| force\_upgrade\_enabled | Whether to force the upgrade of the Kubernetes cluster. | `bool` | `false` | no |
| http\_application\_routing\_enabled | Whether HTTP Application Routing is enabled. | `bool` | `false` | no |
| http\_proxy\_settings | Azure Kubernetes Service HTTP proxy settings. URLs must be in format `http(s)://fqdn:port/`. When setting the `no_proxy_list` parameter, the AKS Private Endpoint domain name and the AKS VNet CIDR (or Subnet CIDRs) must be added to the list. | <pre>object({<br/>    https_proxy_url = optional(string)<br/>    http_proxy_url  = optional(string)<br/>    trusted_ca      = optional(string)<br/>    no_proxy_list   = optional(list(string), [])<br/>  })</pre> | `null` | no |
| image\_cleaner\_configuration | Kubernetes image cleaner configuration. | <pre>object({<br/>    enabled        = optional(bool, true)<br/>    interval_hours = optional(number, 24)<br/>  })</pre> | `{}` | no |
| key\_vault\_secrets\_provider | Enable AKS built-in Key Vault secrets provider. If enabled, an identity is created by the AKS itself and exported from this module. | <pre>object({<br/>    secret_rotation_enabled  = optional(bool, true)<br/>    secret_rotation_interval = optional(string)<br/>  })</pre> | `{}` | no |
| kubernetes\_version | Version of Kubernetes to deploy. | `string` | `null` | no |
| linux\_profile | Username and SSH public key for accessing Linux nodes with SSH. | <pre>object({<br/>    username = string<br/>    ssh_key  = string<br/>  })</pre> | `null` | no |
| location | Azure region to use. | `string` | n/a | yes |
| location\_short | Short string for Azure location. | `string` | n/a | yes |
| logs\_categories | Log categories to send to destinations. | `list(string)` | `null` | no |
| logs\_destinations\_ids | List of destination resources IDs for logs diagnostic destination.<br/>Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.<br/>If you want to use Azure EventHub as a destination, you must provide a formatted string containing both the EventHub Namespace authorization send ID and the EventHub name (name of the queue to use in the Namespace) separated by the <code>&#124;</code> character. | `list(string)` | n/a | yes |
| logs\_kube\_audit\_enabled | Whether to include `kube-audit` and `kube-audit-admin` logs from diagnostics settings collection. Enabling this can increase your Azure billing. | `bool` | `false` | no |
| logs\_metrics\_categories | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| maintenance\_window | Maintenance window configuration. This is the basic configuration for controlling AKS releases. See [documentation](https://learn.microsoft.com/en-us/azure/aks/planned-maintenance?tabs=azure-cli). | <pre>object({<br/>    allowed = optional(list(object({<br/>      day   = string<br/>      hours = list(number)<br/>    })), [])<br/>    not_allowed = optional(list(object({<br/>      start = string<br/>      end   = string<br/>    })), [])<br/>  })</pre> | `null` | no |
| maintenance\_window\_auto\_upgrade | Controls when to perform cluster upgrade with more finely controlled cadence and recurrence settings compared to the basic one. See [documentation](https://learn.microsoft.com/en-us/azure/aks/planned-maintenance?tabs=azure-cli). | <pre>object({<br/>    frequency    = string<br/>    interval     = string<br/>    duration     = number<br/>    day_of_week  = optional(string)<br/>    day_of_month = optional(string)<br/>    week_index   = optional(string)<br/>    start_time   = string<br/>    utc_offset   = optional(string)<br/>    start_date   = optional(string)<br/>    not_allowed = optional(list(object({<br/>      start = string<br/>      end   = string<br/>    })), [])<br/>  })</pre> | `null` | no |
| microsoft\_defender | Specifies the ID of the Log Analytics Workspace where the audit logs collected by Microsoft Defender should be sent to. | <pre>object({<br/>    log_analytics_workspace_id = string<br/>  })</pre> | `null` | no |
| monitor\_metrics | Specifies a Prometheus add-on profile for this Kubernetes Cluster. | <pre>object({<br/>    annotations_allowed = optional(string, null)<br/>    labels_allowed      = optional(string, null)<br/>  })</pre> | `null` | no |
| name\_prefix | Optional prefix for the generated name. | `string` | `""` | no |
| name\_suffix | Optional suffix for the generated name. | `string` | `""` | no |
| network\_mode | Azure Kubernetes Service network mode to use. Only available with Azure CNI. | `string` | `null` | no |
| network\_plugin | Azure Kubernetes Service network plugin to use. Possible names are `azure` and `kubenet`. Possible CNI modes are `None`, `Overlay` and `Cilium` for Azure CNI and `None` for Kubenet. Changing this forces a new resource to be created. | <pre>object({<br/>    name     = optional(string, "azure")<br/>    cni_mode = optional(string, "overlay")<br/>  })</pre> | `{}` | no |
| network\_policy | Azure Kubernetes Service network policy to use. | `string` | `"calico"` | no |
| node\_os\_update\_schedule | Controls when to perform node OS upgrade with more finely controlled cadence and recurrence settings compared to the basic one. See [documentation](https://learn.microsoft.com/en-us/azure/aks/planned-maintenance?tabs=azure-cli). | <pre>object({<br/>    frequency    = optional(string, "Weekly")<br/>    interval     = optional(number, 1)<br/>    duration     = optional(number, 4)<br/>    day_of_week  = optional(string, "Monday")<br/>    day_of_month = optional(string)<br/>    week_index   = optional(string)<br/>    start_time   = optional(string, "04:00")<br/>    utc_offset   = optional(string, "00:00")<br/>    start_date   = optional(string)<br/>    not_allowed = optional(list(object({<br/>      start = string<br/>      end   = string<br/>    })), [])<br/>  })</pre> | `{}` | no |
| node\_os\_upgrade\_channel | The upgrade channel for this Kubernetes Cluster Nodes OS Image. Possible values are `Unmanaged`, `SecurityPatch`, `NodeImage` and `None`. | `string` | `"SecurityPatch"` | no |
| node\_pools | A list of Node Pools to create. | <pre>list(object({<br/>    name              = string<br/>    vm_size           = optional(string, "Standard_D2_v3")<br/>    os_sku            = optional(string, "Ubuntu")<br/>    os_disk_type      = optional(string, "Managed")<br/>    os_disk_size_gb   = optional(number)<br/>    kubelet_disk_type = optional(string)<br/>    linux_os_config = optional(object({<br/>      swap_file_size_mb             = optional(number)<br/>      transparent_huge_page_enabled = optional(string)<br/>      transparent_huge_page_defrag  = optional(string)<br/>      sysctl_config = optional(object({<br/>        fs_aio_max_nr                      = optional(number)<br/>        fs_file_max                        = optional(number)<br/>        fs_inotify_max_user_watches        = optional(number)<br/>        fs_nr_open                         = optional(number)<br/>        kernel_threads_max                 = optional(number)<br/>        net_core_netdev_max_backlog        = optional(number)<br/>        net_core_optmem_max                = optional(number)<br/>        net_core_rmem_default              = optional(number)<br/>        net_core_rmem_max                  = optional(number)<br/>        net_core_somaxconn                 = optional(number)<br/>        net_core_wmem_default              = optional(number)<br/>        net_core_wmem_max                  = optional(number)<br/>        net_ipv4_ip_local_port_range_max   = optional(number)<br/>        net_ipv4_ip_local_port_range_min   = optional(number)<br/>        net_ipv4_neigh_default_gc_thresh1  = optional(number)<br/>        net_ipv4_neigh_default_gc_thresh2  = optional(number)<br/>        net_ipv4_neigh_default_gc_thresh3  = optional(number)<br/>        net_ipv4_tcp_fin_timeout           = optional(number)<br/>        net_ipv4_tcp_keepalive_intvl       = optional(number)<br/>        net_ipv4_tcp_keepalive_probes      = optional(number)<br/>        net_ipv4_tcp_keepalive_time        = optional(number)<br/>        net_ipv4_tcp_max_syn_backlog       = optional(number)<br/>        net_ipv4_tcp_max_tw_buckets        = optional(number)<br/>        net_ipv4_tcp_tw_reuse              = optional(bool)<br/>        net_netfilter_nf_conntrack_buckets = optional(number)<br/>        net_netfilter_nf_conntrack_max     = optional(number)<br/>        vm_max_map_count                   = optional(number)<br/>        vm_swappiness                      = optional(number)<br/>        vm_vfs_cache_pressure              = optional(number)<br/>      }))<br/>    }))<br/>    auto_scaling_enabled    = optional(bool, false)<br/>    node_count              = optional(number, 1)<br/>    min_count               = optional(number, 1)<br/>    max_count               = optional(number, 10)<br/>    max_pods                = optional(number)<br/>    node_labels             = optional(map(any))<br/>    node_taints             = optional(list(any))<br/>    host_encryption_enabled = optional(bool)<br/>    node_public_ip_enabled  = optional(bool, false)<br/>    node_subnet = optional(object({<br/>      name                 = optional(string)<br/>      virtual_network_name = optional(string)<br/>      resource_group_name  = optional(string)<br/>    }), {})<br/>    pod_subnet = optional(object({<br/>      name                 = optional(string)<br/>      virtual_network_name = optional(string)<br/>      resource_group_name  = optional(string)<br/>    }), {})<br/>    priority                    = optional(string)<br/>    eviction_policy             = optional(string)<br/>    orchestrator_version        = optional(string)<br/>    temporary_name_for_rotation = optional(string)<br/>    upgrade_settings = optional(object({<br/>      max_surge = optional(string, "10%")<br/>    }), null)<br/>    zones = optional(list(number), [1, 2, 3])<br/>    tags  = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| nodes\_resource\_group\_name | Name of the Resource Group in which to put Azure Kubernetes Service nodes. | `string` | `null` | no |
| nodes\_subnet | The Subnet used by nodes. | <pre>object({<br/>    name                 = string<br/>    virtual_network_name = string<br/>    resource_group_name  = optional(string)<br/>  })</pre> | n/a | yes |
| oidc\_issuer\_enabled | Whether the OIDC issuer URL should be enabled. | `bool` | `true` | no |
| oms\_agent | OMS Agent configuration. | <pre>object({<br/>    log_analytics_workspace_id      = optional(string)<br/>    msi_auth_for_monitoring_enabled = optional(bool, true)<br/>  })</pre> | n/a | yes |
| outbound\_type | The outbound (egress) routing method which should be used. Possible values are `loadBalancer` and `userDefinedRouting`. | `string` | `"loadBalancer"` | no |
| pod\_cidr | CIDR used by pods when network plugin is set to `kubenet` or `azure` CNI Overlay. | `string` | `null` | no |
| pods\_subnet | The Subnet containing the pods. | <pre>object({<br/>    name                 = optional(string)<br/>    virtual_network_name = optional(string)<br/>    resource_group_name  = optional(string)<br/>  })</pre> | `{}` | no |
| private\_cluster\_enabled | Configure Azure Kubernetes Service as a Private Cluster. See [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_cluster_enabled). | `bool` | `true` | no |
| private\_cluster\_public\_fqdn\_enabled | Specifies whether a Public FQDN for this Private Cluster should be added. See [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_cluster_public_fqdn_enabled). | `bool` | `false` | no |
| private\_dns\_zone\_id | ID of the Private DNS Zone when `private_dns_zone_type = "Custom"`. | `string` | `null` | no |
| private\_dns\_zone\_role\_assignment\_enabled | Option to enable or disable Private DNS Zone role assignment. | `bool` | `true` | no |
| private\_dns\_zone\_type | Set Azure Kubernetes Service private DNS zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)<br/>- "Custom" : You will have to deploy a private DNS Zone on your own and provide the ID with <private\_dns\_zone\_id> variable<br/>- "System" : AKS will manage the Private DNS Zone and creates it in the Node Resource Group<br/>- "None" : In case of None you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning.<br/><br/>See [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_dns_zone_id). | `string` | `"System"` | no |
| resource\_group\_name | Name of the resource group. | `string` | n/a | yes |
| route\_table\_id | Provide an existing Route Table ID when `outbound_type = "userDefinedRouting"`. Only available with Kubenet. | `string` | `null` | no |
| service\_cidr | CIDR used by Kubernetes services (kubectl get svc). | `string` | n/a | yes |
| sku\_tier | Azure Kubernetes Service SKU tier. Possible values are `Free` ou `Standard`. | `string` | `"Standard"` | no |
| stack | Project stack name. | `string` | n/a | yes |
| storage\_profile | Select the CSI drivers to be enabled. | <pre>object({<br/>    blob_driver_enabled         = optional(bool, true)<br/>    disk_driver_enabled         = optional(bool, true)<br/>    file_driver_enabled         = optional(bool, true)<br/>    snapshot_controller_enabled = optional(bool, true)<br/>  })</pre> | `null` | no |
| user\_assigned\_identity\_resource\_group\_name | Resource Group where to deploy the Azure Kubernetes Service User Assigned Identity resource. | `string` | `null` | no |
| user\_assigned\_identity\_tags | Tags to add to AKS MSI. | `map(string)` | `{}` | no |
| workload\_identity\_enabled | Whether Azure AD Workload Identity should be enabled for the cluster. `oidc_issuer_enabled` must be set to true to use this feature. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| apiserver\_endpoint | APIServer Endpoint of the Azure Kubernetes Service. |
| id | ID of the Azure Kubernetes Service. |
| identity\_principal\_id | AKS System Managed Identity principal ID. |
| key\_vault\_secrets\_provider\_identity | The User Managed Identity used by the Key Vault secrets provider. |
| kube\_config | Kube configuration of the Azure Kubernetes Service. |
| kube\_config\_raw | Raw kubeconfig to be used by kubectl command. |
| kubelet\_user\_managed\_identity | The Kubelet User Managed Identity used by the Azure Kubernetes Service. |
| kubernetes\_version | Azure Kubernetes Service Kubernetes version. |
| managed\_private\_dns\_zone\_id | ID of the AKS' managed Private DNS Zone. |
| managed\_private\_dns\_zone\_name | Name of the AKS' managed Private DNS Zone. |
| managed\_private\_dns\_zone\_resource\_group\_name | Resource Group name of the AKS' managed Private DNS Zone. |
| module\_diagnostics | Diagnostics Settings module output. |
| name | Name of the Azure Kubernetes Service. |
| node\_pools | Map of Azure Kubernetes Service Node Pools attributes. |
| nodes\_resource\_group\_name | Name of the Resource Group in which Azure Kubernetes Service nodes are deployed. |
| oidc\_issuer\_url | The OIDC issuer URL that is associated with the Azure Kubernetes Service. |
| portal\_fqdn | Portal FQDN of the Azure Kubernetes Service. |
| private\_cluster\_enabled | Whether private cluster is enabled. |
| private\_fqdn | Private FQDNs of the Azure Kubernetes Service. |
| public\_fqdn | Public FQDN of the Azure Kubernetes Service. |
| resource | Azure Kubernetes Cluster resource object. |
| resource\_data\_collection\_rule | Data Collection Rule resource output. |
| resource\_node\_pools | Azure Kubernetes Node Pools resource output. |
| user\_managed\_identity | The User Managed Identity used by the Azure Kubernetes Service. |
<!-- END_TF_DOCS -->

## Related documentation

- Azure Kubernetes Service documentation: [docs.microsoft.com/en-us/azure/aks/](https://docs.microsoft.com/en-us/azure/aks/)
- Azure Kubernetes Service MSI usage: [docs.microsoft.com/en-us/azure/aks/use-managed-identity](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity)
- Azure Kubernetes Service User-Defined Routes usage: [docs.microsoft.com/en-us/azure/aks/egress-outboundtype](https://docs.microsoft.com/en-us/azure/aks/egress-outboundtype)
- Terraform Kubernetes provider documentation: [www.terraform.io/docs/providers/kubernetes/index.html](https://www.terraform.io/docs/providers/kubernetes/index.html)
