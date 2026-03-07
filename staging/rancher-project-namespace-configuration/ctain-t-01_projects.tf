locals {
  project_limit = {
    limits_cpu       = "6000m"
    limits_memory    = "2000Mi"
    requests_storage = "2Gi"
  }
  namespace_default_limit = {
    limits_cpu       = "2000m"
    limits_memory    = "500Mi"
    requests_storage = "1Gi"
  }
}

module "projects_platform_core_ctain_t_01" {
  source              = "../../__modules/rancher-project-namespace-configuration"
  project_name        = "platform-core"
  namespaces          = ["backend-ns", "frontend-ns", "database-ns"]
  project_description = "Project for core platform services in ctain-t-01 cluster"
  cluster_id          = data.terraform_remote_state.rancher_cluster_configurtion.outputs.rancher2_cluster["ctain-t-01"].cluster_id
  project_members = [
    {
      train = "Plateforme"
      group = "dsi-train-plt-middleware"
    }
  ]
  project_limit = {
    limits_cpu       = "6000m"
    limits_memory    = "2000Mi"
    requests_storage = "3Gi"
  }
  namespace_default_limit = {
    limits_cpu       = "2000m"
    limits_memory    = "500Mi"
    requests_storage = "1Gi"
  }
}


module "projects_analytics_pipeline_ctain_t_01" {
  source                  = "../../__modules/rancher-project-namespace-configuration"
  project_name            = "analytics-pipeline"
  namespaces              = ["data-processing-ns", "reporting-ns"]
  cluster_id              = data.terraform_remote_state.rancher_cluster_configurtion.outputs.rancher2_cluster["ctain-t-01"].cluster_id
  project_description     = "Project for analytics pipeline services in ctain-t-01 cluster"
  project_limit           = local.project_limit
  namespace_default_limit = local.namespace_default_limit
  project_members = [
    {
      train = "Plateforme"
      group = "dsi-train-plt-usine-logicielle"
    }
  ]
}



module "projects_microservices_api_ctain_t_01" {
  source                  = "../../__modules/rancher-project-namespace-configuration"
  project_name            = "microservices-api"
  namespaces              = ["prometheus-ns", "grafana-ns"]
  project_description     = "Project for microservices API monitoring in ctain-t-01 cluster"
  cluster_id              = data.terraform_remote_state.rancher_cluster_configurtion.outputs.rancher2_cluster["ctain-t-01"].cluster_id
  project_limit           = local.project_limit
  namespace_default_limit = local.namespace_default_limit
  project_members = [
    {
      train = "Plateforme"
      group = "dsi-train-plt-usine-logicielle"
    }
  ]
}

