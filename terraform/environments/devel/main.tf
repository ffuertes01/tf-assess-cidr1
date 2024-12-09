provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "ipv4-app-tf-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "ipv4-app-tf-lock"
    encrypt = true
  }
}

module "app" {
  source     = "../../"
  env_name   = "devel"
  app_name   = "ipv4-app"
  build_dir  = "../../../build"
}

output "bucket_website_endpoint" {
    value = module.app.bucket_website_endpoint
}