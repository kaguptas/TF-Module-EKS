provider "aws" {
  region = var.aws_region
}

# Required for public ECR where Karpenter artifacts are hosted
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

provider "kubernetes" {
  host                   = module.aws_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.aws_eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.aws_eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# public subnet tags
resource "aws_ec2_tag" "subnet_tags_public_common" {
  count       = length(var.vpc_subnets_public)
  resource_id = var.vpc_subnets_public[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

# private subnet tags
resource "aws_ec2_tag" "subnet_tags_private_common" {
  count       = length(var.vpc_subnets_private)
  resource_id = var.vpc_subnets_private[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

module "aws_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "v18.29.1"

  cluster_name     = var.cluster_name
  cluster_version  = var.cluster_version
  vpc_id                        = var.vpc_id
  subnet_ids                    = var.vpc_subnets_private
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = false
  cluster_ip_family                    = "ipv4"

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  iam_role_name                 = local.cluster_iam_role_name
  iam_role_use_name_prefix      = false

  cluster_security_group_additional_rules = local.cluster_security_group_additional_rules
  node_security_group_additional_rules = local.node_security_group_additional_rules
  node_security_group_tags             = local.node_security_group_tags

  attach_cluster_encryption_policy = false
  cluster_encryption_config        = local.cluster_encryption_config

  tags = local.tags

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m5.large"]
  }

  eks_managed_node_groups = {
    ondemand_v2 = {
      name            = "ondemand_v2"
      capacity_type   = "ON_DEMAND"
      instance_types  = ["m5.2xlarge"]
      min_size        = 2
      max_size        = 2
      desired_size    = 2

      subnet_ids = var.vpc_subnets_private

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 100
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 125
            encrypted             = true
            kms_key_id            = ""
            delete_on_termination = true
          }
        }
      }

      create_iam_role          = false
      iam_role_arn = aws_iam_role.worker_node.arn

      ami_id                     = data.aws_ami.eks_default.image_id
      enable_bootstrap_user_data = true

      create_security_group          = true
      security_group_name            = "eks-managed-node-group"
      security_group_rules = {
        ingress_self_all = {
          description = "Node to node all ports/protocols"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          type        = "ingress"
          self        = true
        }
        ingress_nodes_kubeapi = {
          description                   = "Node to kube API all ports/protocols"
          protocol                      = "-1"
          from_port                     = 0
          to_port                       = 0
          type                          = "ingress"
          source_cluster_security_group = true
        }
        egress_all = {
          description      = "Node all egress"
          protocol         = "-1"
          from_port        = 0
          to_port          = 0
          type             = "egress"
          cidr_blocks      = ["0.0.0.0/0"]
          ipv6_cidr_blocks = ["::/0"]
        }
        ingress_nodes_karpenter_port = {
          description                   = "Cluster API to Nodegroup for Karpenter"
          protocol                      = "tcp"
          from_port                     = 8443
          to_port                       = 8443
          type                          = "ingress"
          source_cluster_security_group = true
        }
      }
      security_group_tags = {
        Purpose = "Protector of the kubelet"
      }

      tags = {
        "Name"                                                    = "${module.aws_eks.cluster_id}-ondemand_v2"
        "kubernetes.io/cluster/${module.aws_eks.cluster_id}"     = "owned"
      }
    }
  }
}

module "aws_rbac" {
  depends_on = [module.aws_eks.cluster_id]

  source = "./submodules/aws-rbac"
}

module "karpenter" {
  depends_on = [module.aws_eks.cluster_id]

  source = "./submodules/karpenter"

  cluster_name                   = var.cluster_name
  eks_oidc_provider_url          = module.aws_eks.cluster_oidc_issuer_url)[1]
  worker_node_iam_role           = aws_iam_role.worker_node.name
  defaultProvisionerCapacityType = var.karpenter_default_node_capacity
  defaultProvisionerInstanceType = var.karpenter_default_node_instance
  cpu                            = var.karpenter_default_node_cpu
  memory                         = var.karpenter_default_node_memory

  tags = local.tags
}
