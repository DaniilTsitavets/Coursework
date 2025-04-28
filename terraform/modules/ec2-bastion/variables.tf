variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnet_id" {}

variable "ami" {}

