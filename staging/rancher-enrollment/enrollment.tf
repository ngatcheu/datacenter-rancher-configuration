data "terraform_remote_state" "rancher_configuration" {
  backend = "local"

  config = {
    path = "../rancher-configuration/terraform.tfstate"
  }
}

module "rancher_enrollment" {
  source = "../../__modules/rancher-enrollment"

  ssh_private_key = var.ssh_private_key

  # Entrées DNS manquantes sur les nœuds (homelab sans DNS interne complet)
  extra_hosts = {
    "rancher.homelab.local" = "192.168.1.200"
  }

  # Seuls les clusters distants (SSH) sont enrôlés par ce module ; les clusters locaux ne sont pas gérés.
  clusters_to_enroll = {
    for cluster_name, cluster in data.terraform_remote_state.rancher_configuration.outputs.cluster_registration_commands :
    cluster_name => {
      kubectl_command = cluster.kubectl_command
      manifest_url    = cluster.manifest_url
      master_ip       = cluster.master_ip
      master_user     = cluster.master_user
      is_local        = cluster.is_local
    }
    if cluster.master_ip != "" && cluster.master_ip != "local"
  }
}
