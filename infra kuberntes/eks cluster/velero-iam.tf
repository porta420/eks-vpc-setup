
# velero-iam.tf

# (Optional) Dedicated Velero S3 bucket
# Commented out for now, uncomment in production
# resource "aws_s3_bucket" "velero" {
#   bucket = var.velero_backup_bucket
#   acl    = "private"
#
#   tags = {
#     Name        = "${var.cluster_name}-velero-backups"
#     Environment = var.environment
#   }
# }
#
# resource "aws_s3_bucket_versioning" "velero" {
#   bucket = aws_s3_bucket.velero.id
#
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# IAM Role for Velero ServiceAccount
resource "aws_iam_role" "velero" {
  name = "${var.cluster_name}-velero-role"

  assume_role_policy = data.aws_iam_policy_document.velero_assume.json
}

data "aws_iam_policy_document" "velero_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:velero:velero"]
    }
  }
}

# IAM Policy for S3 Backup Access
resource "aws_iam_policy" "velero_s3" {
  name        = "${var.cluster_name}-velero-s3-policy"
  description = "Allow Velero to access S3 bucket for backups"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${var.velero_backup_bucket}",
        "arn:aws:s3:::${var.velero_backup_bucket}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVolumes",
        "ec2:DescribeSnapshots",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "velero_attach" {
  role       = aws_iam_role.velero.name
  policy_arn = aws_iam_policy.velero_s3.arn
}
