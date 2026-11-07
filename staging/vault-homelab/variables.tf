variable "vault_address" {
  description = "Adresse de Vault. Bootstrap (Gateway sans certificat) : http://127.0.0.1:8200 via port-forward."
  type        = string
  default     = "https://vault.homelab.local"
}

variable "vault_root_token" {
  description = "Root token for the homelab Vault instance."
  type        = string
  sensitive   = true
}

variable "clusters" {
  description = "Clusters Kubernetes authentifiés par JWT ; la clé publique de chacun est lue dans cluster-keys/<cluster>.pem."
  type        = list(string)
  default     = ["clusterpayload", "clusterrancher"]
}

variable "pki_ca_cert_path" {
  description = "Certificat de la CA importée dans le montage pki (Home Lab CA, déjà distribuée sur les nœuds)."
  type        = string
  default     = "../../../terragrunt_cluster_kubernetes/live/production/payload/rke2/homelab-ca.crt"
}

variable "pki_ca_key_path" {
  description = "Clé privée de la CA importée dans le montage pki."
  type        = string
  default     = "../../../terragrunt_cluster_kubernetes/live/production/payload/rke2/homelab-ca.key"
}

variable "secrets" {
  description = "Map des secrets applicatifs à stocker dans Vault KV."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "kubernetes_access" {
  description = <<-EOT
    Accès des applis aux secrets KV, par squad et par cluster.
      kubernetes_namespaces : nom court (rôle JWT, chemin KV) => namespace Kubernetes du ServiceAccount
  EOT
  type = map(object({
    cluster_name          = string
    vault_namespace       = string
    vault_environment     = string
    kubernetes_namespaces = map(string)
    pki_certificate_access = object({
      enabled         = bool
      mount_path      = optional(string)
      allowed_domains = optional(list(string))
    })
  }))
  default = {}
}
