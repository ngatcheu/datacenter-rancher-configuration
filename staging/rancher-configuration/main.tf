module "rancher_configuration" {
  source = "../../__modules/rancher-configuration"

  ldap_service_account_username_dn = var.ldap_service_account_username_dn
  ldap_service_account_username    = var.ldap_service_account_username
  ldap_service_account_password    = var.ldap_service_account_password
  ldap_test_password               = var.ldap_test_password

  cluster_list = {
    payload = {
      master_ip   = "192.168.1.113"
      master_user = "root"
      owners = {
        devops = {
          group = "devops"
          train = "devops"
        }
      }
    }
  }

  global_role_bindings = {
    devops = {
      global_role_id = "admin"
      group_cn       = "devops"
      group_ou       = ""
    }
    middleware = {
      global_role_id = "admin"
      group_cn       = "middleware"
      group_ou       = ""
    }
    usilo = {
      global_role_id = "user"
      group_cn       = "usilo"
      group_ou       = ""
    }
  }

  global_settings = {
    "password-min-length"                  = "12"
    "ingress-ip-domain"                    = "sslip.io"
    "auth-user-info-max-age-seconds"       = "3600"
    "auth-user-session-ttl-minutes"        = "960"
    "auth-token-max-ttl-minutes"           = "129600"
    "kubeconfig-generate-token"            = true
    "kubeconfig-default-token-ttl-minutes" = 43200
    "auth-user-info-resync-cron"           = "0 0 * * *"
    "server-url"                           = "https://rancher.homelab.local"
    "telemetry-opt"                        = "out"
    "hide-local-cluster"                   = false
  }

  feature_flags = {
    "continuous-delivery" = true
    "fleet"               = true
    "multi-cluster-management" = true
    "rke2"                = true
    "uiextension"         = true
  }

  ldap = {
    url               = "192.168.1.119"
    port              = 389
    user_search_base  = "ou=people,dc=devsecops,dc=lan"
    group_search_base = "ou=groups,dc=devsecops,dc=lan"
  }

  rancher_ca_cert = var.rancher_ca_cert
}
