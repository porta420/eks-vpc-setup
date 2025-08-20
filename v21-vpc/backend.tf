# ──────────────────────────────────────────────────────────────────────────────
# backend.tf  (NOTE: backend arguments CANNOT use variables)
# Fill in your actual S3 bucket, key path, region, and optional DynamoDB table
# then run:  terraform init -reconfigure
# ──────────────────────────────────────────────────────────────────────────────
terraform {
  backend "s3" {
    bucket         = "noel-s3-tf-state-bucket"
    key            = "vpc/terraform.tfstate"
    region         = "eu-north-1"
   # dynamodb_table = "<OPTIONAL_LOCK_TABLE_NAME>" # create a DynamoDB table with PK "LockID"
    #encrypt        = true
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# versions.tf
# ──────────────────────────────────────────────────────────────────────────────
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50, < 7.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Note: The S3 bucket must already exist before running `terraform init`.
# The DynamoDB table is optional but recommended for state locking.