resource "azurerm_log_analytics_workspace" "common" {
  name                = local.common.log
  location            = "polandcentral"
  resource_group_name = azurerm_resource_group.common["common"].name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.log_daily_quota_gb

  tags = local.project_tags
}