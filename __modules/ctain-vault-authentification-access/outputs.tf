output "vault_jwt_auth_backend_path" {
  description = "Path of the Vault JWT auth backend used for Kubernetes authentication."
  value       = vault_jwt_auth_backend.this.path
}

output "name" {
  description = "Name of the JWT auth backend created for Kubernetes authentication."
  value       = vault_jwt_auth_backend.this
}
