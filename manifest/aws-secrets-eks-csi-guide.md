# AWS Secrets Manager + EKS (CSI Driver Integration)

This guide shows how to integrate **AWS Secrets Manager** with **Amazon EKS** using the **Secrets Store CSI Driver**.  
It covers creating a secret, configuring IAM, syncing to Kubernetes Secrets, and testing with a pod deployment.

---

# Prerequisites

Install the following on your workstation/bastion host:

```bash
# AWS CLI
sudo apt-get update && sudo apt-get install -y awscli

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# eksctl
curl --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Also ensure:
- You have an existing **EKS cluster**
- Your kubeconfig is set:  
  ```bash
  aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
  ```

---

# 1. Create a Secret in AWS Secrets Manager

```bash
aws secretsmanager create-secret   --name my-db-secret   --description "Database credentials for my EKS app"   --secret-string '{"username":"admin","password":"SuperSecurePass123"}'
```

---

##  2. Enable IAM OIDC Provider (if not already enabled)


eksctl utils associate-iam-oidc-provider   --cluster <CLUSTER_NAME>   --region <REGION>   --approve


---

## 3. Install CSI Secrets Store Driver

helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo update

helm upgrade --install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver   --namespace kube-system   --set syncSecret.enabled=true   --set enableSecretRotation=true


Install AWS provider:

kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml


---

## 4. Create IAM Policy for Secrets Access

Create `secretsmanager-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:<REGION>:<ACCOUNT_ID>:secret:my-db-secret-*"
    }
  ]
}
```

Create the policy:

```bash
aws iam create-policy   --policy-name EKSSecretsManagerPolicy   --policy-document file://secretsmanager-policy.json
```

---

## 5. Create Service Account with IAM Role (IRSA)

```bash
eksctl create iamserviceaccount   --cluster <CLUSTER_NAME>   --namespace default   --name secrets-sa   --attach-policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/EKSSecretsManagerPolicy   --approve
```

---

## 🔹 6. Create SecretProviderClass

`secretproviderclass.yaml`:

```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: aws-secrets
  namespace: default
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: "my-db-secret"
        objectType: "secretsmanager"
  secretObjects:
  - secretName: my-k8s-secret
    type: Opaque
    data:
    - objectName: "my-db-secret"
      key: db-creds
```

Apply:

```bash
kubectl apply -f secretproviderclass.yaml
```

---

##  7. Test Deployment

`secrets-test.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secrets-test
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secrets-test
  template:
    metadata:
      labels:
        app: secrets-test
    spec:
      serviceAccountName: secrets-sa
      containers:
      - name: secrets-test
        image: busybox
        command: ["/bin/sh", "-c"]
        args:
          - |
            echo "=== Mounted Secret File ===";
            cat /mnt/secrets-store/my-db-secret || echo "File not found";
            echo "=== Env Var from Synced K8s Secret ===";
            echo $DB_CREDS;
            sleep 3600;
        env:
        - name: DB_CREDS
          valueFrom:
            secretKeyRef:
              name: my-k8s-secret
              key: db-creds
        volumeMounts:
        - name: secrets-store-inline
          mountPath: "/mnt/secrets-store"
          readOnly: true
      volumes:
      - name: secrets-store-inline
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: "aws-secrets"
```

Apply:

```bash
kubectl apply -f secrets-test.yaml
```

---

##  8. Verify

Check pod logs:

```bash
kubectl logs -l app=secrets-test
```

You should see:
```
=== Mounted Secret File ===
{"username":"admin","password":"SuperSecurePass123"}
=== Env Var from Synced K8s Secret ===
{"username":"admin","password":"SuperSecurePass123"}
```

Check Kubernetes Secret:

```bash
kubectl get secret my-k8s-secret -o yaml
kubectl get secret my-k8s-secret -o jsonpath='{.data.db-creds}' | base64 -d
```

Check inside pod:

```bash
kubectl exec -it deploy/secrets-test -- cat /mnt/secrets-store/my-db-secret
kubectl exec -it deploy/secrets-test -- printenv DB_CREDS
```

---

## Success
Now your EKS workloads can consume secrets from AWS Secrets Manager:
- Mounted as **files**  
- Synced as **Kubernetes Secrets**  
- Injected as **environment variables**  
