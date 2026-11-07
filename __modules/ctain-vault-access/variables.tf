variable "vault_namespace" {
  description = "Vault namespace where the application's secrets engines and policies are managed."
  type        = string
}

variable "vault_environment" {
  description = "The environment in Vault (e.g., staging, production) for the application."
  type        = string
}

variable "vault_jwt_auth_backend_path" {
  description = "The path of the Vault JWT auth backend used for Kubernetes authentication."
  type        = string
}

variable "pki_certificate_access" {
  description = "Configuration for PKI certificate access, including enablement, mount path, and allowed domains."
  type = object({
    enabled         = bool
    mount_path      = optional(string)
    allowed_domains = optional(list(string))
  })
  default = {
    enabled = false
  }
}

variable "kubernetes_namespaces" {
  description = "Applis du squad : nom court (rôle JWT, chemin KV) => namespace Kubernetes de son ServiceAccount *-vault-auth."
  type        = map(string)
}

variable "kv_mount" {
  description = "Point de montage du KV v2 contenant les secrets applicatifs."
  type        = string
  default     = "kv"
}
