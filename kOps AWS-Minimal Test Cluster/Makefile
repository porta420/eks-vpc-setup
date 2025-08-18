SHELL := /usr/bin/env bash

# ---- minimal test cluster vars ----
AWS_REGION ?= eu-north-1
KOPS_CLUSTER_NAME ?= prod-eu-north-1.k8s.local
STATE_BUCKET ?= YOUR-UNIQUE-KOPS-STATE-BUCKET
KOPS_STATE_STORE ?= s3://$(STATE_BUCKET)
KOPS_VERSION ?= 1.32.0
K8S_VERSION  ?= 1.31.4

export KOPS_STATE_STORE
export KOPS_CLUSTER_NAME

.PHONY: ensure-tools
ensure-tools:
	command -v kops >/dev/null || { echo "Missing kops"; exit 1; }
	command -v terraform >/dev/null || { echo "Missing terraform"; exit 1; }
	command -v kubectl >/dev/null || { echo "Missing kubectl"; exit 1; }

.PHONY: tf-export
# Export Terraform into clusters/<name>/terraform
# (commit optionally for reviewable plans)
tf-export: ensure-tools
	mkdir -p clusters/$(KOPS_CLUSTER_NAME)/terraform
	kops update cluster $$KOPS_CLUSTER_NAME --out=clusters/$(KOPS_CLUSTER_NAME)/terraform --target=terraform --yes

.PHONY: tf-plan
tf-plan:
	cd clusters/$(KOPS_CLUSTER_NAME)/terraform && terraform init && terraform plan -out=tfplan

.PHONY: tf-apply
tf-apply:
	cd clusters/$(KOPS_CLUSTER_NAME)/terraform && terraform apply -auto-approve tfplan

.PHONY: validate
validate:
	kops validate cluster --wait 10m

.PHONY: delete
delete:
	kops delete cluster $$KOPS_CLUSTER_NAME --yes