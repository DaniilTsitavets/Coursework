terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.4.0"
}

resource "local_file" "etl2" {
  content = templatefile("${path.module}/etl2.sql.tpl", {
    host     = module.rds_oltp.db_address
    db_name  = module.rds_oltp.db_name
    user     = module.rds_oltp.db_username
    password = module.rds_oltp.db_password
  })
  filename = "${path.module}/../sql/etl2.sql"

  depends_on = [module.rds_oltp]
}

module "s3" {
  source = "./modules/s3"
  depends_on = [local_file.etl2]
}

module "vpc" {
  source = "./modules/vpc"
}

module "ec2-bastion" {
  source           = "./modules/ec2-bastion"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
}

module "rds_oltp" {
  source               = "./modules/rds"
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
  bastion_sg           = module.ec2-bastion.bastion_sg
  lambda_sg_map = {
    lambda_oltp = module.lambda_to_oltp.lambda_sg
    lambda_olap = module.lambda_to_olap.lambda_sg
  }
  rds_sg_map = {
    rds_olap_sg_id = module.rds_olap.rds_oltp_sg_id
  }
}

module "lambda_to_oltp" {
  source             = "./modules/lambda"
  filename           = "../build/lambda-to-oltp.zip"
  function_name      = "lambda-to-oltp"
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

  env_variables = {
    DB_HOST         = module.rds_oltp.db_address
    DB_NAME         = module.rds_oltp.db_name
    DB_USER         = module.rds_oltp.db_username
    DB_PASSWORD     = module.rds_oltp.db_password
    S3_BUCKET       = module.s3.bucket_name
    ETL_KEY         = module.s3.s3_key_oltp_etl
    CSV_KEY         = module.s3.s3_key_test_csv
    INIT_TABLES_KEY = module.s3.s3_key_init_oltp_tables
  }
}

module "rds_olap" {
  source               = "./modules/rds"
  db_name              = "OLAPdb"
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
  bastion_sg           = module.ec2-bastion.bastion_sg
  lambda_sg_map = {
    lambda_olap = module.lambda_to_olap.lambda_sg
  }
  rds_sg_map = {}
}

module "lambda_to_olap" {
  source             = "./modules/lambda"
  filename           = "../build/lambda-to-olapp.zip"
  function_name      = "lambda-to-olap"
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

  env_variables = {
    OLAP_HOST     = module.rds_olap.db_address
    OLAP_NAME     = module.rds_olap.db_name
    OLAP_USER     = module.rds_olap.db_username
    OLAP_PASSWORD = module.rds_olap.db_password

    INIT_SQL_KEY = module.s3.s3_key_init_olap_tables
    ETL_SQL_KEY  = module.s3.s3_key_olap_etl
    S3_BUCKET    = module.s3.bucket_name
  }
}
