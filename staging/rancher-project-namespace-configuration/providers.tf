terraform {
  required_version = "~> 1.14"
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 13.0"
    }
  }
}

provider "rancher2" {
  api_url    = "https://rancher.ctain-d-00-app.sacem.fr"
  access_key = var.rancher_terraform_access_key
  secret_key = var.rancher_terraform_secret_key
  insecure   = true
}
