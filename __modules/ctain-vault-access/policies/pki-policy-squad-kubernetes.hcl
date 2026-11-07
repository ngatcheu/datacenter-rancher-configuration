path "${mount_path}/issue/${pki_role_name}" {
  capabilities = ["update"]
}
 
# Permet de lire la CA racine/intermédiaire (utile pour inclure ca.crt dans les Secrets)
path "${mount_path}/cert/ca" {
  capabilities = ["read"]
}
 
# Permet de lire la CRL (utile pour vérifier la révocation)
path "${mount_path}/crl" {
  capabilities = ["read"]
}