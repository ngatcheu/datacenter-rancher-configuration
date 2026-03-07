
data "terraform_remote_state" "rancher_cluster_configurtion" {
  backend = "remote"
  config = {
    hostname     = "artifactory.prusilo.interne.cloud.sacem.fr"
    organization = "dsi-train-plt-usine-logicielle-terraformbackend-staging"
    workspaces = {
      name = "ctain-workspace-factory-rancher-configuration"
    }
  }
}