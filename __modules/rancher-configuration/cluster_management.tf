
resource "rancher2_cluster" "downstream_cluster" {
  for_each = var.cluster_list
  name     = each.key
  lifecycle {
    prevent_destroy = true
  }
}

resource "rancher2_cluster_role_template_binding" "role_by_cluster" {
  for_each = tomap({
    for owner in local.cluster_owners : "${owner.cluster_key}-${owner.owner_key}" => owner
  })
  name               = each.key
  cluster_id         = each.value.cluster_id
  role_template_id   = each.value.role_template_id
  group_principal_id = each.value.group_principal_id
}
