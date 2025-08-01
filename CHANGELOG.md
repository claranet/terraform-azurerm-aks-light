## 8.5.1 (2025-08-01)

### Bug Fixes

* **AZ-1600:** duration setting in node_os_update_schedule 0482001

## 8.5.0 (2025-08-01)

### Features

* add maintenance window node OS parameters df7e706

### Miscellaneous Chores

* 🗑️ remove old commitlint configuration files 4a9c0fa
* **deps:** update dependency opentofu to v1.10.3 d1f3d73
* **deps:** update dependency tflint to v0.58.1 3ef3587
* **deps:** update tools 0b113a5
* **deps:** update tools eef8b09

## 8.4.4 (2025-06-27)

### Bug Fixes

* **AZ-1574:** 🐛 add `upgrade_override` bloc 144de23
* **AZ-1574:** add upgrade_override bloc 28b8b92

### Miscellaneous Chores

* **deps:** update dependency opentofu to v1.10.1 98f7865

## 8.4.3 (2025-06-24)

### Bug Fixes

* **AZ-1573:** 🐛 update node pool configuration for spot instances aea2107
* **AZ-1573:** 🐛 update node taints configuration for spot instances d45f1f2

### Miscellaneous Chores

* **⚙️:** ✏️ update template identifier for MR review 51188b6
* **deps:** update dependency opentofu to v1.10.0 1e2968d
* **deps:** update dependency tflint to v0.57.0 e2a30da
* **deps:** update dependency tflint to v0.58.0 75c67ba
* **deps:** update dependency trivy to v0.62.0 151f7e5
* **deps:** update dependency trivy to v0.62.1 c3f4d5c
* **deps:** update dependency trivy to v0.63.0 3e8e41d
* **deps:** update pre-commit hook tofuutils/pre-commit-opentofu to v2.2.1 50065cc

## 8.4.2 (2025-04-29)

### Bug Fixes

* **AZ-1549:** add `Network Contributor` role to User Assigned Identity on the VNET when `var.private_dns_zone_type` is set to `Custom` fdbb0c2
* **AZ-1549:** exclude network contributor on subnet if activated on VNET b98c81d

### Miscellaneous Chores

* **changelog:** ✏️ fix formatting for tenant_id and api_server_access_profile 7c5a610
* **deps:** update dependency opentofu to v1.9.1 6ee586e
* **deps:** update dependency terraform-docs to v0.20.0 d23de2d
* **deps:** update dependency tflint to v0.56.0 b6a8671
* **deps:** update dependency trivy to v0.61.0 dd25507
* **deps:** update dependency trivy to v0.61.1 643cbc7
* **deps:** update pre-commit hook tofuutils/pre-commit-opentofu to v2.2.0 7ebff01

## 8.4.1 (2025-03-21)

### Bug Fixes

* update `azure_active_directory_role_based_access_control` ce9cb4c
* update `tenant_id` variable in `azure_active_directory_role_based_access_control` bloc a061ca1

### Miscellaneous Chores

* **deps:** update dependency pre-commit to v4.2.0 e73c5b7
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.22.0 0077883

## 8.4.0 (2025-03-07)

### Features

* update no proxy list 1b7275a

### Miscellaneous Chores

* **deps:** update dependency trivy to v0.60.0 de0f230

## 8.3.0 (2025-02-28)

### Features

* **AZ-1531:** add `temporary_name_for_rotation` support for node pool resources 850c41d

## 8.2.1 (2025-02-24)

### Bug Fixes

* **AZ-1527:** deprecated api version 1a4b832

### Miscellaneous Chores

* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.21.0 5369a58

## 8.2.0 (2025-02-07)

### Features

* **AZ-1512:** set `api_server_access_profile` as dynamic 2b1e6f4

### Miscellaneous Chores

* **deps:** update dependency trivy to v0.59.1 a658643

## 8.1.0 (2025-02-04)

### Features

* add microsoft defender 423cb05

### Miscellaneous Chores

* **deps:** update tools c27f38f
* update Github templates 982d57e

## 8.0.0 (2025-01-24)

### ⚠ BREAKING CHANGES

* **AZ-1088:** module standardization

### Features

* **AZ-1088:** bump azapi v2 + use provider function 5be9b14
* **AZ-1088:** enable blob csi driver by default 16af51b
* **AZ-1088:** global rework 50c80a9
* **AZ-1088:** rework module fbcfef1
* **AZ-1088:** rework node_pools variable 3430dc0
* **AZ-1088:** rework variables 5a3ff2e

### Bug Fixes

* **AZ-1088:** force image cleaner interval default value to 24 as the default provider value (0) is not supported by the API 984635f

### Documentation

* **AZ-1088:** add storage_use_azuread provider option in examples 6f35fde
* **AZ-1088:** bump terraform min version in examples 4a5600d
* **AZ-1088:** fix example 0c3a615
* **AZ-1088:** fix typo 53a4979

### Miscellaneous Chores

* **deps:** update dependency azuread to v3 13f3e01
* **deps:** update dependency claranet/diagnostic-settings/azurerm to v8 907bb1c
* **deps:** update dependency opentofu to v1.8.6 3ae932a
* **deps:** update dependency opentofu to v1.8.8 a9b650f
* **deps:** update dependency opentofu to v1.9.0 dabbeb9
* **deps:** update dependency pre-commit to v4.1.0 42a8958
* **deps:** update dependency tflint to v0.54.0 49d931f
* **deps:** update dependency tflint to v0.55.0 dbb5ab6
* **deps:** update dependency trivy to v0.57.1 57611cb
* **deps:** update dependency trivy to v0.58.1 125f2bf
* **deps:** update dependency trivy to v0.58.2 cd38a40
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.19.0 5cb3088
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.20.0 74cbce4
* **deps:** update tools 8ae8613
* **deps:** update tools 65bd4e9
* update tflint config for v0.55.0 8afdf0b

