variable "ldap_service_account_username_dn" {
  description = "Nom d'utilisateur du compte de service LDAP"
  type        = string
  sensitive   = true
}

variable "ldap_service_account_username" {
  description = "Nom d'utilisateur du compte de service LDAP"
  type        = string
  sensitive   = true
}

variable "ldap_service_account_password" {
  description = "Mot de passe du compte de service LDAP"
  type        = string
  sensitive   = true
}

variable "rancher_ca_cert" {
  description = "CA certificate PEM pour Rancher (cacerts setting)"
  type        = string
  default     = ""
}



variable "ldap_test_password" {
  description = "Mot de passe de ldap.test_username, utilisé par Rancher pour valider la connexion LDAP (TF_VAR_ldap_test_password, depuis le vault de datacenter-openldap-playbooks)."
  type        = string
  sensitive   = true
}
