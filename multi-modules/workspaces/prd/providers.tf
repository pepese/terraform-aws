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

provider "aws" {
  alias = "virginia"

  region = local.common_param["acm_region"]
  default_tags {
    tags = {
      System    = local.common_param["system"],
      Env       = local.common_param["env"],
      Terraform = "true",
    }
  }
}

provider "aws" {
  alias = "singapore"

  region = local.common_param["backup_region"]
  default_tags {
    tags = {
      System    = local.common_param["system"],
      Env       = local.common_param["env"],
      Terraform = "true",
    }
  }
}
