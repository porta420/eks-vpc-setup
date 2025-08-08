terraform {
  backend "s3" {
    bucket = "noel-s3-tf-state-bucket"
    key    = "rds-mysql/terraform.tfstate"
    region = "eu-north-1"

    # Optional for state locking
    # dynamodb_table = "terraform-locks"
  }
}