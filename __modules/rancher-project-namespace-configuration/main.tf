resource "rancher2_project" "project" {
  name        = var.project_name
  description = var.project_description
  cluster_id  = var.cluster_id

  resource_quota {
    namespace_default_limit {
      limits_cpu       = var.namespace_default_limit.limits_cpu
      limits_memory    = var.namespace_default_limit.limits_memory
      requests_storage = var.namespace_default_limit.requests_storage
    }
    project_limit {
      limits_cpu       = var.project_limit.limits_cpu
      limits_memory    = var.project_limit.limits_memory
      requests_storage = var.project_limit.requests_storage
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "rancher2_namespace" "namepace" {
  for_each = toset(var.namespaces)

  name       = each.value
  project_id = rancher2_project.project.id
  labels = {
    "created_by"   = "terraform"
    "from_project" = var.project_name
    "teams" = join("_", [
      for binding in var.project_members : binding.group
    ])
  }
  resource_quota {
    limit {
      limits_cpu       = var.namespace_default_limit.limits_cpu
      limits_memory    = var.namespace_default_limit.limits_memory
      requests_storage = var.namespace_default_limit.requests_storage
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "rancher2_project_role_template_binding" "role_template_binding" {
  for_each = tomap({
    for team in var.project_members : "${var.project_name}-${team.train}-${team.group}" => team
  })
  name               = substr("${var.project_name}-${each.value.group}-${data.rancher2_role_template.user_permissions_project.name}", 0, 63)
  project_id         = rancher2_project.project.id
  role_template_id   = data.rancher2_role_template.user_permissions_project.id
  group_principal_id = "openldap_group://CN=${each.value.group},OU=${each.value.train},OU=DSI-TRAINS,OU=Ressources,DC=sacem,DC=fr"
}

resource "rancher2_cluster_role_template_binding" "cluster_binding" {
  for_each = tomap({
    for team in var.project_members : "${var.project_name}-${team.train}-${team.group}" => team
  })
  name               = substr("${var.project_name}-${each.value.group}-${data.rancher2_role_template.cluster_reader.name}", 0, 63)
  role_template_id   = data.rancher2_role_template.cluster_reader.id
  cluster_id         = var.cluster_id
  group_principal_id = "openldap_group://CN=${each.value.group},OU=${each.value.train},OU=DSI-TRAINS,OU=Ressources,DC=sacem,DC=fr"
}

