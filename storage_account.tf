
# Storage Account dla plików stanu (state) wszystkich labów -- jeden na rok kursu
resource "azurerm_storage_account" "backend" {
  name                = "sttfstate26152579" # Existing backend account; keep stable after state migration
  resource_group_name = azurerm_resource_group.common["common"].name
  # Storage account locations are immutable. This account already backs the
  # remote state, so keep its existing location instead of recreating it when
  # the resource-group location changes.
  location                 = "polandcentral"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  # Bezpieczeństwo
  https_traffic_only_enabled = true # wymusza HTTPS
  min_tls_version            = "TLS1_2"
  # Versioning dla historii state
  blob_properties {
    versioning_enabled       = true
    last_access_time_enabled = true # potrzebne do reguł "dni od ostatniego odczytu"
    # Soft delete jako backup (usunięte obiekty też są płatne -- krótka retencja)
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }
  # Network restrictions (opcjonalnie)
  network_rules {
    default_action = "Allow" # Zmień na "Deny" dla większego bezpieczeństwa
    # ip_rules     = ["YOUR_IP_ADDRESS"]
  }
  tags = merge(local.project_tags, {
    purpose    = "tfstate"
    managed_by = "opentofu"
  })
}


# Kontener dla state files
resource "azurerm_storage_container" "backend" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.backend.id
  container_access_type = "private"
}

# RBAC - uprawnienia do Storage Account dla remote backend
resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = azurerm_storage_account.backend.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# RBAC - uprawnienia dla Service Principal (jeśli używany)
resource "azurerm_role_assignment" "storage_blob_data_contributor_sp" {
  count                = var.sops_principal_object_id != "" ? 1 : 0
  scope                = azurerm_storage_account.backend.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.sops_principal_object_id
}

variable "enable_access_key" {
  description = "Czy włączyć generowanie kluczy dostępu (przydatne dla backup/CI/CD)."
  type        = bool
  default     = true
}

output "backend_config" {
  value = {
    resource_group_name  = azurerm_resource_group.common["common"].name
    storage_account_name = azurerm_storage_account.backend.name
    container_name       = azurerm_storage_container.backend.name
  }
  description = "Backend configuration for OpenTofu"
}

output "access_keys" {
  value = (var.enable_access_key
    ? {
      primary_access_key   = (azurerm_storage_account.backend.primary_access_key)
      secondary_access_key = (azurerm_storage_account.backend.secondary_access_key)
      connection_string    = (azurerm_storage_account.backend.primary_connection_string)
    }
  : null)
  description = "Access keys dla backup/CI/CD (jeśli włączone)"
  sensitive   = true
}
