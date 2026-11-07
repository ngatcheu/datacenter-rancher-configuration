

resource "vault_jwt_auth_backend" "this" {
  type = "jwt"
  path = var.cluster_name

  description = "JWT auth backend for Kubernetes service account tokens for ${var.cluster_name}"

  bound_issuer = "https://kubernetes.default.svc.cluster.local"

  jwt_validation_pubkeys = [
    chomp(var.kubernetes_cluster_public_key)
  ]
}


resource "vault_jwt_auth_backend_role" "vso_role" {

  backend   = vault_jwt_auth_backend.this.path
  role_name = "auth-role-operator"
  role_type = "jwt"

  user_claim      = "sub"
  bound_subject   = "system:serviceaccount:infra-secrets-vault-secrets-operator:vault-secrets-operator-controller-manager"
  bound_audiences = ["vault"]

  token_policies = [var.vault_secret_operator_policy_name]
  token_ttl      = 3600 # 1 hour
}
