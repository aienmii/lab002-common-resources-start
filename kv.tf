# Key Vault — główny zasób do przechowywania sekretów
resource "azurerm_key_vault" "this" {
  name                        = local.common.kv
  location                    = "polandcentral"
  resource_group_name         = azurerm_resource_group.common["common"].name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name                    = "standard"
  rbac_authorization_enabled  = true

  tags = local.project_tags

  lifecycle {
    prevent_destroy = true
  }
}

output "key_vault_name" {
  description = "Nazwa wspólnego Key Vault."
  value       = azurerm_key_vault.this.name
}
