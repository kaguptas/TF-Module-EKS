#------------------------------------------------
# IAM Role for EKS-managed node-group variables
#------------------------------------------------
data "aws_iam_policy_document" "managed_ng_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "worker_node" {
  name                  = "${module.aws_eks.cluster_id}-ondemand_v2"
  description           = "EKS Managed Node group IAM Role"
  assume_role_policy    = data.aws_iam_policy_document.managed_ng_assume_role_policy.json
  force_detach_policies = true
  tags                  = local.tags
}

resource "aws_iam_instance_profile" "worker_node" {
  name = aws_iam_role.worker_node.name
  role = aws_iam_role.worker_node.name
  tags = local.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "managed_ng_policies" {
  for_each = toset(local.managed_ng_policies)

  policy_arn = each.value
  role       = aws_iam_role.worker_node.name
}
