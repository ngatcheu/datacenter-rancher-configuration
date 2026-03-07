variable "ldap_service_account_username_dn" {
  description = "DN du compte de service LDAP (rootDN OpenLDAP)"
  type        = string
  sensitive   = true
}

variable "ldap_service_account_username" {
  description = "Identifiant de test pour la vérification LDAP"
  type        = string
  sensitive   = true
}

variable "ldap_service_account_password" {
  description = "Mot de passe du compte de service LDAP (rootDN)"
  type        = string
  sensitive   = true
}

variable "ldap_test_password" {
  description = "Mot de passe de l'utilisateur de test LDAP (fabrice.ngatcheu)"
  type        = string
  sensitive   = true
}

# ─── Rancher API (après bootstrap) ───────────────────────────────────────────
variable "rancher_token_key" {
  description = "Token admin Rancher (issu de make bootstrap-show-token)"
  type        = string
  sensitive   = true
}

variable "rancher_ca_cert" {
  description = "Contenu PEM du CA certificate de Rancher. Obtenu via : make config-show-ca"
  type        = string
  sensitive   = true
  default     = ""
}
