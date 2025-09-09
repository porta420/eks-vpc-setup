# Monitoring Stack (Prometheus + Grafana) on EKS

This setup uses the official [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack) Helm chart to deploy:
- Prometheus (metrics collection)
- Alertmanager (alert routing)
- Grafana (dashboards)
- Node Exporters & Kube State Metrics

---

## Prerequisites
- A working **EKS cluster**
- **kubectl** configured for your cluster
- **Helm v3** installed on your local machine or bastion host

---

## 1. Add Helm Repositories
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f values-demo.yaml

# Prometheus + Grafana Deployment on EKS

This repo provides two configurations for deploying [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack) using Helm.

---

## Deploy (Demo)
For testing (minimal cost):
```bash
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f values-demo.yaml

