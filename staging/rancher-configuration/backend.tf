# terraform {
#   backend "remote" {
#     hostname     = "artifactory.prusilo.interne.cloud.sacem.fr"
#     organization = "dsi-train-plt-usine-logicielle-terraformbackend-staging"
#     workspaces {
#       name = "ctain-workspace-factory-rancher-configuration"
#     }
#   }
# }