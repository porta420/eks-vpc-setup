terraform {
  required_version = ">= 1.5.7"

  backend "s3" {
    bucket = "noel-s3-tf-state-bucket"
    key    = "eks-private/terraform.tfstate"
    region = "eu-north-1"
    # dynamodb_table = "YOUR-LOCK-TABLE"
    # encrypt        = true
  }
}

provider "aws" {
  region = var.region
}