module "app" {
  source     = "../../"
  env_name   = "prod"
  app_name   = "my-app"
  build_dir  = "../../../build"
}