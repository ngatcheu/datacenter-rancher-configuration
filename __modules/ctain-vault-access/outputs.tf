output "pki_role" {
  description = "Name of the PKI secret backend role created for certificate issuance."
  value       = var.pki_certificate_access.enabled ? vault_pki_secret_backend_role.this[0].name : null
}

output "jwt_auth_role" {
  description = "JWT auth backend role name created for Kubernetes authentication."
  value       = vault_jwt_auth_backend_role.this
}


