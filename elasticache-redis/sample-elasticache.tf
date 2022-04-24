#####################################
# ElastiCache(Redis)
#####################################
resource "aws_elasticache_replication_group" "sample" {
  replication_group_id       = "${local.base_name}-sample"
  description                = "Redis cluster for ${local.base_name}-sample."
  automatic_failover_enabled = local.elasticache_settings["automatic_failover_enabled"]
  engine                     = "redis"
  engine_version             = local.elasticache_settings["engine_version"]
  multi_az_enabled           = local.elasticache_settings["multi_az_enabled"]
  node_type                  = local.elasticache_settings["node_type"]
  num_cache_clusters         = local.elasticache_settings["number_cache_clusters"]
  parameter_group_name       = aws_elasticache_parameter_group.sample.id
  subnet_group_name          = aws_elasticache_subnet_group.sample.name
  security_group_ids         = [aws_security_group.sample_elasticache.id]
  port                       = 6379
  maintenance_window         = local.elasticache_settings["maintenance_window"]
  snapshot_window            = local.elasticache_settings["snapshot_window"]
  snapshot_retention_limit   = 35
  final_snapshot_identifier  = "${local.base_name}-sample-final-snapshot"
  apply_immediately          = false
  auto_minor_version_upgrade = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = aws_kms_key.sample_elasticache.arn
  auth_token                 = local.elasticache_settings["auth_token"]
  lifecycle {
    ignore_changes = [
      number_cache_clusters,
      apply_immediately
    ]
  }
  # 以下の Issue のため手動設定が必要 -> 「../docs/elasticache.md」
  # Open Issue
  # https://githubmemory.com/repo/hashicorp/terraform-provider-aws/issues/20023
  # log_delivery {
  #   format = "json"
  #   delivery {
  #     destination_type = "cloudwatch"
  #     log_destination  = "/aws/elasticache/redis-slowlog"
  #   }
  # }
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# Parameter Group
#####################################
resource "aws_elasticache_parameter_group" "sample" {
  name   = "${local.base_name}-sample"
  family = local.elasticache_settings["family"]

  parameter { # slowlog
    name  = "slowlog-log-slower-than"
    value = "1000"
  }

  parameter { # slowlog
    name  = "slowlog-max-len"
    value = "128"
  }

  parameter { # 不要なコネクション削除
    name  = "timeout"
    value = "60"
  }

  parameter { # 使用頻度の低いものを優先削除
    name  = "maxmemory-policy"
    value = "volatile-lru"
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# Subnet Group
#####################################
resource "aws_elasticache_subnet_group" "sample" {
  name = "${local.base_name}-sample"
  subnet_ids = [
    aws_subnet.sample_private_1a.id,
    aws_subnet.sample_private_1c.id
  ]
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# Security Group
#####################################
resource "aws_security_group" "sample_elasticache" {
  name   = "${local.base_name}-sample-elasticache"
  vpc_id = aws_vpc.sample.id
  tags   = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-elasticache" }))
}

resource "aws_security_group_rule" "sample_elasticache_egress" {
  security_group_id = aws_security_group.sample_elasticache.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sample_elasticache_ingress_ec2" {
  security_group_id = aws_security_group.sample_elasticache.id

  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sample_ec2.id
}

#####################################
# KMS / used for Aurora Data Encryption
#####################################
resource "aws_kms_key" "sample_elasticache" {
  description         = "used for Aurora Data Encryption"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.sample_elasticache_kms.json
  tags                = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-elasticache" }))
}

data "aws_iam_policy_document" "sample_elasticache_kms" {
  statement {
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
    resources = ["*"]
  }
}

resource "aws_kms_alias" "sample_elasticache" {
  name          = "alias/${local.system}/${local.env}/sample/elasticache"
  target_key_id = aws_kms_key.sample_elasticache.key_id
}

#####################################
# Route53 Record
#####################################
resource "aws_route53_record" "sample_elasticache" {
  name    = "${local.base_name}-sample-redis.${local.route53_settings["private_hosted_zone_name"]}"
  type    = "CNAME"
  ttl     = "5"
  zone_id = aws_route53_zone.sample_private.id
  weighted_routing_policy {
    weight = 90
  }
  set_identifier = "${local.base_name}-sample-redis"
  records        = [aws_elasticache_replication_group.sample.primary_endpoint_address]
}

resource "aws_route53_record" "sample_elasticache_ro" {
  name    = "${local.base_name}-sample-redis-ro.${local.route53_settings["private_hosted_zone_name"]}"
  type    = "CNAME"
  ttl     = "5"
  zone_id = aws_route53_zone.sample_private.id
  weighted_routing_policy {
    weight = 90
  }
  set_identifier = "${local.base_name}-sample-redis-ro"
  records        = [aws_elasticache_replication_group.sample.reader_endpoint_address]
}