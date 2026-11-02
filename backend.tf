terraform {
  backend "azurerm" {
    resource_group_name  = "rg-common-26"
    storage_account_name = "sttfstate26152579"
    container_name       = "tfstate"
    key                  = "2026/lab02/terraform.tfstate"
    use_azuread_auth     = true
  }
}