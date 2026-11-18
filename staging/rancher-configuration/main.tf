module "rancher_configuration" {
  source = "../../__modules/rancher-configuration"

  ldap_service_account_username_dn = "cn=admin,dc=homelab,dc=local"
  ldap_service_account_username    = "admin"
  ldap_service_account_password    = var.ldap_service_account_password

  cluster_list = {
    clusterpayload = {
      master_ip   = "192.168.1.113"
      master_user = "root"
      owners = {
        usilo = {
          group = "usilo"
          train = "groups"
        }
      }
    }
  }

  global_role_bindings = {
    devops = {
      global_role_id = "admin"
      group_cn       = "devops"
      group_ou       = "groups"
    }
    middleware = {
      global_role_id = "admin"
      group_cn       = "middleware"
      group_ou       = "groups"
    }
    usilo = {
      global_role_id = "user"
      group_cn       = "usilo"
      group_ou       = "groups"
    }
  }

  global_settings = {
    "engine-install-url"                   = "https://releases.rancher.com/install-docker/27.5.sh",
    "engine-iso-url"                       = "https://releases.rancher.com/os/latest/rancheros-vmware.iso"
    "password-min-length"                  = "12"
    "ingress-ip-domain"                    = "sslip.io"
    "auth-user-info-max-age-seconds"       = "3600"
    "auth-user-session-ttl-minutes"        = "960"
    "auth-token-max-ttl-minutes"           = "129600"
    "kubeconfig-generate-token"            = true
    "kubeconfig-default-token-ttl-minutes" = 43200
    "auth-user-info-resync-cron"           = "0 0 * * *"
    "server-url"                           = "https://rancher.homelab.local"
    "rke-metadata-config" = {
      "refresh-interval-minutes" : "1440",
      "url" : "https://releases.rancher.com/kontainer-driver-metadata/release-v2.10/data.json"
    }
    "system-default-registry"                  = ""
    "ui-index"                                 = "https://releases.rancher.com/ui/release-2.10/index.html"
    "ui-dashboard-index"                       = "https://releases.rancher.com/dashboard/release-2.10/index.html"
    "ui-offline-preferred"                     = "dynamic"
    "ui-brand"                                 = ""
    "cluster-template-enforcement"             = false
    "telemetry-opt"                            = "out"
    "hide-local-cluster"                       = false
    "agent-tls-mode"                           = "strict"
    "k3s-based-upgrader-uninstall-concurrency" = 5
  }

  feature_flags = {
    "clean-stale-secrets"                            = true
    "continuous-delivery"                            = true
    "fleet"                                          = true
    "harvester"                                      = true
    "harvester-baremetal-container-workload"         = false
    "istio-virtual-service-ui"                       = true
    "legacy"                                         = false
    "multi-cluster-management"                       = true
    "provisioningprebootstrap"                       = false
    "provisioningv2-fleet-workspace-back-population" = false
    "rke1-custom-node-cleanup"                       = true
    "rke1-ui"                                        = true
    "rke2"                                           = true
    "token-hashing"                                  = false
    "ui-sql-cache"                                   = false
    "uiextension"                                    = true
    "unsupported-storage-drivers"                    = false
  }

  ldap = {
    url           = "192.168.1.120" # OpenLDAP sur standalone-1 (datacenter-openldap-playbooks)
    port          = 389
    base_dn       = "dc=homelab,dc=local"
    test_username = "fabrice.ngatcheu"
    test_password = var.ldap_test_password
  }
}