path "${kv_mount}/data/${vault_namespace}/${vault_environment}/${cluster_name}/${app_name}/*" {
  capabilities = ["read"]
}

path "${kv_mount}/metadata/${vault_namespace}/${vault_environment}/${cluster_name}/${app_name}/*" {
  capabilities = ["read", "list"]
}
