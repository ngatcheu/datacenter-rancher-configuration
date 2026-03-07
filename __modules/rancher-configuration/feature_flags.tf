resource "rancher2_feature" "feature_flags" {
  for_each = var.feature_flags

  name  = each.key
  value = each.value
}
