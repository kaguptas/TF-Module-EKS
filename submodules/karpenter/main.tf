locals {
  values = {
    subnetSelectorKey              = "aws-ids"
    subnetSelectorValue            = join(",", [for s in data.aws_subnet.subnets : s.id])
    securityGroupSelectorKey       = "karpenter.sh/discovery/${var.cluster_name}"
    securityGroupSelectorValue     = var.cluster_name
    instanceProfile                = aws_iam_instance_profile.karpenter.name
    defaultProvisionerCapacityType = var.karpenter_default_node_capacity
    defaultProvisionerInstanceType = var.karpenter_default_node_instance
    cpu                            = var.karpenter_default_node_cpu
    memory                         = var.karpenter_default_node_memory

    tags = local.tags
  }
}

#---------------------------------
# Karpenter-controller IRSA role
#---------------------------------
module "iam_assumable_role_karpenter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "karpenter-controller-${var.cluster_name}"
  provider_url                  = var.eks_oidc_provider_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:karpenter:karpenter"]
}

resource "aws_iam_role_policy" "karpenter_contoller" {
  name = "karpenter-policy-${var.cluster_name}"
  role = module.iam_assumable_role_karpenter.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "iam:PassRole",
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

#---------------------------------
# Karpenter-node permissions
#---------------------------------

# Utilizing same IAM role as the EKS managed-nodes (so we don't need to reconfigure aws-auth),
# this section adds karpenter-node policies to that role (the policy to grab the EKS AMI from public SSM)
data "aws_iam_policy" "ssm_managed_instance" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm_policy" {
  role       = var.worker_node_iam_role
  policy_arn = data.aws_iam_policy.ssm_managed_instance.arn
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = var.worker_node_iam_role
}

#---------------------------------
# Karpenter Helm Release
#---------------------------------
resource "kubernetes_namespace" "karpenter" {
  metadata {
    annotations = {
      name = "karpenter"
    }
    name = "karpenter"
  }
}

resource "helm_release" "karpenter" {
  depends_on = [kubernetes_namespace.karpenter]

  namespace = "karpenter"

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "0.16.3"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_karpenter.iam_role_arn
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "clusterEndpoint"
    value = module.aws_eks.cluster_endpoint
  }
  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }
}

#---------------------------------
# Karpenter Provisioner(s)
#---------------------------------
resource "helm_release" "provisioners" {
  depends_on = [helm_release.karpenter]

  name       = "provisioners"
  chart      = "./helm-charts/"
  namespace  = "default"

  values     = [ yamlencode(local.values) ]
}
