variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "public_subnet_id" {
  type    = string
  default = null
}

variable "ami_id" {
  type    = string
  default = "ami-0c1ac8a41498c1a9c" //ubuntu
}

variable "key_name" {
  type    = string
  default = "coursework-bastion-kp"
}

variable "project_name" {
  type    = string
  default = "coursework"
}

variable "cidr_ipv4_ingress" {
  type    = string
  default = "0.0.0.0/0"
}

variable "cidr_ipv4_egress" {
  type    = string
  default = "0.0.0.0/0"
}