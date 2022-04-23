#####################################
# RDS
#####################################
resource "aws_db_instance" "ms1_rds" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
  identifier           = "${var.base_name}-ms1-rds" # name ではなくこちら（小文字英字・数字・ハイフン、ユニーク）
  allocated_storage    = var.rds_settings["allocated_storage"]
  engine               = var.rds_settings["engine"]
  engine_version       = var.rds_settings["engine_version"]
  instance_class       = var.rds_settings["instance_class"]
  username             = var.rds_settings["username"]
  password             = var.rds_settings["password"]
  db_subnet_group_name = aws_db_subnet_group.ms1_rds_dbsg.name
  parameter_group_name = aws_db_parameter_group.ms1_rds_dbpg.name
  vpc_security_group_ids = [
    aws_security_group.ms1_rds_sg.id,
  ]
  skip_final_snapshot     = true
  multi_az                = true
  monitoring_interval     = 30                                # 拡張モニタリング
  monitoring_role_arn     = aws_iam_role.ms1_rds_iam_role.arn # 拡張モニタリング
  backup_retention_period = "7"                               # 最大7日間保管するバックアップを
  backup_window           = "00:00-01:00"                     # 毎日深夜の0:00に取得する
  apply_immediately       = "true"                            # terraform applyを実行直後にDBへの変更が適用される
  tags                    = merge(tomap({ "Service" = "sm1" }), tomap({ "Name" = "${var.base_name}-ms1-rds" }))
}

#####################################
# DB Subnet Group
#####################################
resource "aws_db_subnet_group" "ms1_rds_dbsg" {
  name = "${var.base_name}-ms1-rds-dbsg"
  subnet_ids = [
    aws_subnet.cmn_subnet_private_1a.id,
    aws_subnet.cmn_subnet_private_1c.id,
  ]

  tags = merge(tomap({ "Service" = "sm1" }), tomap({ "Name" = "${var.base_name}-ms1-rds-dbsg" }))
}

#####################################
# Security Group
#####################################
resource "aws_security_group" "ms1_rds_sg" {
  name   = "${var.base_name}-ms1-rds-sg"
  vpc_id = aws_vpc.cmn_vpc.id
  tags   = merge(tomap({ "Service" = "sm1" }), tomap({ "Name" = "${var.base_name}-ms1-rds-sg" }))
}

# resource "aws_security_group_rule" "ms1_rds_sg_ingress_rule" {
#   security_group_id = aws_security_group.ms1_rds_sg.id

#   type                     = "ingress"
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.ms1_ecs_service_sg.id
# }

#####################################
# Parameter Group
#####################################
resource "aws_db_parameter_group" "ms1_rds_dbpg" {
  name   = "${var.base_name}-ms1-rds-dbpg"
  family = "postgres13"

  # install libraries
  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements ,pg_hint_plan ,pgaudit"
    apply_method = "pending-reboot"
  }

  # audit setting
  parameter {
    name         = "pgaudit.log_catalog"
    value        = true
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.log_parameter"
    value        = true
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.log_relation"
    value        = true
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.log_statement_once"
    value        = true
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.log"
    value        = "ddl ,misc ,role"
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.role"
    value        = "rds_pgaudit"
    apply_method = "immediate"
  }

  # no local
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

  tags = merge(tomap({ "Service" = "ms1" }), tomap({ "Name" = "${var.base_name}-ms1-rds-dbpg" }))
}

#####################################
# Data: IAM Policy Document
#####################################
data "aws_iam_policy_document" "ms1_rds_iam_policy" {
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
resource "aws_iam_role" "ms1_rds_iam_role" {
  name               = "${var.base_name}-ms1-rds-iam-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ms1_rds_iam_policy.json
  tags               = merge(tomap({ "Service" = "sm1" }), tomap({ "Name" = "${var.base_name}-ms1-rds-iam-role" }))
}

resource "aws_iam_role_policy_attachment" "ms1_rds_enhanced_monitoring" {
  role       = aws_iam_role.ms1_rds_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}