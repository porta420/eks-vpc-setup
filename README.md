# eks-vpc-setup

# EKS Cluster Access Setup & Troubleshooting Guide

## 1. Infrastructure Setup Summary

- EKS Cluster provisioned in a custom VPC with public and private subnets.
- Bastion host EC2 instance deployed in the **public subnet** of the same VPC.
- Cluster endpoint **public access enabled** for external connectivity(only during, for production endpoint should be private.
- IAM roles and policies configured to grant cluster admin access to the bastion host and Terraform user.

---

## 2. Security Group Configurations

### Bastion Host Security Group
- Inbound rules: Allow all traffic from anywhere (`0.0.0.0/0`) for testing, for production restrict to company ip.
- Outbound rules: Allow all outbound traffic (`0.0.0.0/0`).

### EKS Cluster Control Plane Security Group
- Initially missing HTTPS (TCP 443) inbound rule from bastion host SG.
- Correct rule added:
  - **Type:** HTTPS (TCP 443)
  - **Source:** Bastion host security group ID

---

## 3. Common Connectivity Issues

- Connection timeouts when accessing the EKS API server from the bastion host.
- `kubectl` commands return errors such as:
- Curl to cluster endpoint fails due to TCP timeouts.

---

## 4. Step-by-Step Access Setup & Resolution

### Problem Symptoms

- Attempts to run `kubectl get nodes` from bastion host fail with timeout or forbidden errors.
- API endpoint unreachable over port 443.

### Diagnosis

- Cluster endpoint resolving to private IPs.
- Network traffic blocked by missing inbound rules on cluster control plane security group.

### Resolution Steps

1. **Modify EKS Cluster Control Plane Security Group:**

 - Add an inbound rule for HTTPS (TCP 443).
 - Set the source to the bastion host's security group ID to allow traffic from bastion.

2. **Verify Bastion Security Group Outbound Rules:**

 - Ensure outbound HTTPS (TCP 443) is allowed (usually open by default).

3. **Ensure Cluster Endpoint Public Access is Enabled:**

 - Confirm `cluster_endpoint_public_access = true` in your Terraform or EKS console.

4. **Test Connectivity from Bastion:**

 ```bash
 curl -v https://<cluster-endpoint>:443
 kubectl get nodes


5. Troubleshooting Tips

Check the cluster control plane security group inbound rules.

Use curl or telnet to test connectivity to the API server on port 443.

Verify IAM role attached to bastion has necessary EKS permissions.

Review kubeconfig to ensure correct user/role ARN is set.

Confirm that network ACLs and route tables allow traffic between bastion and cluster subnets.

## EKS Cluster Access Issue: Problem, Troubleshooting, and Solution

### Problem  
After provisioning the EKS cluster, attempts to access the Kubernetes API from the admin server (e.g., Terraform server or bastion host) failed with timeout and permission errors. This prevented running `kubectl` commands against the cluster.

### Troubleshooting  
The root cause was identified as missing ingress rules in the EKS control plane security group. Although the admin server was deployed inside the same VPC, its security group (often the default VPC security group) was not explicitly allowed to access the cluster’s API endpoint on port 443.

### Solution  
The issue was resolved by updating the EKS cluster security group to allow inbound HTTPS (port 443) traffic from the admin server’s security group. This secured and enabled communication between the admin server and the EKS control plane within the private VPC network. Once this rule was in place, `kubectl` commands successfully connected to and managed the cluster.

---

This approach avoids exposing the cluster API publicly and follows best practices for secure access within a VPC.
