variable "allocated_storage" {
  type    = number
  default = 5
}

variable "db_name" {
  type    = string
  default = "OLTPdb"
}

variable "engine" {
  type    = string
  default = "postgres"
}

variable "engine_version" {
  type    = string
  default = "17.2"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  type    = string
  default = "mypostgrespassword"
}

variable "db_subnet_group_name" {
  type    = string
}

variable "project_name" {
  type    = string
  default = "coursework"
}

variable "vpc_id" {
  type    = string
}

variable "lambda_sg_map" {
  type = map(string)
  description = "Map of Lambda security group identifiers"
}

variable "bastion_sg" {
  type = string
}

variable "rds_sg_map" {
  type = map(string)
}