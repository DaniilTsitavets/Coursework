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
#
# variable "db_subnet_group_name" {
#   type = string
#   default = null
# }

variable "project_name" {
  type    = string
  default = "coursework"
}

variable "vpc_id" {
  type    = string
  default = null
}