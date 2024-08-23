terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.86"
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
      source  = "azure/azapi"
      version = "~> 1.9, < 1.13"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
