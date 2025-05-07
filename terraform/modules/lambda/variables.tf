variable "function_name" {
  type = string
}
variable "handler" {
  type    = string
  default = "index.handler" //<file_name>.<function_name>
}
variable "runtime" {
  type    = string
  default = "python3.12"
}
variable "filename" {
  type = string
}
variable "policy_arns" {
  type = list(string)
  default = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

variable "private_subnet_ids" {
  type = list(string)
}
variable "vpc_id" {
  type = string
}