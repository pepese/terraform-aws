#####################################
# Provider Settings
#####################################

provider "aws" {
  version    = "~> 2.25"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}