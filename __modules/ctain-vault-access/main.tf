locals {
  squad_name = var.vault_namespace
  name       = "${var.vault_jwt_auth_backend_path}-${local.squad_name}-${var.vault_environment}"
}

# Une clé de kubernetes_namespaces = un nom court d'appli (nom du rôle, chemin KV) ;
# sa valeur = le namespace Kubernetes réel de son ServiceAccount *-vault-auth.
resource "vault_jwt_auth_backend_role" "this" {
  for_each = var.kubernetes_namespaces

  backend   = var.vault_jwt_auth_backend_path
  role_name = "jwt-${local.name}-${each.key}"
  role_type = "jwt"

  bound_audiences   = [local.squad_name]
  user_claim        = "iss"
  bound_claims_type = "glob"
  bound_claims = {
    "sub" = "system:serviceaccount:${each.value}:*-vault-auth"
  }
  token_policies = compact([
    var.pki_certificate_access.enabled ? vault_policy.pki[0].name : null,
    vault_policy.kvv2[each.key].name
  ])
  token_ttl = 86400
}

resource "vault_policy" "kvv2" {
  for_each = var.kubernetes_namespaces

  name = "jwt-${local.name}-${each.key}"
  policy = templatefile("${path.module}/policies/kvv2-policy-squad-kubernetes.hcl", {
    kv_mount          = var.kv_mount
    vault_namespace   = var.vault_namespace
    vault_environment = var.vault_environment
    cluster_name      = var.vault_jwt_auth_backend_path
    app_name          = each.key
  })
}


resource "vault_policy" "pki" {
  count = var.pki_certificate_access.enabled ? 1 : 0


  name = "pki-${local.name}"
  policy = templatefile("${path.module}/policies/pki-policy-squad-kubernetes.hcl", {
    mount_path    = var.pki_certificate_access.mount_path
    pki_role_name = vault_pki_secret_backend_role.this[0].name
  })
}

resource "vault_pki_secret_backend_role" "this" {
  count   = var.pki_certificate_access.enabled ? 1 : 0
  backend = var.pki_certificate_access.mount_path
  name    = "pki-${local.name}"
  ttl     = "7776000"  # 90 days
  max_ttl = "31536000" # 1 year

  # Change this to the domain your app needs a certificate for
  allowed_domains    = var.pki_certificate_access.allowed_domains
  allow_subdomains   = true
  allow_bare_domains = true
  key_type           = "rsa"
  key_bits           = 2048
}