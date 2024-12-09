module "app" {
  source     = "../../"
  env_name   = "stage"
  app_name   = "my-app"
  build_dir  = "../../../build"
}