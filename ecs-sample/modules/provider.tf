provider "aws" {
  region = var.region
  default_tags {
    tags = {
      System    = var.system
      Env       = var.env
      Terraform = "true"
    }
  }
}