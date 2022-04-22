#####################################
# LB
#####################################
/*
resource "aws_s3_bucket" "sample_bucket" {
  bucket        = "sample-bucket-${var.env}"
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-s3-bucket-sample" }))
}*/