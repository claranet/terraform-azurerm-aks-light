terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.35"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  alias                  = "aks-module"
  host                   = module.aks.aks_kube_config[0].host
  client_certificate     = base64decode(module.aks.aks_kube_config[0].client_certificate)
  client_key             = base64decode(module.aks.aks_kube_config[0].client_key)
  cluster_ca_certificate = base64decode(module.aks.aks_kube_config[0].cluster_ca_certificate)
}
