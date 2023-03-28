# Azure Kubernetes Service
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/aks-light/azurerm/)

This terraform module creates an [Azure Kubernetes Service](https://azure.microsoft.com/fr-fr/services/kubernetes-service/).

Inside the cluster the default node pool is initialized.

This module also configures logging to a [Log Analytics Workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace), and creates some
[Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) with different types of Azure managed disks (Standard HDD retain and delete, Premium SSD retain and delete).

## Requirements
- You have to register the `AzureOverlayPreview` feature flag according to the [documentation](https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay#register-the-azureoverlaypreview-feature-flag)
to use [Azure CNI Overlay](https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay) included in the module.
- You have to register the `EnableWorkloadIdentityPreview` feature flag according to the [documentation](https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity#register-the-enableworkloadidentitypreview-feature-flag)
to use [Azure AD workload identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview) included in the module.

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 7.x.x       | 1.3.x             | >= 3.0          |
| >= 6.x.x       | 1.x               | >= 3.0          |
| >= 5.x.x       | 0.15.x            | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   | >= 2.0          |
| >= 3.x.x       | 0.12.x            | >= 2.0          |
| >= 2.x.x       | 0.12.x            | < 2.0           |
| <  2.x.x       | 0.11.x            | < 2.0           |

## Contributing

If you want to contribute to this repository, feel free to use our [pre-commit](https://pre-commit.com/) git hook configuration
which will help you automatically update and format some files for you by enforcing our Terraform code module best-practices.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

```hcl
locals {
  allowed_cidrs = ["x.x.x.x", "y.y.y.y"]
}

module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "azure_virtual_network" {
  source  = "claranet/vnet/azurerm"
  version = "x.x.x"

  environment    = var.environment
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  vnet_cidr = ["10.0.0.0/19"]
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "privatelink.francecentral.azmk8s.io"
  resource_group_name = module.rg.resource_group_name

}

module "node_network_subnet" {
  source  = "claranet/subnet/azurerm"
  version = "x.x.x"

  environment    = var.environment
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  stack          = var.stack

  resource_group_name  = module.rg.resource_group_name
  virtual_network_name = module.azure_virtual_network.virtual_network_name

  name_suffix = "nodes"

  subnet_cidr_list = ["10.0.0.0/20"]

  service_endpoints = ["Microsoft.Storage"]
}

module "appgw_network_subnet" {
  source  = "claranet/subnet/azurerm"
  version = "x.x.x"

  environment    = var.environment
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  stack          = var.stack

  resource_group_name  = module.rg.resource_group_name
  virtual_network_name = module.azure_virtual_network.virtual_network_name

  name_suffix = "appgw"

  subnet_cidr_list = ["10.0.20.0/24"]
}

module "global_run" {
  source  = "claranet/run/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  environment    = var.environment
  stack          = var.stack

  monitoring_function_splunk_token = var.monitoring_function_splunk_token

  resource_group_name = module.rg.resource_group_name

  tenant_id = var.azure_tenant_id
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

module "aks" {
  #source  = "claranet/aks-light/azurerm"
  #version = "x.x.x"
  source = "git@git.fr.clara.net:claranet/projects/cloud/azure/terraform/modules/aks-light.git?ref=AZ-1027-init--module"

  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

  resource_group_name = module.rg.resource_group_name
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short

  service_cidr       = "10.0.16.0/22"
  kubernetes_version = "1.25.5"

  vnet_id         = module.azure_virtual_network.virtual_network_id
  nodes_subnet_id = module.node_network_subnet.subnet_id

  private_cluster_enabled = true
  private_dns_zone_type   = "Custom"
  private_dns_zone_id     = azurerm_private_dns_zone.private_dns_zone.id

  default_node_pool = {
    max_pods        = 110
    os_disk_size_gb = 64
    vm_size         = "Standard_B4ms"
  }

  nodes_pools = [
    {
      name                = "nodepool1"
      vm_size             = "Standard_B4ms"
      os_type             = "Linux"
      os_disk_type        = "Ephemeral"
      os_disk_size_gb     = 100
      vnet_subnet_id      = module.node_network_subnet.subnet_id
      max_pods            = 110
      enable_auto_scaling = true
      count               = 1
      min_count           = 1
      max_count           = 10
    },
  ]

  linux_profile = {
    username = "nodeadmin"
    ssh_key  = tls_private_key.key.public_key_openssh
  }

  oms_log_analytics_workspace_id = module.global_run.log_analytics_workspace_id
  azure_policy_enabled           = false

  logs_destinations_ids = [module.global_run.log_analytics_workspace_id]

  container_registries_id = [module.acr.acr_id]
}

module "acr" {
  source  = "claranet/acr/azurerm"
  version = "x.x.x"

  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name
  sku                 = "Standard"

  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

  logs_destinations_ids = [module.global_run.log_analytics_workspace_id]
}
```

## Providers

| Name | Version |
|------|---------|
| azuread | ~> 2.31 |
| azurecaf | ~> 1.2, >= 1.2.22 |
| azurerm | ~> 3.57 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| diagnostics | claranet/diagnostic-settings/azurerm | ~> 6.4.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster.aks_light](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.node_pools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_role_assignment.aci_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_acr_pull_allowed](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_kubelet_uai_vnet_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_uai_private_dns_zone_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_uai_vnet_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_user_assigned](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.aks_user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azuread_service_principal.aci_identity](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurecaf_name.aks](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.aks_identity](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.aks_light](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.aks_node_rg](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_virtual_network.aks_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aci\_subnet\_id | Optional subnet Id used for ACI virtual-nodes | `string` | `null` | no |
| aks\_http\_proxy\_settings | AKS HTTP proxy settings. URLs must be in format `http(s)://fqdn:port/`. When setting the `no_proxy_url_list` parameter, the AKS Private Endpoint domain name and the AKS VNet CIDR must be added to the URLs list. | <pre>object({<br>    http_proxy_url    = optional(string)<br>    https_proxy_url   = optional(string)<br>    no_proxy_url_list = optional(list(string), [])<br>    trusted_ca        = optional(string)<br>  })</pre> | `null` | no |
| aks\_network\_plugin | AKS network plugin to use. Possible values are `azure` and `kubenet`. Changing this forces a new resource to be created | `string` | `"azure"` | no |
| aks\_network\_policy | AKS network policy to use. | `string` | `"calico"` | no |
| aks\_pod\_cidr | CIDR used by pods when network plugin is set to `kubenet`. https://docs.microsoft.com/en-us/azure/aks/configure-kubenet | `string` | `"172.17.0.0/16"` | no |
| aks\_sku\_tier | aks sku tier. Possible values are Free ou Paid | `string` | `"Free"` | no |
| aks\_user\_assigned\_identity\_custom\_name | Custom name for the aks user assigned identity resource | `string` | `null` | no |
| aks\_user\_assigned\_identity\_resource\_group\_name | Resource Group where to deploy the aks user assigned identity resource. Used when private cluster is enabled and when Azure private dns zone is not managed by aks | `string` | `null` | no |
| aks\_user\_assigned\_identity\_tags | Tags to add to AKS MSI | `map(string)` | `{}` | no |
| allowed\_cidrs | List of allowed CIDR ranges to access the AKS resource. | `list(string)` | `[]` | no |
| allowed\_subnet\_ids | List of allowed subnets IDs to access the AKS resource. | `list(string)` | `[]` | no |
| api\_server\_authorized\_ip\_ranges | Ip ranges allowed to interract with Kubernetes API. Default no restrictions | `list(string)` | `[]` | no |
| auto\_scaler\_profile | Configuration of `auto_scaler_profile` block object | <pre>object({<br>    balance_similar_node_groups      = optional(bool, false)<br>    expander                         = optional(string, "random")<br>    max_graceful_termination_sec     = optional(number, 600)<br>    max_node_provisioning_time       = optional(string, "15m")<br>    max_unready_nodes                = optional(number, 3)<br>    max_unready_percentage           = optional(number, 45)<br>    new_pod_scale_up_delay           = optional(string, "10s")<br>    scale_down_delay_after_add       = optional(string, "10m")<br>    scale_down_delay_after_delete    = optional(string, "10s")<br>    scale_down_delay_after_failure   = optional(string, "3m")<br>    scan_interval                    = optional(string, "10s")<br>    scale_down_unneeded              = optional(string, "10m")<br>    scale_down_unready               = optional(string, "20m")<br>    scale_down_utilization_threshold = optional(number, 0.5)<br>    empty_bulk_delete_max            = optional(number, 10)<br>    skip_nodes_with_local_storage    = optional(bool, true)<br>    skip_nodes_with_system_pods      = optional(bool, true)<br>  })</pre> | `null` | no |
| azure\_policy\_enabled | Should the Azure Policy Add-On be enabled? | `bool` | `false` | no |
| client\_name | Client name/account used in naming. | `string` | n/a | yes |
| container\_registries\_id | List of Azure Container Registries ids where AKS needs pull access. | `list(string)` | `[]` | no |
| custom\_diagnostic\_settings\_name | Custom name of the diagnostics settings, name will be 'default' if not set. | `string` | `"default"` | no |
| custom\_name | Custom AKS, generated if not set | `string` | `""` | no |
| default\_node\_pool | Default node pool configuration | <pre>object({<br>    name                   = optional(string, "default")<br>    node_count             = optional(number, 1)<br>    vm_size                = optional(string, "Standard_D2_v3")<br>    os_type                = optional(string, "Linux")<br>    zones                  = optional(list(number), [1, 2, 3])<br>    enable_auto_scaling    = optional(bool, false)<br>    min_count              = optional(number, 1)<br>    max_count              = optional(number, 10)<br>    type                   = optional(string, "VirtualMachineScaleSets")<br>    node_taints            = optional(list(any), null)<br>    node_labels            = optional(map(any), null)<br>    orchestrator_version   = optional(string, null)<br>    priority               = optional(string, null)<br>    enable_host_encryption = optional(bool, null)<br>    eviction_policy        = optional(string, null)<br>    max_pods               = optional(number, 30)<br>    os_disk_type           = optional(string, "Managed")<br>    os_disk_size_gb        = optional(number, 128)<br>    enable_node_public_ip  = optional(bool, false)<br>  })</pre> | `{}` | no |
| default\_node\_pool\_tags | Specific tags for default node pool | `map(string)` | `{}` | no |
| default\_tags\_enabled | Option to enable or disable default tags. | `bool` | `true` | no |
| environment | Project environment. | `string` | n/a | yes |
| extra\_tags | Additional tags to add on resources. | `map(string)` | `{}` | no |
| http\_application\_routing\_enabled | Whether HTTP Application Routing is enabled. | `bool` | `false` | no |
| key\_vault\_secrets\_provider\_enabled | Specifies wether Secrets Store CSI Driver should be enabled for the cluster. https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver | `bool` | `true` | no |
| key\_vault\_secrets\_provider\_interval | The interval to poll for secret rotation. This attribute is only set when `secret_rotation` is `true`. | `string` | `"2m"` | no |
| kubernetes\_version | Version of Kubernetes to deploy | `string` | `"1.25.5"` | no |
| linux\_profile | Username and ssh key for accessing AKS Linux nodes with ssh. | <pre>object({<br>    username = string,<br>    ssh_key  = string<br>  })</pre> | `null` | no |
| location | Azure region to use. | `string` | n/a | yes |
| location\_short | Short string for Azure location. | `string` | n/a | yes |
| logs\_categories | Log categories to send to destinations. | `list(string)` | `null` | no |
| logs\_destinations\_ids | List of destination resources IDs for logs diagnostic destination.<br>Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.<br>If you want to specify an Azure EventHub to send logs and metrics to, you need to provide a formated string with both the EventHub Namespace authorization send ID and the EventHub name (name of the queue to use in the Namespace) separated by the `|` character. | `list(string)` | n/a | yes |
| logs\_kube\_audit\_enabled | Whether to include `kube-audit` and `kube-audit-admin` logs from diagnostics settings collection. Enabling this can increase your Azure billing. | `bool` | `false` | no |
| logs\_metrics\_categories | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| logs\_retention\_days | Number of days to keep logs on storage account. | `number` | `30` | no |
| name\_prefix | Optional prefix for the generated name | `string` | `""` | no |
| name\_suffix | Optional suffix for the generated name | `string` | `""` | no |
| network\_bypass | Specify whether traffic is bypassed for 'Logging', 'Metrics', 'AzureServices' or 'None'. | `list(string)` | <pre>[<br>  "Logging",<br>  "Metrics",<br>  "AzureServices"<br>]</pre> | no |
| node\_pool\_tags | Specific tags for node pool | `map(string)` | `{}` | no |
| node\_resource\_group\_name | Name of the resource group in which to put AKS nodes. If null default to MC\_<AKS RG Name> | `string` | `null` | no |
| nodes\_pools | A list of nodes pools to create, each item supports same properties as `local.default_agent_profile` | `list(any)` | `[]` | no |
| nodes\_subnet\_id | ID of the subnet used for nodes | `string` | n/a | yes |
| oidc\_issuer\_enabled | Enable or Disable the OIDC issuer URL. | `bool` | `true` | no |
| oms\_log\_analytics\_workspace\_id | The ID of the Log Analytics Workspace used to send OMS logs | `string` | n/a | yes |
| outbound\_type | The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are `loadBalancer` and `userDefinedRouting`. | `string` | `"loadBalancer"` | no |
| private\_cluster\_enabled | Configure AKS as a Private Cluster: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_cluster_enabled | `bool` | `true` | no |
| private\_dns\_zone\_id | Id of the private DNS Zone when <private\_dns\_zone\_type> is custom | `string` | `null` | no |
| private\_dns\_zone\_role\_assignment\_enabled | Option to enable or disable Private DNS Zone role assignment. | `bool` | `true` | no |
| private\_dns\_zone\_type | Set AKS private dns zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)<br>- "Custom" : You will have to deploy a private Dns Zone on your own and pass the id with <private\_dns\_zone\_id> variable<br>If this settings is used, aks user assigned identity will be "userassigned" instead of "systemassigned"<br>and the aks user must have "Private DNS Zone Contributor" role on the private DNS Zone<br>- "System" : AKS will manage the private zone and create it in the same resource group as the Node Resource Group<br>- "None" : In case of None you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning.<br><br>https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_dns_zone_id | `string` | `"System"` | no |
| public\_network\_access\_enabled | Whether the AKS is available from public network. | `bool` | `false` | no |
| resource\_group\_name | Name of the resource group. | `string` | n/a | yes |
| service\_cidr | CIDR used by kubernetes services (kubectl get svc). | `string` | n/a | yes |
| stack | Project stack name. | `string` | n/a | yes |
| vnet\_id | Vnet id that Aks MSI should be network contributor in a private cluster | `string` | `null` | no |
| workload\_identity\_enabled | Specifies whether Azure AD Workload Identity should be enabled for the cluster. `oidc_issuer_enabled` must be set to true to use this feature. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| aks\_id | AKS resource id |
| aks\_kube\_config | Kube configuration of AKS Cluster |
| aks\_kube\_config\_raw | Raw kube config to be used by kubectl command |
| aks\_kubelet\_user\_managed\_identity | The Kubelet User Managed Identity used by the AKS cluster. |
| aks\_light | AKS output object |
| aks\_name | Name of the AKS cluster |
| aks\_nodes\_pools\_ids | Ids of AKS nodes pools |
| aks\_nodes\_pools\_names | Names of AKS nodes pools |
| aks\_nodes\_rg | Name of the resource group in which AKS nodes are deployed |
| aks\_oidc\_issuer\_url | The OIDC issuer URL that is associated with the cluster. |
| aks\_user\_managed\_identity | The User Managed Identity used by the AKS cluster. |
| id | AKS ID |
| identity\_principal\_id | AKS system identity principal ID |
| name | AKS name |
<!-- END_TF_DOCS -->

## Related documentation

Microsoft Azure documentation: xxxx
| aks\_id | AKS resource id |
| aks\_kube\_config | Kube configuration of AKS Cluster |
| aks\_kube\_config\_raw | Raw kube config to be used by kubectl command |
| aks\_kubelet\_user\_managed\_identity | The Kubelet User Managed Identity used by the AKS cluster. |
| aks\_name | Name of the AKS cluster |
| aks\_nodes\_pools\_ids | Ids of AKS nodes pools |
| aks\_nodes\_pools\_names | Names of AKS nodes pools |
| aks\_nodes\_rg | Name of the resource group in which AKS nodes are deployed |
| aks\_oidc\_issuer\_url | The OIDC issuer URL that is associated with the cluster. |
| aks\_user\_managed\_identity | The User Managed Identity used by the AKS cluster. |
<!-- END_TF_DOCS -->
## Related documentation

- Azure Kubernetes Service documentation : [docs.microsoft.com/en-us/azure/aks/](https://docs.microsoft.com/en-us/azure/aks/)
- Azure Kubernetes Service MSI Usage : [docs.microsoft.com/en-us/azure/aks/use-managed-identity](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity)
- Azure Kubernetes Service User-Defined Route usage : [docs.microsoft.com/en-us/azure/aks/egress-outboundtype](https://docs.microsoft.com/en-us/azure/aks/egress-outboundtype)
- Terraform Kubernetes provider documentation: [www.terraform.io/docs/providers/kubernetes/index.html](https://www.terraform.io/docs/providers/kubernetes/index.html)
