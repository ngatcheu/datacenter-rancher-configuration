output "enrolled_clusters" {
  description = "List of clusters that were enrolled (remote only; local clusters are not managed by this module)"
  value       = [for k, v in terraform_data.enroll_cluster : k]
}

output "enrollment_status" {
  description = "Status of each cluster enrollment"
  value = {
    for k, v in terraform_data.enroll_cluster : k => {
      id        = v.id
      master_ip = var.clusters_to_enroll[k].master_ip
      type      = "remote"
      status    = "enrolled"
    }
  }
}
