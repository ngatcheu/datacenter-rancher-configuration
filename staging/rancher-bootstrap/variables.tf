variable "rancher_bootstrap_initial_password" {
  description = "Mot de passe initial Rancher (bootstrapPassword du HelmRelease FluxCD)"
  type        = string
  sensitive   = true
}

variable "rancher_admin_password" {
  description = "Nouveau mot de passe admin Rancher après bootstrap"
  type        = string
  sensitive   = true
}
