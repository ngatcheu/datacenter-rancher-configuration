.PHONY: help \
        bootstrap-init bootstrap-apply bootstrap-show-token bootstrap-destroy \
        config-init config-plan config-apply config-destroy config-show-ca \
        enrollment-init enrollment-plan enrollment-apply enrollment-destroy \
        projects-init projects-plan projects-apply projects-destroy \
        init plan apply destroy

TF := terraform -chdir

BOOTSTRAP_DIR  := staging/rancher-bootstrap
CONFIG_DIR     := staging/rancher-configuration
ENROLLMENT_DIR := staging/rancher-enrollment
PROJECTS_DIR   := staging/rancher-project-namespace-configuration

# Clé SSH pour l'enrôlement — peut être surchargée : make enrollment-apply SSH_KEY=~/.ssh/autre_clé
SSH_KEY ?= ~/.ssh/id_rsa

help:
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "rancher-bootstrap (étape 1 — une seule fois) :"
	@echo "  bootstrap-init          init"
	@echo "  bootstrap-apply         initialise le mot de passe admin + génère le token API"
	@echo "  bootstrap-show-token    affiche access_key et secret_key"
	@echo "  bootstrap-destroy       destroy"
	@echo ""
	@echo "rancher-configuration :"
	@echo "  config-init        init"
	@echo "  config-plan        plan"
	@echo "  config-apply       apply"
	@echo "  config-destroy     destroy"
	@echo ""
	@echo "rancher-enrollment :"
	@echo "  enrollment-init    init"
	@echo "  enrollment-plan    plan"
	@echo "  enrollment-apply   apply"
	@echo "  enrollment-destroy destroy"
	@echo ""
	@echo "rancher-project-namespace-configuration :"
	@echo "  projects-init      init"
	@echo "  projects-plan      plan"
	@echo "  projects-apply     apply"
	@echo "  projects-destroy   destroy"
	@echo ""
	@echo "Global :"
	@echo "  init               init tous les stacks"
	@echo "  plan               plan config + enrollment + projects"
	@echo "  apply              apply tous les stacks dans l'ordre"
	@echo "  destroy            destroy tous les stacks en ordre inverse"
	@echo ""
	@echo "Workflow initial :"
	@echo "  1. make bootstrap-init && make bootstrap-apply"
	@echo "  2. make init && make apply  (token + CA cert injectés automatiquement)"
	@echo ""

# ─── RANCHER-BOOTSTRAP ───────────────────────────────────────────────────────

bootstrap-init:
	$(TF)=$(BOOTSTRAP_DIR) init

bootstrap-apply:
	$(TF)=$(BOOTSTRAP_DIR) apply

bootstrap-show-token:
	@echo "=== Token Key (rancher_token_key) ==="
	@$(TF)=$(BOOTSTRAP_DIR) output -raw rancher_token_key
	@echo ""

bootstrap-destroy:
	$(TF)=$(BOOTSTRAP_DIR) destroy

# ─── RANCHER-CONFIGURATION ───────────────────────────────────────────────────

config-init:
	$(TF)=$(CONFIG_DIR) init

_config-env = TF_VAR_rancher_token_key="$$($(TF)=$(BOOTSTRAP_DIR) output -raw rancher_token_key)" \
              TF_VAR_rancher_ca_cert="$$(kubectl get secret tls-ca -n cattle-system -o jsonpath='{.data.tls\.crt}' | base64 -d)"

config-plan:
	$(_config-env) $(TF)=$(CONFIG_DIR) plan

config-apply:
	$(_config-env) $(TF)=$(CONFIG_DIR) apply

config-destroy:
	$(_config-env) $(TF)=$(CONFIG_DIR) destroy

# Extrait le CA cert depuis le serveur Rancher → à coller dans terraform.tfvars (rancher_ca_cert)
config-show-ca:
	@echo "=== Tentative extraction CA via TLS chain ==="
	@echo "(Si vide : le serveur n'envoie pas la chaîne complète → utiliser SSH sur le cluster Rancher)"
	@openssl s_client -connect rancher.homelab.local:443 -showcerts </dev/null 2>/dev/null \
	  | awk 'BEGIN{c="";last=""} /BEGIN CERTIFICATE/{c=""} {c=c$$0"\n"} /END CERTIFICATE/{last=c} END{printf "%s",last}'
	@echo ""
	@echo "→ Ou directement depuis kubectl :"
	@echo "  kubectl get secret tls-ca -n cattle-system -o jsonpath='{.data.tls\\.crt}' | base64 -d"

# ─── RANCHER-ENROLLMENT ──────────────────────────────────────────────────────

enrollment-init:
	$(TF)=$(ENROLLMENT_DIR) init

enrollment-plan:
	TF_VAR_ssh_private_key="$$(cat $(SSH_KEY))" $(TF)=$(ENROLLMENT_DIR) plan

enrollment-apply:
	TF_VAR_ssh_private_key="$$(cat $(SSH_KEY))" $(TF)=$(ENROLLMENT_DIR) apply

enrollment-destroy:
	TF_VAR_ssh_private_key="$$(cat $(SSH_KEY))" $(TF)=$(ENROLLMENT_DIR) destroy

# ─── RANCHER-PROJECT-NAMESPACE-CONFIGURATION ─────────────────────────────────

projects-init:
	$(TF)=$(PROJECTS_DIR) init

projects-plan:
	$(TF)=$(PROJECTS_DIR) plan

projects-apply:
	$(TF)=$(PROJECTS_DIR) apply

projects-destroy:
	$(TF)=$(PROJECTS_DIR) destroy

# ─── GLOBAL ──────────────────────────────────────────────────────────────────

init: config-init enrollment-init projects-init

plan: config-plan enrollment-plan projects-plan

apply: config-apply enrollment-apply projects-apply

destroy: projects-destroy enrollment-destroy config-destroy
