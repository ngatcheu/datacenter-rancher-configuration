# vault-homelab

Workspace Terraform qui configure HashiCorp Vault pour l'intégration avec le Vault Secrets Operator (VSO) sur les clusters Kubernetes.

---

## Glossaire

| Terme | Définition |
|-------|------------|
| **Vault** | Gestionnaire de secrets HashiCorp. Stocke, chiffre et contrôle l'accès aux secrets. |
| **Secret Engine** | Plugin Vault qui gère un type de secret. Ex : `kv` pour les paires clé/valeur, `transit` pour le chiffrement, `pki` pour les certificats. |
| **KV v2** (`kv`) | Secret engine clé/valeur avec versioning. Chaque écriture crée une nouvelle version, l'historique est conservé. |
| **Transit engine** | Secret engine de chiffrement à la volée. Ne stocke pas de données — chiffre/déchiffre des payloads externes. Utilisé ici pour chiffrer le cache VSO. |
| **Mount** | Point de montage d'un secret engine dans Vault. Ex : `kv/` est le mount du KV engine. Analogue à un répertoire racine. |
| **Path** | Chemin complet d'un secret dans Vault. Ex : `kv/warap/staging/clusterpayload/warap/postgres-credentials`. |
| **Auth Backend** | Mécanisme d'authentification dans Vault. Ex : `jwt` permet à un ServiceAccount Kubernetes de prouver son identité via son token JWT. |
| **JWT** (JSON Web Token) | Token signé que Kubernetes attache à chaque ServiceAccount. Vault vérifie la signature avec la clé publique du cluster pour valider l'identité. |
| **Role** | Règle dans un auth backend qui associe une identité (ex : un ServiceAccount) à des policies. Définit qui peut s'authentifier et avec quels droits. |
| **Policy** | Règle d'autorisation dans Vault. Définit quels paths un token peut lire, écrire, lister. Ex : read-only sur `kv/warap/*`. |
| **Token** | Credential Vault obtenu après authentification. Porte les policies associées au role utilisé. |
| **Root Token** | Token avec tous les droits sur Vault. Généré à l'initialisation. À utiliser uniquement pour l'administration. |
| **Unseal** | Opération de déverrouillage de Vault après un redémarrage. Vault démarre scellé (les données sont chiffrées et inaccessibles) jusqu'à fournir suffisamment de clés unseal. |
| **Unseal Key** | Clé partielle générée à l'initialisation de Vault. Il faut en fournir `threshold` (ex : 3 sur 5) pour unsealer. |
| **VSO** (Vault Secrets Operator) | Opérateur Kubernetes qui lit des secrets dans Vault et les synchronise automatiquement vers des Kubernetes Secrets. |
| **VaultConnection** | Ressource Kubernetes (CRD VSO) qui définit l'URL de Vault et les options TLS. Référencée par les VaultAuth. |
| **VaultAuth** | Ressource Kubernetes (CRD VSO) qui définit comment VSO s'authentifie auprès de Vault pour un namespace donné (method, role, ServiceAccount). |
| **VaultStaticSecret** | Ressource Kubernetes (CRD VSO) qui décrit quel secret Vault synchroniser et vers quel Kubernetes Secret. |
| **ServiceAccount** | Identité Kubernetes attachée à un Pod ou utilisée par VSO pour s'authentifier auprès de Vault via JWT. |
| **Squad** | Terme utilisé dans ce projet pour désigner une équipe ou un domaine applicatif. Correspond au `vault_namespace` dans les tfvars — préfixe du path KV. |
| **Namespace K8s** | Espace d'isolation logique dans Kubernetes. Les secrets VSO sont créés dans le même namespace que la VaultStaticSecret. |

---

## Ce que ça fait

- Active le **transit engine** (`vault-secret-operator-transit`) et crée la clé de chiffrement du cache VSO
- Active le **KV v2 engine** (`kv`) pour le stockage des secrets applicatifs
- Crée un **JWT auth backend** par cluster (un backend = un cluster Kubernetes)
- Crée les **roles et policies** par namespace applicatif (accès read-only sur les paths KV du namespace)

## Prérequis

- Vault déployé, initialisé et unsealed sur `https://vault.homelab.local`
- `vault_root_token` valide dans `.env`
- `rancher-enrollment` appliqué (nécessaire pour récupérer les clés publiques des clusters)

## Appliquer

```bash
make env=staging vault-homelab-apply
```

---

## Stocker un secret dans Vault

### Convention de nommage du path KV

```
kv/<squad>/<environment>/<cluster>/<k8s_namespace>/<secret_name>
```

Exemple : `kv/warap/staging/clusterpayload/warap/postgres-credentials`

### Via CLI

```bash
export VAULT_ADDR=https://vault.homelab.local
export VAULT_TOKEN=<root_token>
export VAULT_SKIP_VERIFY=true

vault kv put kv/warap/staging/clusterpayload/warap/postgres-credentials \
  username=warap \
  password=changeme \
  database=warap

# Vérifier
vault kv get kv/warap/staging/clusterpayload/warap/postgres-credentials
```

### Via UI

