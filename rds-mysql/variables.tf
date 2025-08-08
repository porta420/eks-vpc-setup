variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "vpc_remote_state_bucket" {
  type    = string
  default = "noel-s3-tf-state-bucket"
}

variable "vpc_remote_state_key" {
  type    = string
  default = "vpc/terraform.tfstate"
}

variable "db_identifier" {
  type    = string
  default = "project022d-mysql"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type    = string
  default = "SuperSecretPass123!" # You can use `terraform.tfvars` or secrets manager in real cases
}

variable "db_name" {
  type    = string
  default = "projectdb"
}
