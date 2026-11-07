# cluster-keys

Clé publique de signature des tokens de ServiceAccount de chaque cluster
(`<cluster>.pem`). Vault s'en sert pour valider les JWT présentés par VSO
(backend `auth/<cluster>`). Fichiers publics : versionnés.

À régénérer après la reconstruction d'un cluster (nouvelle clé `service.key`) :

```bash
ssh root@192.168.1.113 'openssl pkey -in /var/lib/rancher/rke2/server/tls/service.key -pubout' > clusterpayload.pem
ssh root@192.168.1.110 'openssl pkey -in /var/lib/rancher/rke2/server/tls/service.key -pubout' > clusterrancher.pem
```

Ajouter un cluster : déposer `<cluster>.pem` ici et l'ajouter à `var.clusters`.
