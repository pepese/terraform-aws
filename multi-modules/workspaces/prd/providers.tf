provider "aws" {
  region = local.common_param["region"]
  default_tags {
    tags = {
      System    = local.common_param["system"],
      Env       = local.common_param["env"],
      Terraform = "true",
    }
  }
}
