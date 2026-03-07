# datacenter-rancher-configuration

Configuration Rancher via Terraform — bootstrap, configuration LDAP/settings, enrôlement des clusters, projets/namespaces.

## Structure

```
staging/
  rancher-bootstrap/                  # Étape 1 : init mot de passe admin + token API
  rancher-configuration/              # Étape 2 : LDAP, settings, global role bindings
  rancher-enrollment/                 # Étape 3 : enrôlement des clusters downstream
  rancher-project-namespace-configuration/  # Étape 4 : projets et namespaces
__modules/
  rancher-bootstrap/
  rancher-configuration/
  rancher-enrollment/
  rancher-project-namespace-configuration/
```

## Prérequis

- Terraform >= 1.5
- Rancher déployé et accessible sur `https://rancher.homelab.local`
- Clé SSH vers les nœuds master des clusters downstream
- OpenLDAP opérationnel

## Workflow initial (premier déploiement)

### 1. Bootstrap — générer le token API

```bash
make bootstrap-init
make bootstrap-apply
make bootstrap-show-token   # → copier la valeur rancher_token_key
```

### 2. Configurer les variables

Éditer `staging/rancher-configuration/terraform.tfvars` :

```hcl
rancher_token_key = "token-xxxxx:yyy..."

ldap_service_account_username_dn = "dc=example,dc=lan"
ldap_service_account_username    = "admin"
ldap_service_account_password    = "secret"
ldap_test_password               = "changeme"
```

**Si Rancher utilise un CA privé (cert-manager)**, récupérer le CA cert :

```bash
# La CA est dans cattle-system/tls-ca (clé tls.crt)
kubectl get secret tls-ca -n cattle-system \
  -o jsonpath='{.data.tls\.crt}' | base64 -d

# Ou depuis un nœud via SSH
ssh root@<rancher-node> \
  "KUBECONFIG=/etc/rancher/rke2/rke2.yaml /var/lib/rancher/rke2/bin/kubectl \
   get secret tls-ca -n cattle-system -o jsonpath='{.data.tls\.crt}' | base64 -d"
```

Ou via `make config-show-ca` si le serveur envoie la chaîne complète.

Ajouter dans `terraform.tfvars` :

```hcl
rancher_ca_cert = <<-EOT
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
EOT
```

> Le `rancher_ca_cert` est indispensable pour que les agents des clusters downstream
> valident le TLS (`CATTLE_CA_CHECKSUM` dans le manifest d'enrollment).

### 3. Appliquer dans l'ordre

```bash
make init
make config-apply       # configure Rancher : LDAP, settings, cacerts
make enrollment-apply   # enrôle les clusters downstream via SSH
make projects-apply     # crée les projets et namespaces
```

## Workflow redeployment (Rancher réinstallé)

Si Rancher est réinstallé from scratch :

```bash
# Détruire les anciens états si besoin
make enrollment-destroy
make config-destroy

# Regénérer un token
make bootstrap-init
make bootstrap-apply
make bootstrap-show-token

# Mettre à jour terraform.tfvars avec le nouveau token (et le CA cert si changé)
# Puis réappliquer
make init
make config-apply
make enrollment-apply
make projects-apply
```

## Commandes disponibles

```
make help
```

| Cible                  | Description                                              |
|------------------------|----------------------------------------------------------|
| `bootstrap-init`       | init Terraform bootstrap                                 |
| `bootstrap-apply`      | initialise le mot de passe admin + génère le token API   |
| `bootstrap-show-token` | affiche le token API Rancher                             |
| `bootstrap-destroy`    | destroy bootstrap                                        |
| `config-init`          | init Terraform rancher-configuration                     |
| `config-plan`          | plan rancher-configuration                               |
| `config-apply`         | applique LDAP, settings, CA cert, global role bindings   |
| `config-destroy`       | destroy rancher-configuration                            |
| `config-show-ca`       | extrait le CA cert depuis le serveur Rancher via TLS     |
| `enrollment-init`      | init Terraform rancher-enrollment                        |
| `enrollment-plan`      | plan rancher-enrollment                                  |
| `enrollment-apply`     | enrôle les clusters downstream via SSH                   |
| `enrollment-destroy`   | destroy rancher-enrollment                               |
| `projects-init`        | init Terraform rancher-project-namespace-configuration   |
| `projects-plan`        | plan projects                                            |
| `projects-apply`       | crée projets et namespaces                               |
| `projects-destroy`     | destroy projects                                         |
| `init`                 | init config + enrollment + projects                      |
| `plan`                 | plan config + enrollment + projects                      |
| `apply`                | apply tous les stacks dans l'ordre                       |
| `destroy`              | destroy tous les stacks en ordre inverse                 |

## Variables SSH

La clé SSH utilisée pour l'enrôlement peut être surchargée :

```bash
make enrollment-apply SSH_KEY=~/.ssh/autre_cle
```

Par défaut : `~/.ssh/id_rsa`.
