terraform {
  backend "s3" {
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.state_key_network
    region = var.region
  }
}

data "terraform_remote_state" "lb" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.state_key_lb
    region = var.region
  }
}