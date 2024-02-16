variable "kubernetes_version" {
  description = "Version of Kubernetes to deploy."
  type        = string
  default     = null
}

variable "api_server_authorized_ip_ranges" {
  description = <<EOD
IP ranges allowed to interact with Kubernetes API for public clusters.
See documentation about "0.0.0.0/32" default value :
- https://learn.microsoft.com/en-us/azure/aks/api-server-authorized-ip-ranges#allow-only-the-outbound-public-ip-of-the-standard-sku-load-balancer
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#public_network_access_enabled

Set to `0.0.0.0/0` to wide open (not recommended)
EOD
  type        = list(string)
  default     = ["0.0.0.0/32"]
}

variable "nodes_resource_group_name" {
  description = "Name of the Resource Group in which to put Azure Kubernetes Service nodes."
  type        = string
  default     = null
}

variable "http_application_routing_enabled" {
  description = "Whether HTTP Application Routing is enabled."
  type        = bool
  nullable    = false
  default     = false
}

variable "private_cluster_enabled" {
  description = "Configure Azure Kubernetes Service as a Private Cluster: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_cluster_enabled"
  type        = bool
  nullable    = false
  default     = true
}

variable "private_cluster_public_fqdn_enabled" {
  description = "Specifies whether a Public FQDN for this Private Cluster should be added: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_cluster_public_fqdn_enabled"
  type        = bool
  nullable    = false
  default     = false
}

variable "private_dns_zone_type" {
  description = <<EOD
Set Azure Kubernetes Service private DNS zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)
- "Custom" : You will have to deploy a private DNS Zone on your own and provide the ID with <private_dns_zone_id> variable
- "System" : AKS will manage the Private DNS Zone and creates it in the Node Resource Group
- "None" : In case of None you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning.

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_dns_zone_id
EOD
  type        = string
  nullable    = false
  default     = "System"
}

variable "private_dns_zone_id" {
  description = "ID of the Private DNS Zone when `private_dns_zone_type = \"Custom\"`."
  type        = string
  default     = null
}

variable "private_dns_zone_role_assignment_enabled" {
  description = "Option to enable or disable Private DNS Zone role assignment."
  type        = bool
  nullable    = false
  default     = true
}

variable "aks_user_assigned_identity_resource_group_name" {
  description = "Resource Group where to deploy the Azure Kubernetes Service User Assigned Identity resource."
  type        = string
  default     = null
}

variable "aks_sku_tier" {
  description = "Azure Kubernetes Service SKU tier. Possible values are Free ou Standard"
  type        = string
  nullable    = false
  default     = "Standard"
}

variable "aks_network_plugin" {
  description = "Azure Kubernetes Service network plugin to use. Possible names are `azure` and `kubenet`. Possible CNI modes are `None`, `Overlay` and `Cilium` for Azure CNI and `None` for Kubenet. Changing this forces a new resource to be created."
  type = object({
    name     = optional(string, "azure")
    cni_mode = optional(string, "overlay")
  })
  nullable = false
  default  = {}

  validation {
    condition     = contains(["azure", "kubenet"], var.aks_network_plugin.name)
    error_message = "The network plugin value must be \"azure\" or \"kubenet\"."
  }
  validation {
    condition     = contains(["none", "overlay", "cilium"], lower(var.aks_network_plugin.cni_mode))
    error_message = "The network plugin value must be \"None\", \"Overlay\" or \"Cilium\"."
  }
}

variable "aks_network_policy" {
  description = "Azure Kubernetes Service network policy to use."
  type        = string
  default     = "calico"
}

variable "aks_network_mode" {
  description = "Azure Kubernetes Service network mode to use. Only available with Azure CNI."
  type        = string
  default     = null
}

variable "aks_route_table_id" {
  description = "Provide an existing Route Table ID when `outbound_type = \"userDefinedRouting\"`. Only available with Kubenet."
  type        = string
  default     = null
}

variable "aks_http_proxy_settings" {
  description = "Azure Kubernetes Service HTTP proxy settings. URLs must be in format `http(s)://fqdn:port/`. When setting the `no_proxy_list` parameter, the AKS Private Endpoint domain name and the AKS VNet CIDR (or Subnet CIDRs) must be added to the list."
  type = object({
    https_proxy_url = optional(string)
    http_proxy_url  = optional(string)
    trusted_ca      = optional(string)
    no_proxy_list   = optional(list(string), [])
  })
  default = null
}

variable "default_node_pool" {
  description = "Default Node Pool configuration."
  type = object({
    name                        = optional(string, "default")
    type                        = optional(string, "VirtualMachineScaleSets")
    vm_size                     = optional(string, "Standard_D2_v3")
    os_sku                      = optional(string, "Ubuntu")
    os_disk_type                = optional(string, "Managed")
    os_disk_size_gb             = optional(number)
    enable_auto_scaling         = optional(bool, false)
    node_count                  = optional(number, 1)
    min_count                   = optional(number, 1)
    max_count                   = optional(number, 10)
    max_pods                    = optional(number)
    node_labels                 = optional(map(any))
    node_taints                 = optional(list(any))
    enable_host_encryption      = optional(bool)
    enable_node_public_ip       = optional(bool, false)
    orchestrator_version        = optional(string)
    zones                       = optional(list(number), [1, 2, 3])
    tags                        = optional(map(string), {})
    temporary_name_for_rotation = optional(string)
  })
  nullable = false
  default  = {}
}

