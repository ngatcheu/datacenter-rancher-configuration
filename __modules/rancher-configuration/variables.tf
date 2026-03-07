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
  description = "Mot de passe du compte de service LDAP (rootDN)"
  type        = string
  sensitive   = true
}

variable "ldap_test_password" {
  description = "Mot de passe de l'utilisateur de test LDAP (test_username)"
  type        = string
  sensitive   = true
}

variable "cluster_list" {
  description = "Map of downstream clusters to manage in Rancher"
  type = map(object({
    owners = optional(map(object({
      group = string
      train = string
    })), {})
    master_ip   = optional(string, "")
    master_user = optional(string, "root")
    is_local    = optional(bool, false) # true for k3d/kind/minikube clusters
  }))
}

variable "global_role_bindings" {
  description = "Map of global role bindings for LDAP groups"
  type = map(object({
    global_role_id = string
    group_cn       = string
    group_ou       = string
  }))
  default = {}
}

variable "global_settings" {
  description = "Map of global settings to apply in Rancher"
  type        = any
}

variable "feature_flags" {
  description = "Map of feature flags to enable/disable in Rancher"
  type        = map(bool)
  default     = {}
}

variable "ldap" {
  description = "Configuration de la connexion LDAP"
  type = object({
    url               = string
    port              = number
    user_search_base  = string
    group_search_base = string
  })
}

variable "rancher_ca_cert" {
  description = "Contenu PEM du CA certificate de Rancher (setting cacerts). Vide = désactivé."
  type        = string
  sensitive   = true
  default     = ""
}
