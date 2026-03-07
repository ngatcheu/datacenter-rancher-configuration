variable "cluster_id" {
  description = "Rancher cluster ID"
  type        = string
}

variable "project_name" {
  description = "Rancher project name"
  type        = string
}

variable "namespaces" {
  description = "List of Rancher namespace names"
  type        = list(string)
}

variable "project_members" {
  description = "A list of members to bind to roles in the project."
  type = list(object({
    train = string
    group = string
  }))
  default = []
}


variable "project_limit" {
  description = "Resource quota for the entire project."
  type = object({
    limits_cpu       = optional(string)
    limits_memory    = optional(string)
    requests_storage = optional(string)
  })
  default = {
    limits_cpu       = "2000m"
    limits_memory    = "2000Mi"
    requests_storage = "2Gi"
  }
}

variable "namespace_default_limit" {
  description = "Default resource quota for each namespace in the project."
  type = object({
    limits_cpu       = optional(string)
    limits_memory    = optional(string)
    requests_storage = optional(string)
  })
}

variable "project_description" {
  description = "A description for the Rancher project."
  type        = string
}