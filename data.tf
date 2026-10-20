# Subskrypcja Azure — krok 2 (budżety)
data "azurerm_subscription" "current" {}

# Konfiguracja klienta Azure — krok 3
data "azurerm_client_config" "current" {}
