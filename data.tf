data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


data "aws_eks_cluster" "cluster" {
  name = module.aws_eks.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.aws_eks.cluster_id
}

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }
}


data "aws_subnet" "subnets" {
  for_each = setunion(toset(var.vpc_subnets_public), toset(var.vpc_subnets_private))
  id       = each.value
}

data "aws_subnet" "subnets_public" {
  for_each = toset(var.vpc_subnets_public)
  id       = each.value
}

data "aws_subnet" "subnets_private" {
  for_each = toset(var.vpc_subnets_private)
  id       = each.value
}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}
