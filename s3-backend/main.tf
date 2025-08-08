terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.44.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = var.bucket_name
    Environment = "test"
  }
}

# Optional DynamoDB table for state locking (commented out)
# resource "aws_dynamodb_table" "tf_lock" {
#   name           = "${var.bucket_name}-lock"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"
#
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
