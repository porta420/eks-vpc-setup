terraform {
  backend "s3" {
    bucket = "noel-s3-tf-state-bucket"
    key    = "vpc/terraform.tfstate"
    region = "eu-north-1"

    # Uncomment below if using DynamoDB state locking later
    # dynamodb_table = "noel-s3-tf-state-bucket-lock"
  }
}