## 7.11.0 (2024-10-25)

### Features

* support for `cost_analysis_enabled` property of azurerm_kubernetes_cluster 9e8a64f

### Miscellaneous Chores

* **deps:** update dependency claranet/diagnostic-settings/azurerm to v7 6ef7275
* **deps:** update dependency opentofu to v1.8.3 6b5dfd4
* **deps:** update dependency opentofu to v1.8.4 1de12c1
* **deps:** update dependency pre-commit to v4 8fec423
* **deps:** update dependency pre-commit to v4.0.1 8fd017a
* **deps:** update dependency trivy to v0.56.1 10d4443
* **deps:** update dependency trivy to v0.56.2 2d9c47b
* **deps:** update pre-commit hook pre-commit/pre-commit-hooks to v5 dafb3ae
* **deps:** update pre-commit hook tofuutils/pre-commit-opentofu to v2.1.0 8d91bcb
* prepare for new examples structure 712b9f9
* require AzureRM `v3.106+` 1944857, closes /github.com/hashicorp/terraform-provider-azurerm/blob/main/CHANGELOG-v3.md#31060-may-31-2024
* update examples structure 99a8611

## 7.10.0 (2024-10-03)

### Features

* **AZ-1462:** add linux_os_config block 06f6eb3

### Documentation

* **AZ-1462:** update README 139c7df

### Miscellaneous Chores

* **AZ-1462:** apply suggestion 54fdcf4
* **deps:** update dependency trivy to v0.56.0 52a4d8a

## 7.9.0 (2024-10-03)

### Features

* use Claranet "azurecaf" provider 80d66ca

### Documentation

* update README badge to use OpenTofu registry 30b200e
* update README with `terraform-docs` v0.19.0 1aaffe3

### Miscellaneous Chores

* **deps:** update dependency opentofu to v1.8.2 239fae9
* **deps:** update dependency terraform-docs to v0.19.0 9a535ab
* **deps:** update dependency trivy to v0.55.0 f00c187
* **deps:** update dependency trivy to v0.55.1 bdc3c74
* **deps:** update dependency trivy to v0.55.2 cac1912
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.18.0 34060a5
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.1 9c89ac6
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.2 144f5fb
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.3 e8038e5
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.95.0 986d254
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.96.0 74cfc2e
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.96.1 d47b1ca

## 7.8.0 (2024-08-30)

### Features

* **AZ-1450:** image cleaner support 88e3386

### Miscellaneous Chores

* default `interval_hours` to null d599eba
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.17.0 4098886
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.3 7a38e84
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.93.0 243a341
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.0 7ccb397

## 7.7.1 (2024-08-23)

### Documentation

* update README d239885

### Code Refactoring

* remove use of deprecated default_node_pool.node_taints d1dfa09, closes #12

### Miscellaneous Chores

* bump minimum required AzureRM provider cdb2059
* **deps:** update dependency opentofu to v1.7.3 d4af9b5
* **deps:** update dependency opentofu to v1.8.0 90cba62
* **deps:** update dependency opentofu to v1.8.1 ee89cb0
* **deps:** update dependency pre-commit to v3.8.0 43fa6de
* **deps:** update dependency tflint to v0.51.2 c8aae76
* **deps:** update dependency tflint to v0.52.0 8534e1e
* **deps:** update dependency tflint to v0.53.0 b93352c
* **deps:** update dependency trivy to v0.52.2 7f194ef
* **deps:** update dependency trivy to v0.53.0 99b077d
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.0 66a3b70
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.2 bc2cfe5
* **deps:** update tools 533d8ae

## 7.7.0 (2024-06-14)


### Features

* **AZ-1424:** add `storage_profile` block e59bdb2


### Miscellaneous Chores

* **deps:** update dependency opentofu to v1.7.2 766c8df
* **deps:** update dependency trivy to v0.52.0 14cbcee
* **deps:** update dependency trivy to v0.52.1 6f6ec5a

## 7.6.0 (2024-05-31)


### Features

* **AZ-1416:** add maintenance window configuration cd8431f


### Miscellaneous Chores

* **AZ-1416:** bump AzureRM min version to 3.63 3befa97
* **AZ-1416:** update Example and variable description 020b414
* **deps:** update dependency opentofu to v1.7.0 8f35463
* **deps:** update dependency opentofu to v1.7.1 1719b82
* **deps:** update dependency pre-commit to v3.7.1 b00435a
* **deps:** update dependency terraform-docs to v0.18.0 52f461d
* **deps:** update dependency tflint to v0.51.0 a8a22cc
* **deps:** update dependency tflint to v0.51.1 9ebdf16
* **deps:** update dependency trivy to v0.51.0 a69eb0b
* **deps:** update dependency trivy to v0.51.1 1cda4ad
* **deps:** update dependency trivy to v0.51.2 bbcadae
* **deps:** update dependency trivy to v0.51.3 7fe2729
* **deps:** update dependency trivy to v0.51.4 4e66369

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
