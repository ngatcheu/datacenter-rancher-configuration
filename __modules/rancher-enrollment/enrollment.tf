locals {
  # Clusters avec SSH (master_ip renseigné et non "local") — pas de local-exec en CI
  remote_clusters = {
    for k, v in var.clusters_to_enroll : k => v
    if v.master_ip != "" && v.master_ip != "local"
  }
}

# Téléchargement du manifest d'enrollment depuis la machine Terraform (qui a accès à Rancher)
data "http" "rancher_manifest" {
  for_each = local.remote_clusters

  url = each.value.manifest_url

  # Autorise les certificats auto-signés (homelab)
  insecure = true
}

resource "terraform_data" "enroll_cluster" {
  for_each = local.remote_clusters

  triggers_replace = [
    each.value.kubectl_command
  ]

  connection {
    type        = "ssh"
    host        = each.value.master_ip
    user        = each.value.master_user
    private_key = var.ssh_private_key
    timeout     = var.ssh_timeout
  }

  # Ajout des entrées /etc/hosts manquantes (idempotent)
  provisioner "remote-exec" {
    inline = [for hostname, ip in var.extra_hosts :
      "grep -qF '${ip} ${hostname}' /etc/hosts || echo '${ip} ${hostname}' | sudo tee -a /etc/hosts"
    ]
  }

  # Upload du manifest depuis la machine Terraform → pas de curl depuis le nœud
  provisioner "file" {
    content     = data.http.rancher_manifest[each.key].response_body
    destination = "/tmp/rancher-agent-${each.key}.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "KUBECTL='/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml'",
      "if sudo $KUBECTL get namespace cattle-system 2>/dev/null; then",
      "  if sudo $KUBECTL get deployment cattle-cluster-agent -n cattle-system 2>/dev/null; then",
      "    echo 'Cluster ${each.key} already enrolled (cattle-system and agent present), skipping.'",
      "    rm -f /tmp/rancher-agent-${each.key}.yaml",
      "    exit 0",
      "  fi",
      "  echo 'ERROR: namespace cattle-system exists but cluster not fully enrolled. Wait for cleanup or fix manually.'",
      "  exit 1",
      "fi",
      "echo 'Enrolling cluster ${each.key} into Rancher...'",
      "sudo $KUBECTL apply -f /tmp/rancher-agent-${each.key}.yaml",
      "rm -f /tmp/rancher-agent-${each.key}.yaml",
      "echo 'Enrollment command executed for ${each.key}'"
    ]
  }
}
