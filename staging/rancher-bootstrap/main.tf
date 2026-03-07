resource "rancher2_bootstrap" "admin" {
  initial_password = var.rancher_bootstrap_initial_password
  password         = var.rancher_admin_password
}
