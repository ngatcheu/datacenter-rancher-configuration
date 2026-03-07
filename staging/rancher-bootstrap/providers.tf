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
  api_url   = "https://rancher.homelab.local"
  insecure  = true
  bootstrap = true
}
