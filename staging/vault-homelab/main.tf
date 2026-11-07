# Clés publiques de signature des ServiceAccounts, une par cluster (cluster-keys/README.md).
# Lues sur disque et non via l'API Rancher : Rancher lui-même a besoin de Vault pour démarrer.
locals {
  cluster_public_keys = {
    for cluster in var.clusters : cluster => file("${path.module}/cluster-keys/${cluster}.pem")
  }
}

# Configure le transit engine pour le Vault Secrets Operator
module "vault_secrets_operator_configuration" {
  source = "../../__modules/vault-secrets-operator"
}

# Configure l'auth JWT pour chaque cluster
module "vault_authentification_access" {
  source   = "../../__modules/ctain-vault-authentification-access"
  for_each = local.cluster_public_keys

  cluster_name                      = each.key
  kubernetes_cluster_public_key     = each.value
  vault_secret_operator_policy_name = module.vault_secrets_operator_configuration.vault_secret_operator_policy_name
}

# Configure le KV secrets engine et les policies pour les apps
module "vault_kubernetes_app_access" {
  for_each = var.kubernetes_access

  source                      = "../../__modules/ctain-vault-access"
  vault_jwt_auth_backend_path = module.vault_authentification_access[each.value.cluster_name].vault_jwt_auth_backend_path
  vault_namespace             = each.value.vault_namespace
  kubernetes_namespaces       = each.value.kubernetes_namespaces
  vault_environment           = each.value.vault_environment
  pki_certificate_access      = each.value.pki_certificate_access
  kv_mount                    = vault_mount.kv.path
}

# Active le KV v2 secrets engine
resource "vault_mount" "kv" {
  path        = "kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV v2 secrets engine for homelab"
}