1. `https://vault.homelab.local` → connexion avec le root token
2. `kv/` → `Create secret`
3. Path : `<squad>/<environment>/<cluster>/<k8s_namespace>/<secret_name>`

---

## Récupérer un secret dans Kubernetes via VSO

Le Vault Secrets Operator synchronise automatiquement les secrets Vault vers des Kubernetes Secrets.

### 1. Créer une VaultAuth dans le namespace applicatif

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
  name: vault-auth
  namespace: warap
spec:
  vaultConnectionRef:
    name: vault-connection
    namespace: vault-secrets-operator-system
  method: jwt
  mount: clusterpayload                              # nom du JWT auth backend = nom du cluster
  jwt:
    role: jwt-clusterpayload-warap-staging-warap     # role créé par Terraform
    serviceAccount: warap-vault-auth                 # ServiceAccount du namespace (pattern *-vault-auth)
    audiences:
      - warap                                        # = vault_namespace dans tfvars
```

### 2. Créer une VaultStaticSecret

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: postgres-credentials
  namespace: warap
spec:
  vaultAuthRef: vault-auth
  mount: kv
  type: kv-v2
  path: warap/staging/clusterpayload/warap/postgres-credentials
  destination:
    name: postgres-credentials    # nom du Kubernetes Secret créé par VSO
    create: true
  refreshAfter: 30s
```

VSO crée le Kubernetes Secret `postgres-credentials` dans `warap` avec les champs `username`, `password`, `database`. Il le resynchronise toutes les 30 secondes.

### Utiliser le secret dans un Pod

```yaml
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgres-credentials
        key: password
```

---

## Ajouter l'accès pour un nouveau namespace

**1. Ajouter dans `terraform.tfvars`** :

```hcl
kubernetes_access = {
  "clusterpayload-<squad>" = {
    cluster_name          = "clusterpayload"
    vault_namespace       = "<squad>"
    vault_environment     = "staging"
    kubernetes_namespaces = ["<k8s-namespace>"]
    pki_certificate_access = {
      enabled = false
    }
  }
}
```

**2. Appliquer** :

```bash
make env=staging vault-homelab-apply
```

Cela crée dans Vault :
- Role JWT : `jwt-clusterpayload-<squad>-staging-<k8s-namespace>`
- Policy : accès read sur `kv/<squad>/staging/clusterpayload/<k8s-namespace>/*`

**3. Créer le ServiceAccount dans le gitops** (`apps/base/<app>/vault-serviceaccount.yaml`) :

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: <app>-vault-auth
  namespace: <k8s-namespace>
```

**4. Créer la `VaultAuth` dans le namespace** (`apps/cluster-payload/<app>/vault-secrets.yaml`) en adaptant l'exemple ci-dessus.

**5. Créer la `VaultStaticSecret`** dans le même fichier pour synchroniser le secret vers un Kubernetes Secret.

---

## ServiceAccount et authentification JWT

### Pourquoi un ServiceAccount ?

Vault utilise la méthode JWT pour vérifier l'identité d'un namespace Kubernetes. Quand VSO veut lire un secret, il présente le **token JWT du ServiceAccount** du namespace. Vault vérifie ce token avec la clé publique du cluster (récupérée automatiquement par le module `retrieve-publics-keys`) et autorise l'accès selon le role configuré.

```
VSO → token JWT du ServiceAccount → Vault vérifie → accorde accès selon policy
```

### Flow complet

```
FluxCD crée le ServiceAccount <app>-vault-auth
        ↓
VSO utilise ce SA pour générer un token JWT
        ↓
VSO présente le token à Vault (mount: clusterpayload, role: jwt-...-<namespace>)
        ↓
Vault vérifie : sub = system:serviceaccount:<namespace>:<app>-vault-auth ✓
        ↓
Vault accorde l'accès en lecture sur kv/<squad>/staging/clusterpayload/<namespace>/*
        ↓
VSO crée le Kubernetes Secret dans le namespace
```

### Convention de nommage

| Élément | Pattern | Exemple |
|---------|---------|---------|
| ServiceAccount | `<app>-vault-auth` | `openldap-vault-auth` |
| VaultAuth role | `jwt-<cluster>-<squad>-<env>-<namespace>` | `jwt-clusterpayload-middleware-staging-openldap` |
| Audience JWT | `<squad>` | `middleware` |

> Le role Terraform autorise tous les SAs qui matchent `*-vault-auth` dans le namespace (`bound_claims.sub = "system:serviceaccount:<namespace>:*-vault-auth"`).

---

## Namespaces configurés (staging)

| Cluster | Squad | Namespace K8s | Role JWT |
|---------|-------|---------------|----------|
| clusterpayload | warap | warap | `jwt-clusterpayload-warap-staging-warap` |
| clusterpayload | devsecops | devsecops | `jwt-clusterpayload-devsecops-staging-devsecops` |

---

## Unseal après redémarrage

Vault se re-scelle à chaque redémarrage du pod (pas d'auto-unseal configuré) :

```bash
kubectl exec -n vault vault-0 -- vault operator unseal <UNSEAL_KEY>
kubectl exec -n vault vault-0 -- vault status
```

Mettre à jour `.env` si le root token change :

```bash
vault_root_token=<nouveau_token>
```
