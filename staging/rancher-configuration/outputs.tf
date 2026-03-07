output "cluster_registration_commands" {
  description = "kubectl commands to import each cluster into Rancher"
  value       = module.rancher_configuration.cluster_registration_commands
}

output "rancher2_cluster" {
  description = "Rancher cluster information"
  value       = module.rancher_configuration.clusters_by_name
}
