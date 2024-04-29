## 7.5.0 (2024-04-29)


### Features

* **AZ-1398:** add feature block `monitor_metrics` 7883fc2

## 7.4.2 (2024-04-26)


### Bug Fixes

* **AzAPI:** provider pinned `< v1.13` to avoid breaking changes 7ca614b


### Miscellaneous Chores

* **deps:** update dependency trivy to v0.50.4 a61f32b
* **pre-commit:** update commitlint hook eb251a0
* **release:** remove legacy `VERSION` file 1904a73

## 7.4.1 (2024-04-24)


### Bug Fixes

* **AZ-1396:** fix preconditions a804483


### Continuous Integration

* **AZ-1391:** update semantic-release config [skip ci] a1fe1de


### Miscellaneous Chores

* **deps:** enable automerge on renovate 882f324
* **deps:** update dependency trivy to v0.50.2 5c777ce

## 7.4.0 (2024-04-19)


### Features

* **AZ-1390:** add Azure active directory role based access control cbcabd6


### Continuous Integration

* **AZ-1391:** enable semantic-release [skip ci] 5001712


### Miscellaneous Chores

* **deps:** add renovate.json 3221e08
* **deps:** update renovate.json 728fbe1

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
