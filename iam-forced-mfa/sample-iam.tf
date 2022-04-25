#####################################
# IAM / Group
#####################################
resource "aws_iam_group" "sample_developers" {
  count = length(local.sample_iam_dev_users) > 0 ? 1 : 0
  name  = "Developers"
}

resource "aws_iam_group_policy_attachment" "sample_developers_readonly" {
  count      = length(local.sample_iam_dev_users) > 0 ? 1 : 0
  group      = aws_iam_group.sample_developers[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "sample_developers_codeartifact_readonly" {
  count      = length(local.sample_iam_dev_users) > 0 ? 1 : 0
  group      = aws_iam_group.sample_developers[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeArtifactReadOnlyAccess"
}

resource "aws_iam_policy" "sample_developers" {
  count       = length(local.sample_iam_dev_users) > 0 ? 1 : 0
  name        = "${local.base_name}-sample-developers"
  description = "Policy for developers"
  policy      = data.aws_iam_policy_document.sample_developers.json
  tags        = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-developers" }))
}

data "aws_iam_policy_document" "sample_developers" {
  statement { // codeartifact
    actions = [
      "codeartifact:DeletePackageVersions",
      "codeartifact:DisposePackageVersions",
      "codeartifact:PublishPackageVersion",
      "codeartifact:PutPackageMetadata",
      "codeartifact:TagResource",
      "codeartifact:UntagResource",
      "codeartifact:UpdatePackageVersionsStatus",
      "codeartifact:GetAuthorizationToken",
    ]
    resources = [
      "*",
    ]
  }
  statement { // cloudwatch logs insights
    actions = [
      "logs:StopQuery",
      "logs:StartQuery",
      "logs:PutQueryDefinition",
      "logs:GetQueryResults",
      "logs:DescribeQueryDefinitions",
      "logs:DescribeQueries",
      "logs:DeleteQueryDefinition",
      "cloudwatch:TagResource",
      "cloudwatch:PutInsightRule",
      "cloudwatch:GetInsightRuleReport",
      "cloudwatch:EnableInsightRules",
      "cloudwatch:DescribeInsightRules",
      "cloudwatch:DeleteInsightRules",
    ]
    resources = [
      "*",
    ]
  }
  statement { // mfa 強制
    effect = "Deny"
    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GetUser",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
      "iam:ChangePassword",
      "sts:GetSessionToken",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}

resource "aws_iam_group_policy_attachment" "sample_developers" {
  count      = length(local.sample_iam_dev_users) > 0 ? 1 : 0
  group      = aws_iam_group.sample_developers[count.index].name
  policy_arn = aws_iam_policy.sample_developers[count.index].arn
}

#####################################
# IAM / User
#####################################
resource "aws_iam_user" "sample_developers" {
  for_each = toset(local.sample_iam_dev_users)
  name     = each.value
  tags     = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-developers" }))
}

resource "aws_iam_user_login_profile" "sample_developers" {
  for_each = toset(local.sample_iam_dev_users)
  user     = each.value
  depends_on = [
    aws_iam_user.sample_developers,
  ]
  password_reset_required = true
  password_length         = "13"
  lifecycle {
    ignore_changes = [
      password,
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }
}

resource "aws_iam_user_policy" "sample_developers" {
  for_each = toset(local.sample_iam_dev_users)
  user     = each.value
  depends_on = [
    aws_iam_user.sample_developers,
  ]
  name   = "${local.base_name}-sample-developers-${each.value}"
  policy = data.aws_iam_policy_document.sample_developers_user["${each.key}"].json
}

data "aws_iam_policy_document" "sample_developers_user" {
  for_each = toset(local.sample_iam_dev_users)
  depends_on = [
    aws_iam_user.sample_developers,
  ]
  statement {
    actions = [
      "iam:ChangePassword",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile",
      "iam:CreateServiceSpecificCredential",
      "iam:DeactivateMFADevice",
      "iam:DeleteAccessKey",
      "iam:DeleteLoginProfile",
      "iam:DeleteSSHPublicKey",
      "iam:DeleteServiceSpecificCredential",
      "iam:DeleteSigningCertificate",
      "iam:EnableMFADevice",
      "iam:ResetServiceSpecificCredential",
      "iam:ResyncMFADevice",
      "iam:UpdateAccessKey",
      "iam:UpdateLoginProfile",
      "iam:UpdateSSHPublicKey",
      "iam:UpdateServiceSpecificCredential",
      "iam:UpdateSigningCertificate",
      "iam:UploadSSHPublicKey",
      "iam:UploadSigningCertificate",
      "iam:ListMFADevices",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:user/${each.value}",
    ]
  }
  statement { // mfa 許可
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:ListMFADeviceTags",
      "iam:TagMFADevice",
      "iam:UntagMFADevice",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:mfa/${each.value}*",
      "arn:aws:iam::${local.account_id}:sms-mfa/${each.value}*",
    ]
  }
  statement {
    actions = [
      "iam:List*",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_group_membership" "sample_developers" {
  count = length(local.sample_iam_dev_users) > 0 ? 1 : 0
  depends_on = [
    aws_iam_user.sample_developers,
  ]
  name  = "${local.base_name}-sample-developers-membership"
  users = local.sample_iam_dev_users
  group = aws_iam_group.sample_developers[count.index].name
}