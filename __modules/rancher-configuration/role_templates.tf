resource "rancher2_role_template" "user_permissions_project" {
  name        = "user"
  context     = "project"
  description = "Allows a user to manage applications within a project."

  rules {
    api_groups = [""] # The core API group
    resources  = ["pods", "configmaps", "secrets", "services", "persistentvolumeclaims", "pods/log"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }

  rules {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets", "replicasets", "statefulsets"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }

  rules {
    api_groups = ["batch"]
    resources  = ["cronjobs", "jobs"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }


  # # Rule to allow executing into pods for debugging
  # rules {
  #   api_groups = [""]
  #   resources  = ["pods/exec"]
  #   verbs      = ["create"] # 'exec' uses the 'create' verb on the pods/exec subresource
  # }
}

resource "rancher2_role_template" "cluster_reader" {
  name        = "cluster-reader"
  context     = "cluster"
  description = "Provides a comprehensive read-only view of cluster resources."

  role_template_ids = ["projects-view", "clustercatalogs-view"]

  rules {
    api_groups = [""] # The core API group
    resources = [
      "pods",
      "namespaces",
      "secrets",
      "configmaps",
      "services",
      "endpoints",
      "persistentvolumeclaims",
      "serviceaccounts"
    ]
    verbs = ["list", "watch"]
  }

  rules {
    api_groups = [""] # The core API group
    resources = [
      "pods",
      "namespaces",
      "configmaps",
      "services",
      "endpoints",
      "persistentvolumeclaims",
      "serviceaccounts"
    ]
    verbs = ["get"]
  }

  rules {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets", "replicasets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  rules {
    api_groups = ["batch"]
    resources  = ["cronjobs", "jobs"]
    verbs      = ["get", "list", "watch"]
  }

  rules {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses", "networkpolicies"]
    verbs      = ["get", "list", "watch"]
  }

  rules {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list", "watch"]
  }
}