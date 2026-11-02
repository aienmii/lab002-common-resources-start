# Resource groups are configured by common_resource_groups in variables.tf and
# named from local.rg in naming.tf.
resource "azurerm_resource_group" "common" {
  for_each = { for k, v in var.common_resource_groups : k => v if v.enabled }

  name     = local.rg[each.key]
  location = var.location

  tags = merge(local.project_tags, {
    labs = each.value.labs
    test = "lab002"
  })
}