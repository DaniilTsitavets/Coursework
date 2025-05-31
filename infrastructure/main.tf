terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.4.0"
}

module "s3" {
  source = "./modules/s3"
}

module "vpc" {
  source = "./modules/vpc"
}

module "ec2-bastion" {
  source           = "./modules/ec2-bastion"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
}

module "rds" {
  source               = "./modules/rds"
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
  cidr_ipv4_ingress    = module.ec2-bastion.instance_private_ip
  lambda_sg = module.lambda_to_oltp.lambda_sg
}

module "lambda_to_oltp" {
  source             = "./modules/lambda"
  filename           = "./../build/lambda_to_oltp.zip"
  function_name      = "lambda-to-oltp"
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  policy_arns = [
  "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

  env_variables = {
    DB_HOST     = module.rds.db_address
    DB_NAME     = module.rds.db_name
    DB_USER     = module.rds.db_username
    DB_PASSWORD = module.rds.db_password
    S3_BUCKET   = module.s3.bucket_name
    ETL_KEY     = module.s3.s3_key_oltp_etl
    CSV_KEY     = module.s3.s3_key_test_csv
    INIT_TABLES_KEY = module.s3.s3_key_init_tables
  }
}
