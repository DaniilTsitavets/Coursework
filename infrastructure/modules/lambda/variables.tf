variable "function_name" {
  type = string
  default = "lambda-to-oltp"
}
variable "handler" {
  type    = string
  default = "lambda_function.handler" //<file_name>.<function_name>
}
variable "runtime" {
  type    = string
  default = "python3.11"
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

variable "env_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}
