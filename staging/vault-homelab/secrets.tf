locals {
  cluster = "clusterpayload"
  env     = "staging"
}

resource "vault_kv_secret_v2" "openldap" {
  mount = vault_mount.kv.path
  name  = "middleware/${local.env}/${local.cluster}/openldap/openldap-secret"

  data_json = jsonencode({
    admin-password  = var.secrets["openldap_admin_password"]
    config-password = var.secrets["openldap_config_password"]
  })
}

resource "vault_kv_secret_v2" "phpipam" {
  mount = vault_mount.kv.path
  name  = "middleware/${local.env}/${local.cluster}/phpipam/phpipam-secret"

  data_json = jsonencode({
    database-password = var.secrets["phpipam_database_password"]
  })
}

resource "vault_kv_secret_v2" "harbor" {
  mount = vault_mount.kv.path
  name  = "middleware/${local.env}/${local.cluster}/harbor/harbor-secret"

  data_json = jsonencode({
    harborAdminPassword = var.secrets["harbor_admin_password"]
    secretKey           = var.secrets["harbor_secret_key"]
  })
}

resource "vault_kv_secret_v2" "adminer_basic_auth" {
  mount = vault_mount.kv.path
  name  = "middleware/${local.env}/${local.cluster}/adminer/adminer-basic-auth"

  data_json = jsonencode({
    auth = var.secrets["adminer_basic_auth"]
  })
}

# Mot de passe de démarrage de Rancher (VaultStaticSecret rancher-bootstrap-secret,
# cluster Rancher) : sans lui, la HelmRelease rancher reste bloquée.
resource "vault_kv_secret_v2" "rancher" {
  mount = vault_mount.kv.path
  name  = "middleware/${local.env}/clusterrancher/rancher/rancher-secret"

  data_json = jsonencode({
    bootstrapPassword = var.secrets["rancher_bootstrap_password"]
  })
}

resource "vault_kv_secret_v2" "warap_db" {
  mount = vault_mount.kv.path
  name  = "warap/${local.env}/${local.cluster}/warap/warap-db-secret"

  data_json = jsonencode({
    username = var.secrets["warap_db_username"]
    password = var.secrets["warap_db_password"]
  })
}