variable "nodes_subnet" {
  description = "The Subnet used by nodes."
  type = object({
    name                 = string
    virtual_network_name = string
    resource_group_name  = optional(string)
  })
  nullable = false
}

variable "pods_subnet" {
  description = "The Subnet containing the pods."
  type = object({
    name                 = optional(string)
    virtual_network_name = optional(string)
    resource_group_name  = optional(string)
  })
  nullable = false
  default  = {}
  validation {
    condition = var.pods_subnet.name != null || var.pods_subnet.virtual_network_name != null ? length(
      compact([var.pods_subnet.name, var.pods_subnet.virtual_network_name])
    ) == 2 : true
    error_message = "var.pods_subnet.name and var.pods_subnet.virtual_network_name must be specified together."
  }
}

variable "aci_subnet_id" {
  description = "ID of the Subnet for ACI virtual-nodes."
  type        = string
  default     = null
}

variable "auto_scaler_profile" {
  description = "Auto Scaler configuration."
  type = object({
    balance_similar_node_groups      = optional(bool, false)
    expander                         = optional(string, "random")
    max_graceful_termination_sec     = optional(number, 600)
    max_node_provisioning_time       = optional(string, "15m")
    max_unready_nodes                = optional(number, 3)
    max_unready_percentage           = optional(number, 45)
    new_pod_scale_up_delay           = optional(string, "10s")
    scale_down_delay_after_add       = optional(string, "10m")
    scale_down_delay_after_delete    = optional(string, "10s")
    scale_down_delay_after_failure   = optional(string, "3m")
    scan_interval                    = optional(string, "10s")
    scale_down_unneeded              = optional(string, "10m")
    scale_down_unready               = optional(string, "20m")
    scale_down_utilization_threshold = optional(number, 0.5)
    empty_bulk_delete_max            = optional(number, 10)
    skip_nodes_with_local_storage    = optional(bool, true)
    skip_nodes_with_system_pods      = optional(bool, true)
  })
  default = null
}

variable "oms_agent" {
  description = "OMS Agent configuration."
  type = object({
    log_analytics_workspace_id      = optional(string)
    msi_auth_for_monitoring_enabled = optional(bool, true)
  })
}

variable "azure_policy_enabled" {
  description = "Option to enable Azure Policy add-on."
  type        = bool
  nullable    = false
  default     = true
}

variable "linux_profile" {
  description = "Username and SSH public key for accessing Linux nodes with SSH."
  type = object({
    username = string
    ssh_key  = string
  })
  default = null
}

variable "service_cidr" {
  description = "CIDR used by Kubernetes services (kubectl get svc)."
  type        = string
  nullable    = false
}

variable "aks_pod_cidr" {
  description = "CIDR used by pods when network plugin is set to `kubenet` or `azure` CNI Overlay."
  type        = string
  default     = null
}

variable "outbound_type" {
  description = "The outbound (egress) routing method which should be used. Possible values are `loadBalancer` and `userDefinedRouting`."
  type        = string
  nullable    = false
  default     = "loadBalancer"
}

variable "node_pools" {
  description = "A list of Node Pools to create."
  type = list(object({
    name                   = string
    vm_size                = optional(string, "Standard_D2_v3")
    os_sku                 = optional(string, "Ubuntu")
    os_disk_type           = optional(string, "Managed")
    os_disk_size_gb        = optional(number)
    kubelet_disk_type      = optional(string)
    enable_auto_scaling    = optional(bool, false)
    node_count             = optional(number, 1)
    min_count              = optional(number, 1)
    max_count              = optional(number, 10)
    max_pods               = optional(number)
    node_labels            = optional(map(any))
    node_taints            = optional(list(any))
    enable_host_encryption = optional(bool)
    enable_node_public_ip  = optional(bool, false)
    node_subnet = optional(object({
      name                 = optional(string)
      virtual_network_name = optional(string)
      resource_group_name  = optional(string)
    }), {})
    pod_subnet = optional(object({
      name                 = optional(string)
      virtual_network_name = optional(string)
      resource_group_name  = optional(string)
    }), {})
    priority             = optional(string)
    eviction_policy      = optional(string)
    orchestrator_version = optional(string)
    zones                = optional(list(number), [1, 2, 3])
    tags                 = optional(map(string), {})
  }))
  nullable = false
  default  = []
}

variable "container_registries_ids" {
  description = "List of Azure Container Registries IDs where Azure Kubernetes Service needs pull access."
  type        = list(string)
  nullable    = false
  default     = []
}

variable "oidc_issuer_enabled" {
  description = "Whether the OIDC issuer URL should be enabled."
  type        = bool
  nullable    = false
  default     = true
}

variable "workload_identity_enabled" {
  description = "Whether Azure AD Workload Identity should be enabled for the cluster. `oidc_issuer_enabled` must be set to true to use this feature."
  type        = bool
  nullable    = false
  default     = true
}

variable "key_vault_secrets_provider" {
  description = "Enable AKS built-in Key Vault secrets provider. If enabled, an identity is created by the AKS itself and exported from this module."
  type = object({
    secret_rotation_enabled  = optional(bool, true)
    secret_rotation_interval = optional(string)
  })
  default = {}
}

variable "vnet_integration" {
  description = "Virtual Network integration configuration."
  type = object({
    enabled   = optional(bool, false)
    subnet_id = optional(string)
  })
  nullable = false
  default  = {}
  validation {
    condition     = !var.vnet_integration.enabled || var.vnet_integration.subnet_id != null
    error_message = "var.vnet_integration.subnet_id must be set when VNet integration is enabled."
  }
}
