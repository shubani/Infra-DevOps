variable "aws_region" {
  default = "us-east-2"
}

variable "ecr_repo_name" {
  default = "app123"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "app_name" {
  type    = string
  default = "mandi"
}

variable "app_port" {
  type    = number
  default = 8080
}