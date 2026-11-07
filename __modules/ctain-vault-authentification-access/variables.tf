variable "cluster_name" {
  description = "The name of the Kubernetes cluster, used to create a unique auth path."
  type        = string
}

variable "kubernetes_cluster_public_key" {
  description = "The PEM-encoded public key from the Kubernetes cluster for validating service account JWTs."
  type        = string
}

variable "vault_secret_operator_policy_name" {
  description = "value"
  type        = string
}