terraform {
  required_version = "~> 1.14"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">=4.6.0"
    }
  }
}

# Adresse surchargeable (TF_VAR_vault_address) : au bootstrap, la Gateway n'a pas
# encore de certificat, on passe alors par un port-forward (http://127.0.0.1:8200).
provider "vault" {
  address         = var.vault_address
  token           = var.vault_root_token
  skip_tls_verify = true
}
