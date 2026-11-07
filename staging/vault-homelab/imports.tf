# Ressources créées à la main au bootstrap du 07/11/2026 (Vault neuf : PKI et auth
# clusterpayload nécessaires pour émettre les certificats de la Gateway avant que
# https://vault.homelab.local réponde). Ces blocs les rattachent au state sans les
# recréer ; sans effet une fois importées, ils peuvent alors être supprimés.

import {
  to = vault_mount.pki
  id = "pki"
}

import {
  to = vault_pki_secret_backend_role.homelab_server
  id = "pki/roles/homelab-server"
}

import {
  to = vault_policy.pki_homelab_server
  id = "pki-homelab-server"
}

import {
  to = module.vault_authentification_access["clusterpayload"].vault_jwt_auth_backend.this
  id = "clusterpayload"
}

import {
  to = vault_jwt_auth_backend_role.pki["clusterpayload"]
  id = "auth/clusterpayload/role/pki-clusterpayload-middleware-staging"
}
