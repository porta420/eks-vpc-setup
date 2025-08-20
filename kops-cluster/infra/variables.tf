variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for kOps state store (globally unique)"
  type        = string
}