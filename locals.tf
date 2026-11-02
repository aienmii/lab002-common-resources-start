locals {
  # Wartości labu wymagane przez naming.tf
  lab            = "002"
  workload       = "main"
  workload_short = null # skrót, gdy workload nie mieści się w limicie nazwy (naming.tf)

  project_name = var.project

  # Tagi zasobów tego repo: tagi wspólne (naming.tf) + nazwa projektu
  project_tags = merge(local.tags, {
    project = local.project_name
  })

  budgets_for_alerts = toset(["10", "20", "50"])

  principal_id = var.sops_principal_object_id != "" ? var.sops_principal_object_id : data.azurerm_client_config.current.object_id
}
