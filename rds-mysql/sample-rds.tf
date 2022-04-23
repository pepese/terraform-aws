#####################################
# RDS
#####################################
resource "aws_db_instance" "sample" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
  identifier           = "${local.base_name}-sample" # name ではなくこちら（小文字英字・数字・ハイフン、ユニーク）
  allocated_storage    = local.rds_settings["allocated_storage"]
  engine               = local.rds_settings["engine"]
  engine_version       = local.rds_settings["engine_version"]
  instance_class       = local.rds_settings["instance_class"]
  username             = local.rds_settings["username"]
  password             = local.rds_settings["password"]
  db_subnet_group_name = aws_db_subnet_group.sample.name
  parameter_group_name = aws_db_parameter_group.sample.name
  vpc_security_group_ids = [
    aws_security_group.sample_rds.id,
  ]
  skip_final_snapshot     = true
  multi_az                = true
  monitoring_interval     = 30                          # 拡張モニタリング
  monitoring_role_arn     = aws_iam_role.sample_rds.arn # 拡張モニタリング
  backup_retention_period = "7"                         # 最大7日間保管するバックアップを
  backup_window           = "00:00-01:00"               # 毎日深夜の0:00に取得する
  apply_immediately       = "true"                      # terraform applyを実行直後にDBへの変更が適用される
  tags                    = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
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
# Security Group
#####################################
resource "aws_security_group" "sample_rds" {
  name   = "${local.base_name}-sample-rds"
  vpc_id = aws_vpc.sample.id
  tags   = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-rds" }))
}

resource "aws_security_group_rule" "sample_rds_ingress" {
  security_group_id = aws_security_group.sample_rds.id

  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sample_ec2.id
}

#####################################
# Parameter Group
#####################################
resource "aws_db_parameter_group" "sample" {
  name   = "${local.base_name}-sample"
  family = "mysql5.7"

  parameter {
    name         = "time_zone"
    value        = "Asia/Tokyo"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "slow_query_log"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "long_query_time"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_output"
    value        = "TABLE"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "performance_schema"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "skip_name_resolve"
    value        = "1"
    apply_method = "pending-reboot"
  }

  # 以降、文字コード関連
  # https://aws.amazon.com/jp/blogs/news/best-practices-for-configuring-parameters-for-amazon-rds-for-mysql-part-3-parameters-related-to-security-operational-manageability-and-connectivity-timeout/
  parameter {
    name         = "character_set_client"
    value        = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "character_set_connection"
    value        = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "character_set_database"
    value        = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "character_set_results"
    value        = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "character_set_server"
    value        = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "skip-character-set-client-handshake"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "init_connect"
    value        = "SET NAMES utf8mb4"
    apply_method = "pending-reboot"
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# IAM Settings
#####################################
resource "aws_iam_role" "sample_rds" {
  name               = "${local.base_name}-sample-rds"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.sample_rds_assume.json
  tags               = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-rds" }))
}

data "aws_iam_policy_document" "sample_rds_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "sample_rds_monitoring" {
  role       = aws_iam_role.sample_rds.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}