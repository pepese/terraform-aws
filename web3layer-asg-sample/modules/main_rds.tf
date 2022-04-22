#####################################
# RDS
#####################################
resource "aws_db_instance" "rds" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
  identifier           = "${var.base_name}-rds" # name ではなくこちら（小文字英字・数字・ハイフン、ユニーク）
  allocated_storage    = var.rds_settings["allocated_storage"]
  engine               = var.rds_settings["engine"]
  engine_version       = var.rds_settings["engine_version"]
  instance_class       = var.rds_settings["instance_class"]
  username             = var.rds_settings["username"]
  password             = var.rds_settings["password"]
  db_subnet_group_name = aws_db_subnet_group.rds_dbsg.name
  parameter_group_name = aws_db_parameter_group.rds_dbpg.name
  vpc_security_group_ids = [
    aws_security_group.rds_sg.id,
  ]
  skip_final_snapshot     = true
  multi_az                = true
  monitoring_interval     = 30                            # 拡張モニタリング
  monitoring_role_arn     = aws_iam_role.rds_iam_role.arn # 拡張モニタリング
  backup_retention_period = "7"                           # 最大7日間保管するバックアップを
  backup_window           = "00:00-01:00"                 # 毎日深夜の0:00に取得する
  apply_immediately       = "true"                        # terraform applyを実行直後にDBへの変更が適用される
  tags                    = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-rds" }))
}

#####################################
# DB Subnet Group
#####################################
resource "aws_db_subnet_group" "rds_dbsg" {
  name = "${var.base_name}-rds-dbsg"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id,
  ]

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-rds-dbsg" }))
}

#####################################
# Security Group
#####################################
resource "aws_security_group" "rds_sg" {
  name   = "${var.base_name}-rds-sg"
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-rds-sg" }))
}

resource "aws_security_group_rule" "rds_sg_ingress_rule" {
  security_group_id = aws_security_group.rds_sg.id

  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_sg.id
}

#####################################
# Parameter Group
#####################################
resource "aws_db_parameter_group" "rds_dbpg" {
  name   = "${var.base_name}-db-parameter-group"
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

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-db-parameter-group" }))
}

#####################################
# Data: IAM Policy Document
#####################################
data "aws_iam_policy_document" "rds_iam_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

#####################################
# IAM Settings
#####################################
resource "aws_iam_role" "rds_iam_role" {
  name               = "${var.base_name}-rds-iam-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.rds_iam_policy.json
  tags               = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-rds-iam-role" }))
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}