#####################################
# Aurora / Postgres
#####################################
resource "aws_rds_cluster" "sample" {
  cluster_identifier              = "${local.base_name}-sample"
  engine                          = local.aurora_settings["engine"]
  engine_version                  = local.aurora_settings["engine_version"]
  master_username                 = local.aurora_settings["username"]
  master_password                 = local.aurora_settings["password"]
  database_name                   = local.aurora_settings["db_name"]
  port                            = local.aurora_settings["port"]
  vpc_security_group_ids          = [aws_security_group.sample_aurora.id]
  db_subnet_group_name            = aws_db_subnet_group.sample.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.sample.name

  apply_immediately            = false
  deletion_protection          = true
  preferred_maintenance_window = local.aurora_settings["maintenance_window"]
  preferred_backup_window      = local.aurora_settings["backup_window"]
  backup_retention_period      = local.aurora_settings["backup_retention_period"]
  copy_tags_to_snapshot        = true
  storage_encrypted            = true
  kms_key_id                   = aws_kms_key.sample_aurora.arn
  skip_final_snapshot          = false
  final_snapshot_identifier    = "${local.base_name}-sample-final-snapshot"

  enabled_cloudwatch_logs_exports = [ // 「/aws/rds/cluster/system-[Env]-sample/postgresql」ロググループ
    "postgresql",
  ]

  lifecycle {
    ignore_changes = [
      master_password,
      availability_zones
    ]
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

resource "aws_rds_cluster_instance" "sample" {
  count                           = local.env == "prd" || local.env == "stg" ? 2 : 1
  cluster_identifier              = aws_rds_cluster.sample.id
  identifier                      = "${local.base_name}-sample-${count.index}"
  engine                          = aws_rds_cluster.sample.engine
  engine_version                  = aws_rds_cluster.sample.engine_version
  instance_class                  = local.aurora_settings["instance_class"]
  monitoring_interval             = 60 #拡張モニタリング
  monitoring_role_arn             = aws_iam_role.sample_aurora_monitoring.arn
  db_subnet_group_name            = aws_db_subnet_group.sample.name
  db_parameter_group_name         = aws_db_parameter_group.sample.name
  apply_immediately               = false
  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.sample_aurora_pi.arn
  tags                            = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-${count.index}" }))
}

#####################################
# DB Subnet Group
#####################################
resource "aws_db_subnet_group" "sample" {
  name = "${local.base_name}-sample"
  subnet_ids = [
    aws_subnet.sample_private_1a.id,
    aws_subnet.sample_private_1c.id,
  ]

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# Cluster Parameter Group
#####################################
resource "aws_rds_cluster_parameter_group" "sample" {
  name   = "${local.base_name}-sample"
  family = "aurora-postgresql13"

  # timezone
  parameter {
    name         = "timezone"
    value        = "Asia/Tokyo"
    apply_method = "pending-reboot"
  }
  # log
  parameter {
    name         = "log_statement"
    value        = "none" # default
    apply_method = "immediate"
  }
  parameter { // 許容できないレスポンス時間(ミリ秒)
    name         = "log_min_duration_statement"
    value        = 3000
    apply_method = "immediate"
  }
  parameter {
    name  = "log_destination"
    value = "csvlog"
  }
  parameter {
    name  = "log_error_verbosity"
    value = "verbose"
  }
  parameter {
    name  = "log_lock_waits"
    value = 1
  }
  parameter {
    name  = "deadlock_timeout"
    value = 1000
  }
  # 統計情報
  parameter {
    name  = "track_functions"
    value = "all"
  }
  # keepalive
  parameter {
    name  = "tcp_keepalives_idle"
    value = 60
  }
  parameter {
    name  = "tcp_keepalives_interval"
    value = 5
  }
  # install libraries
  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements,auto_explain,pg_hint_plan,pgaudit"
    apply_method = "pending-reboot"
  }
  # pgaudit setting(監査ログ)
  parameter { // pg_catalog.pg_class、pg_catalog.pg_namespace への SELECT 監査ログ
    name         = "pgaudit.log_catalog"
    value        = "0"
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.log_parameter"
    value        = "1"
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.log_relation"
    value        = "1"
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.log_statement_once"
    value        = "1"
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.log"
    value        = "ddl,misc,role"
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.role"
    value        = "rds_pgaudit"
    apply_method = "immediate"
  }
  # --no-local
  parameter {
    name         = "lc_messages"
    value        = "C"
    apply_method = "immediate"
  }
  parameter {
    name         = "lc_monetary"
    value        = "C"
    apply_method = "immediate"
  }
  parameter {
    name         = "lc_numeric"
    value        = "C"
    apply_method = "immediate"
  }
  parameter {
    name         = "lc_time"
    value        = "C"
    apply_method = "immediate"
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# Instance Parameter Group
#####################################
resource "aws_db_parameter_group" "sample" {
  name   = "${local.base_name}-sample"
  family = "aurora-postgresql13"

  #parameter { # default: LEAST({DBInstanceClassMemory/9531392},5000)
  #  name         = "max_connections"
  #  value        = 2000
  #  apply_method = "pending-reboot"
  #}

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# Security Group
#####################################
resource "aws_security_group" "sample_aurora" {
  name   = "${local.base_name}-sample-aurora"
  vpc_id = aws_vpc.sample.id
  tags   = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-aurora" }))
}

resource "aws_security_group_rule" "sample_aurora_ingress_ec2" {
  security_group_id = aws_security_group.sample_aurora.id

  type                     = "ingress"
  from_port                = local.aurora_settings["port"]
  to_port                  = local.aurora_settings["port"]
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sample_ec2.id
}

#####################################
# IAM Role for Monitoring
#####################################
resource "aws_iam_role" "sample_aurora_monitoring" {
  name               = "${local.base_name}-sample-aurora"
  assume_role_policy = data.aws_iam_policy_document.sample_aurora_monitoring_assume.json
  tags               = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-aurora" }))
}

data "aws_iam_policy_document" "sample_aurora_monitoring_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy_attachment" "sample_aurora_monitoring" {
  name       = "${local.base_name}-sample-aurora"
  roles      = [aws_iam_role.sample_aurora_monitoring.name] # list
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

#####################################
# KMS / used for Aurora Data Encryption
#####################################
resource "aws_kms_key" "sample_aurora" {
  description         = "used for Aurora Data Encryption"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.sample_aurora_kms.json
  tags                = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-aurora" }))
}

data "aws_iam_policy_document" "sample_aurora_kms" {
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

resource "aws_kms_alias" "sample_aurora" {
  name          = "alias/${local.system}/${local.env}/sample/aurora"
  target_key_id = aws_kms_key.sample_aurora.key_id
}

#####################################
# KMS / used for Aurora Data Encryption
#####################################
resource "aws_kms_key" "sample_aurora_pi" {
  description         = "used for Aurora Performance Insights"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.sample_aurora_pi_kms.json
  tags                = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-aurora" }))
}

data "aws_iam_policy_document" "sample_aurora_pi_kms" {
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

resource "aws_kms_alias" "sample_aurora_pi" {
  name          = "alias/${local.system}/${local.env}/sample/aurora-pi"
  target_key_id = aws_kms_key.sample_aurora_pi.key_id
}

#####################################
# Route53 Record
#####################################
resource "aws_route53_record" "sample_aurora" {
  name    = "${local.base_name}-sample-aurora.${local.route53_settings["private_hosted_zone_name"]}"
  type    = "CNAME"
  ttl     = "5"
  zone_id = aws_route53_zone.sample_private.id
  weighted_routing_policy {
    weight = 90
  }
  set_identifier = "${local.base_name}-sample-aurora"
  records        = [aws_rds_cluster.sample.endpoint]
}

resource "aws_route53_record" "sample_aurora_ro" {
  name    = "${local.base_name}-sample-aurora-ro.${local.route53_settings["private_hosted_zone_name"]}"
  type    = "CNAME"
  ttl     = "5"
  zone_id = aws_route53_zone.sample_private.id
  weighted_routing_policy {
    weight = 90
  }
  set_identifier = "${local.base_name}-sample-aurora-ro"
  records        = [aws_rds_cluster.sample.reader_endpoint]
}