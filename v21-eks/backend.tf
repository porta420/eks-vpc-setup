terraform {
  required_version = ">= 1.5.7"

  backend "s3" {
    bucket         = "noel-s3-tf-state-bucket"
    key            = "v21-eks/terraform.tfstate"
    region         = "eu-north-1"
    #dynamodb_table = "YOUR-LOCK-TABLE"
    #encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.vpc_remote_state_bucket
    key    = var.vpc_remote_state_key
    region = var.region
  }
}