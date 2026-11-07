# ==============================================================================
# PKI des certificats HTTPS des Gateways Traefik (VaultPKISecret de
# catalog-gitops-fluxcd/infra/secrets/vso-pki-secrets, rôle homelab-server).
# La CA importée est la Home Lab CA : déjà de confiance sur les nœuds
# (make ca-distribute) et utilisée par l'issuer cert-manager homelab-ca-issuer.
# ==============================================================================

resource "vault_mount" "pki" {
  path                  = "pki"
  type                  = "pki"
  description           = "PKI homelab (Home Lab CA)"
  max_lease_ttl_seconds = 315360000 # 10 ans
}

resource "vault_pki_secret_backend_config_ca" "homelab" {
  backend    = vault_mount.pki.path
  pem_bundle = "${file(var.pki_ca_cert_path)}${file(var.pki_ca_key_path)}"
}

resource "vault_pki_secret_backend_role" "homelab_server" {
  backend = vault_mount.pki.path
  name    = "homelab-server"

  allowed_domains             = ["homelab.local"]
  allow_subdomains            = true
  allow_bare_domains          = true
  allow_wildcard_certificates = true
  key_type                    = "rsa"
  key_bits                    = 2048
  max_ttl                     = "31536000" # 1 an

  depends_on = [vault_pki_secret_backend_config_ca.homelab]
}

resource "vault_policy" "pki_homelab_server" {
  name   = "pki-homelab-server"
  policy = <<-EOT
    path "${vault_mount.pki.path}/issue/${vault_pki_secret_backend_role.homelab_server.name}" { capabilities = ["update"] }
    path "${vault_mount.pki.path}/cert/ca"              { capabilities = ["read"] }
    path "${vault_mount.pki.path}/crl"                  { capabilities = ["read"] }
  EOT
}

# VaultAuth vault-pki-auth (namespace platform-network-gateway) de chaque cluster.
resource "vault_jwt_auth_backend_role" "pki" {
  for_each = module.vault_authentification_access

  backend   = each.value.vault_jwt_auth_backend_path
  role_name = "pki-${each.key}-middleware-staging"
  role_type = "jwt"

  user_claim        = "sub"
  bound_audiences   = ["middleware"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "system:serviceaccount:platform-network-gateway:pki-vault-auth"
  }
  token_policies = [vault_policy.pki_homelab_server.name]
  token_ttl      = 86400
}
