terraform {
  backend "s3" {
    bucket = "noel-s3-tf-state-bucket"
    key    = "eks-cluster/terraform.tfstate"
    region = "eu-north-1"

    # Uncomment below if you want DynamoDB locking
    # dynamodb_table = "terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}
