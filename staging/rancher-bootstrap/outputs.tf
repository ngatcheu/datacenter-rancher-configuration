output "rancher_token_key" {
  description = "Token admin à copier dans rancher-configuration/terraform.tfvars"
  value       = "${rancher2_bootstrap.admin.token_id}:${rancher2_bootstrap.admin.token}"
  sensitive   = true
}
