variable "clusters_to_enroll" {
  description = "Map of clusters to enroll with their enrollment commands and master IPs"
  type = map(object({
    kubectl_command = string
    manifest_url    = string
    master_ip       = string
    master_user     = string
    is_local        = optional(bool, false)
  }))
}

variable "ssh_private_key" {
  description = "SSH private key content for connecting to cluster masters"
  type        = string
  sensitive   = true
}

variable "ssh_timeout" {
  description = "Timeout for SSH connection"
  type        = string
  default     = "5m"
}

variable "extra_hosts" {
  description = "Entrées /etc/hosts à ajouter sur chaque nœud avant l'enrôlement (ex: {\"rancher.homelab.local\" = \"192.168.1.200\"})"
  type        = map(string)
  default     = {}
}
