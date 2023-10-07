#----------------------------------
# Slmetrics Service account roles
#----------------------------------

data "aws_iam_policy_document" "sa_iam_policy_document" {
  for_each = var.iam_policy_service_account_allow_resource_map
  statement {
    sid    = "allowSecrets"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]
    resources = each.value
  }
}

data "aws_iam_policy_document" "sa_iam_trusted_relation" {
  for_each = var.iam_trust_service_account_arn_map
  statement {
    sid    = "stsAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type        = "Federated"
      identifiers = [module.aws_eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.aws_eks.cluster_oidc_issuer_url}:sub"
      values   = each.value
    }
  }
}

resource "aws_iam_policy" "sa_policy" {
  for_each = var.iam_policy_service_account_allow_resource_map
  name     = "${module.aws_eks.cluster_id}-${each.key}-sa-policy"
  policy   = data.aws_iam_policy_document.sa_iam_policy_document[each.key].json
}

resource "aws_iam_role" "sa_role" {
  for_each           = var.iam_trust_service_account_arn_map
  name               = "${module.aws_eks.cluster_id}-${each.key}-sa-role"
  assume_role_policy = data.aws_iam_policy_document.sa_iam_trusted_relation[each.key].json
}

resource "aws_iam_role_policy_attachment" "sa_role_policy" {
  for_each   = var.iam_trust_service_account_arn_map
  role       = aws_iam_role.sa_role[each.key].name
  policy_arn = aws_iam_policy.sa_policy[each.key].arn
}
