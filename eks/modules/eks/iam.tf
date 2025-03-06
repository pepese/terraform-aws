resource "aws_iam_role" "eks_master_role" {
  name               = "${local.base_name}-eks-master-role"
  assume_role_policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOS
  tags               = merge(local.base_tags, map("Name", "${local.base_name}-eks-master-role"))
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy" "eks_cloud_watch_metrics_policy" {
  name   = "${local.base_name}-eks-cloud-watch-metrics-policy"
  role   = aws_iam_role.eks_master_role.id
  policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOS
}

resource "aws_iam_role_policy" "eks_nlb_policy" {
  name   = "${local.base_name}-eks-nlb-policy"
  role   = aws_iam_role.eks_master_role.id
  policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "elasticloadbalancing:*",
        "ec2:CreateSecurityGroup",
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOS
}

resource "aws_iam_role" "eks_worker_role" {
  name               = "${local.base_name}-eks-worker-role"
  assume_role_policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOS
  tags               = merge(local.base_tags, map("Name", "${local.base_name}-eks-worker-role"))
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_role_for_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_instance_profile" "eks_worker_role_profile" {
  name = "${local.base_name}-eks-worker-role-profile"
  role = aws_iam_role.eks_worker_role.name
}