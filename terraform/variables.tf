variable "aws_region" {
  default = "us-east-1"
}

variable "env_name" {
  description = "Environment name (devel, stage, prod)"
}

variable "app_name" {
  default = "my-app"
}

variable "build_dir" {
  description = "Directory where the build files are located"
}
