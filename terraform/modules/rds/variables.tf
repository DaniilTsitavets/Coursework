variable "allocated_storage" {
  type    = number
  default = 5
}

variable "db_name" {
  type    = string
  default = "oltp-db"
}

variable "engine" {
  type    = string
  default = "postgres"
}

variable "engine_version" {
  type    = string
  default = ""
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_username" {
  type    = string
  default = "user"
}

variable "db_password" {
  type    = string
  default = "password"
}

