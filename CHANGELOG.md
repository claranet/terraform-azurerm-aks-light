# v7.3.0 - 2024-03-08

Breaking
 * [GH-10](https://github.com/claranet/terraform-azurerm-aks-light/issues/10): manage only one ACR attached to the cluster instead of a list, avoid `for_each/toset` terraform errors

# v7.2.1 - 2024-03-01

Fixed
  * AZ-1364: Drop null/empty values in `no_proxy_list`

# v7.2.0 - 2024-02-23

Added
  * AZ-1348: Add Data Collection Rule management
  * AZ-1351: Add `upgrade_settings` parameter

# v7.1.1 - 2024-02-16

Fixed
  * Fix public cluster configuration example

# v7.1.0 - 2024-01-26

Added
  * AZ-1341: Add `temporary_name_for_rotation` property for default node pool

# v7.0.2 - 2023-12-15

Fixed
  * [GITHUB-5](https://github.com/claranet/terraform-azurerm-aks-light/issues/5)/AZ-1305: Fix `aci_subnet_id` variable usage
  * [GITHUB-8](https://github.com/claranet/terraform-azurerm-aks-light/pull/8): Assign AcrPull role to kubelet identity

# v7.0.1 - 2023-12-05

Fixed
  * [GITHUB-3](https://github.com/claranet/terraform-azurerm-aks-light/pull/3): Fix unescaped backtick in `logs_destinations_ids` description

# v7.0.0 - 2023-09-29

Added
  * AZ-1027: AKS module first release
