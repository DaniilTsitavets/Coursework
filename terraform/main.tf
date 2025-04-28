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
  # s3_bucket_name = "coursework-data-bucket"
}
module "vpc" {
  source = "./modules/vpc"
}
module "rds" {
  source = "./modules/rds"
  #have to take db_subnet_group_name AND vpc_id from vpc module
  vpc_id = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
}