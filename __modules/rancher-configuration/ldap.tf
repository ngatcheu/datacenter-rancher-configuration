
# LDAP configuration — OpenLDAP
resource "rancher2_auth_config_openldap" "openldap" {
  servers                            = [var.ldap.url]
  port                               = var.ldap.port
  connection_timeout                 = 5000
  service_account_distinguished_name = var.ldap_service_account_username_dn
  service_account_password           = var.ldap_service_account_password

  # Utilisateurs
  user_search_base      = var.ldap.user_search_base
  user_object_class     = "inetOrgPerson"
  user_name_attribute   = "cn"
  user_login_attribute  = "uid"
  user_member_attribute = "memberOf"
  user_search_attribute = "uid|sn|givenName"

  # Groupes
  group_search_base              = var.ldap.group_search_base
  group_object_class             = "groupOfUniqueNames"
  group_name_attribute           = "cn"
  group_member_mapping_attribute = "uniqueMember"
  group_member_user_attribute    = "dn"
  group_search_attribute         = "cn"
  group_dn_attribute             = "entryDN"
  nested_group_membership_enabled = false

  test_username = var.ldap_service_account_username
  test_password = var.ldap_test_password
  enabled       = true
}
