variable "ssh_private_key" {
  description = "Contenu de la clé SSH privée pour se connecter aux masters"
  type        = string
  sensitive   = true
}
