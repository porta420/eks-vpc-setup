variable "region" {
  default = "eu-north-1"
}

variable "project_name" {
  default = "project022d"
}

variable "vpc_cidr" {
  default = "10.50.0.0/16"
}

# Two large public subnets across two AZs
variable "public_subnets" {
  type    = list(string)
  default = ["10.50.0.0/18", "10.50.64.0/18"]
}
