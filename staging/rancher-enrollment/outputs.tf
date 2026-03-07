output "enrolled_clusters" {
  description = "Liste des clusters enrôlés"
  value       = module.rancher_enrollment.enrolled_clusters
}

output "enrollment_status" {
  description = "Statut de l'enrollment de chaque cluster"
  value       = module.rancher_enrollment.enrollment_status
}
