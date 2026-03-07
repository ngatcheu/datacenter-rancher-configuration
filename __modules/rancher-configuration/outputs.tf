output "cluster_registration_commands" {
  description = "kubectl commands to import each cluster into Rancher (secure command only)"
  value = {
    for cluster_name, cluster in rancher2_cluster.downstream_cluster :
    cluster_name => {
      cluster_id      = cluster.id
      kubectl_command = cluster.cluster_registration_token[0].command
      manifest_url    = cluster.cluster_registration_token[0].manifest_url
      master_ip       = var.cluster_list[cluster_name].master_ip
      master_user     = var.cluster_list[cluster_name].master_user
      is_local        = try(var.cluster_list[cluster_name].is_local, false)
    }
  }
}

output "clusters_by_name" {
  description = "Map of cluster names to cluster IDs"
  value = {
    for name, cluster in rancher2_cluster.downstream_cluster : name => { cluster_id = cluster.id }
  }
}
