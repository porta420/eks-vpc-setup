terraform {
  required_version = ">= 1.5.7"

  # Adjust to your RDS project state location
  backend "s3" {
    bucket = "noel-s3-tf-state-bucket"
    key    = "rds/terraform.tfstate"
    region = "eu-north-1"
    # dynamodb_table = "YOUR-LOCK-TABLE"
    # encrypt        = true
  }
}
