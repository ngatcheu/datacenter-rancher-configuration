terraform {
  required_providers {
    # required_providers version
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.4"
    }
  }
  # terraform_required_version
  required_version = "~> 1.5"
}

