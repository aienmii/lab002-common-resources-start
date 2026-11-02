resource "azurerm_consumption_budget_subscription" "this" {
  for_each = local.budgets_for_alerts

  name = "Budget-for-${each.key}-usd-subscription-consumption"

  subscription_id = data.azurerm_subscription.current.id
  amount          = each.key
  time_grain      = "Monthly"

  time_period {
    start_date = "2026-11-01T00:00:00Z"
    end_date   = "2027-01-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 70.0
    operator       = "GreaterThan"
    contact_emails = var.contact_emails
  }

  notification {
    enabled        = true
    threshold      = 90.0
    operator       = "GreaterThan"
    contact_emails = var.contact_emails
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = var.contact_emails
  }
}
