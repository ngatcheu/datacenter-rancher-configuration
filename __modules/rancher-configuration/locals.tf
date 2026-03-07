locals {
  cluster_owners = flatten([
    for cluster_key, cluster_value in var.cluster_list : [
      for owner_key, owner_value in cluster_value.owners : {
        cluster_key        = cluster_key
        owner_key          = owner_key
        name               = "${cluster_key}-${owner_key}-owner"
        cluster_id         = rancher2_cluster.downstream_cluster[cluster_key].id
        role_template_id   = "cluster-owner"
        group_principal_id = "openldap_group://cn=${owner_value.group},${var.ldap.group_search_base}"
      }
    ]
  ])
}