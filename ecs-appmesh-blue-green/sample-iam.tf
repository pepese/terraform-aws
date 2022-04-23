#####################################
# ECS Task Execution Role
#####################################
resource "aws_iam_role" "sample_exec" {
  name               = "${local.base_name}-sample-exec"
  assume_role_policy = data.aws_iam_policy_document.sample_exec_assume.json
  tags               = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-exec" }))
}

data "aws_iam_policy_document" "sample_exec_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "sample_exec" {
  role       = aws_iam_role.sample_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#####################################
# ECS Task Role
#####################################
resource "aws_iam_role" "sample" {
  name               = "${local.base_name}-sample"
  assume_role_policy = data.aws_iam_policy_document.sample_assume.json
  tags               = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

data "aws_iam_policy_document" "sample_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sample" {
  count = 1
  statement {
    actions = [
      "appmesh:StreamAggregatedResources",
    ]
    resources = local.sample_param["blue_is_active"] == true ? local.sample_param["green_is_active"] == true ? ["${aws_appmesh_virtual_node.sample_blue[count.index].arn}", "${aws_appmesh_virtual_node.sample_green[count.index].arn}"] : ["${aws_appmesh_virtual_node.sample_blue[count.index].arn}"] : ["${aws_appmesh_virtual_node.sample_green[count.index].arn}"]
  }
}

resource "aws_iam_role_policy" "sample" {
  count  = 1
  role   = aws_iam_role.sample.name
  policy = data.aws_iam_policy_document.sample[count.index].json
}

resource "aws_iam_role_policy_attachment" "sample_cloudwatch" {
  role       = aws_iam_role.sample.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "sample_xray" {
  role       = aws_iam_role.sample.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}