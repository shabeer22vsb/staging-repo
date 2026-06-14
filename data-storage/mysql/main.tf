terraform {
  backend "s3" {
    bucket       = "my-tf-practical-bucket-166373406634-eu-west-1-an"
    key          = "stage/data-stores/mysql/terraform.tfstate"
    use_lockfile = true
    region       = "eu-west-1"
  }
}
provider "aws" {
  region = "eu-west-1"           # ← default provider (no alias)
}
provider "aws" {
    region = "eu-west-1"
    alias = "ireland"
}
provider "aws" {
    region = "eu-west-2"
    alias = "london"
}
data "aws_secretsmanager_secret_version" "db-creds" {
  secret_id = "db-creds"
}
locals {
  db_creds=jsondecode(
    data.aws_secretsmanager_secret_version.db-creds.secret_string
  )
}
module "data-storage-ireland"{
  source = "github.com/shabeer22vsb/modules//services/data-storage"
  db_name = "prod-db"
  backup_retention_period = 1
  db_password = local.db_creds.password
  db_username = local.db_creds.username
  db_instance_class = var.db_instance_class
  allocated_storage = var.allocated_storage
  skip_final_snapshot = var.skip_final_snapshot
  providers = {
    aws = aws.ireland
  }
}
module "data-storage-ireland-replica" {
  source = "github.com/shabeer22vsb/modules//services/data-storage"
  replicate_source_db = module.data-storage-ireland.arn
  providers = {
    aws = aws.london
  }
}
module "data-storage-london"{
  source = "github.com/shabeer22vsb/modules//services/data-storage"
  db_password = local.db_creds.password
  db_username = local.db_creds.username
  db_instance_class = var.db_instance_class
  allocated_storage = var.allocated_storage
  skip_final_snapshot = var.skip_final_snapshot
  providers = {
    aws = aws.london
  }
}
