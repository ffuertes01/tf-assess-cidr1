module "app" {
  source     = "../../"
  env_name   = "devel"
  app_name   = "my-app"
  #build_dir  = "../build"
  #build_dir = "/Users/ffuertes/fslabs/tf-assess-cidr1/build"
  build_dir  = "../../../build"
}