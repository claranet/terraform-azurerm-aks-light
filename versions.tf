terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.57"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2, >= 1.2.22"
    }
    # tflint-ignore: terraform_unused_required_providers
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.31"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.5"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
