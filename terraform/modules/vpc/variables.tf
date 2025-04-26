variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "project_name" {
  type = string
  default = "coursework"
}

variable "public_subnet_cidr" {
type = list(string)
default = ["10.0.1.0/24"]
}

variable "private_subnet_cidr" {
  type = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "subnet_az" {
  type = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}