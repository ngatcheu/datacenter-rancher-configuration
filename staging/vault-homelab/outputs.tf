output "vault_jwt_auth_backends" {
  description = "JWT auth backend paths per cluster."
  value = {
    for k, v in module.vault_authentification_access : k => v.vault_jwt_auth_backend_path
  }
}

output "kv_mount_path" {
  description = "KV v2 secrets engine mount path."
  value       = vault_mount.kv.path
}
