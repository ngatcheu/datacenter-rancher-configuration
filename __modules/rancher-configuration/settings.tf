resource "rancher2_setting" "global_settings" {
  for_each = var.global_settings

  name  = each.key
  value = try(tostring(each.value), jsonencode(each.value))
}

# Configure le CA cert privé de Rancher (nécessaire pour que les agents valident le TLS)
resource "rancher2_setting" "cacerts" {
  count = var.rancher_ca_cert != "" ? 1 : 0

  name  = "cacerts"
  value = var.rancher_ca_cert
}