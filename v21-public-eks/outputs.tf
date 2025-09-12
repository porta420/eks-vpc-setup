output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "velero_role_arn" {
  description = "IAM role ARN for Velero service account"
  value       = aws_iam_role.velero.arn
}

output "velero_backup_bucket" {
  description = "S3 bucket used for Velero backups"
  value       = var.velero_backup_bucket
}

output "velero_region" {
  description = "Region for Velero backups"
  value       = var.velero_region
}
