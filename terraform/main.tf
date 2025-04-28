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
  source        = "./modules/s3"
  # s3_bucket_name = "coursework-data-bucket"
}
module "vpc" {
  source = "./modules/vpc"
}
module "ec2-bastion" {
  source = "./modules/ec2-bastion"
  vpc_id = module.vpc.vpc_id
}