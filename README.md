# Azure Kubernetes Service
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/aks-light/azurerm/)

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

This modules supersedes the previous [AKS module](https://registry.terraform.io/modules/claranet/aks/azurerm).
We've built a new module to clean up the technical debt that piled up due to fast-moving AKS product and keep backwards
compatibility for existing users. Also, we've decided to remove all Kubernetes resources from this new module as a
[recommended best practice](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources)
and for better tooling responsibility segregation.

So this module does less, that why `light`, but it should do it better.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Related documentation

- Azure Kubernetes Service documentation: [docs.microsoft.com/en-us/azure/aks/](https://docs.microsoft.com/en-us/azure/aks/)
- Azure Kubernetes Service MSI usage: [docs.microsoft.com/en-us/azure/aks/use-managed-identity](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity)
- Azure Kubernetes Service User-Defined Routes usage: [docs.microsoft.com/en-us/azure/aks/egress-outboundtype](https://docs.microsoft.com/en-us/azure/aks/egress-outboundtype)
- Terraform Kubernetes provider documentation: [www.terraform.io/docs/providers/kubernetes/index.html](https://www.terraform.io/docs/providers/kubernetes/index.html)
