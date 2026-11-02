# Klucz RSA używany przez SOPS do szyfrowania klucza danych w secrets.yaml.
resource "azurerm_key_vault_key" "sops_encryption_key" {
  count        = var.create_sops_key ? 1 : 0
  name         = var.sops_encryption_key_name
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "RSA"
  key_size     = 4096
  key_opts     = ["decrypt", "encrypt", "unwrapKey", "wrapKey"]

  depends_on = [azurerm_role_assignment.key_vault_crypto_officer]

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [rotation_policy]
  }
}

# Używane, gdy klucz został utworzony wcześniej (np. po ponownym wdrożeniu).
data "azurerm_key_vault_key" "sops_encryption_key" {
  count        = var.create_sops_key ? 0 : 1
  name         = var.sops_encryption_key_name
  key_vault_id = azurerm_key_vault.this.id
}

locals {
  sops_key_id = var.create_sops_key ? azurerm_key_vault_key.sops_encryption_key[0].id : data.azurerm_key_vault_key.sops_encryption_key[0].id

  secrets_file = "${path.module}/secrets.yaml"
  secrets      = fileexists(local.secrets_file) ? data.sops_file.secrets[0].data : {}
}

# Plik jest opcjonalny, aby pierwszy apply mógł utworzyć Key Vault i klucz
# przed zaszyfrowaniem sekretów przez SOPS.
data "sops_file" "secrets" {
  count       = fileexists(local.secrets_file) ? 1 : 0
  source_file = local.secrets_file
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each     = toset(nonsensitive(keys(local.secrets)))
  name         = replace(each.key, "_", "-")
  value        = local.secrets[each.key]
  key_vault_id = azurerm_key_vault.this.id

  tags = merge(local.project_tags, {
    source    = "sops"
    encrypted = "true"
  })

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    azurerm_role_assignment.sops_crypto_user,
    azurerm_role_assignment.key_vault_secrets_officer
  ]
}

output "sops_key_kid" {
  description = "Key identifier (KID) klucza Key Vault używanego przez SOPS."
  value       = local.sops_key_id
}
