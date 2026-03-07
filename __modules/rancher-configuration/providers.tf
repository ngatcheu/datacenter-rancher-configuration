terraform {
  required_version = "~> 1.14"
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 13.0"
    }
  }
}
