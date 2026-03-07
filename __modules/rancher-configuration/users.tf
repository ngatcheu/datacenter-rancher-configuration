resource "rancher2_global_role_binding" "ldap_binding" {
  for_each = var.global_role_bindings

  name               = "${each.key}-ldap-binding"
  global_role_id     = each.value.global_role_id
  group_principal_id = "openldap_group://cn=${each.value.group_cn},${var.ldap.group_search_base}"
}

