terraform {
  required_version = "~> 1.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.8"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.3"
    }
  }

}

provider "azurerm" {
  features {
    key_vault {
      # tylko na potrzeby wczesnego developmentu/testów — usunąć później
      purge_soft_deleted_keys_on_destroy = true
      recover_soft_deleted_keys          = true
    }
  }
}
