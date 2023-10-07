locals {

  # Cluster data
  cluster_encryption_config = [{
      provider_key_arn = aws_kms_key.this.arn
      resources        = ["secrets"]
  }]

  eks_cluster_id     = module.aws_eks.cluster_id
  cluster_ca_base64  = module.aws_eks.cluster_certificate_authority_data
  cluster_endpoint   = module.aws_eks.cluster_endpoint

  cluster_iam_role_name        = "${var.cluster_name}-cluster-role"
  cluster_iam_role_pathed_name = local.cluster_iam_role_name
  cluster_iam_role_pathed_arn  = "arn:${data.aws_partition.current.id}:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_iam_role_pathed_name}"

  # Network information
  vpc_id             = var.vpc_id
  private_subnet_ids = var.vpc_subnets_private
  public_subnet_ids  = var.vpc_subnets_public

  # AWS-Auth
  map_accounts = [data.aws_caller_identity.current.account_id]

  managed_node_group_aws_auth_config_map = length(var.managed_node_groups) > 0 == true ? [
    for key, node in var.managed_node_groups : {
      rolearn : try(node.iam_role_arn, "arn:${data.aws_partition.current.id}:iam::${data.aws_caller_identity.current.account_id}:role/${module.aws_eks.cluster_id}-${node.node_group_name}")
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ] : []

  # Managed node-group
  managed_ng_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  # Security groups
  cluster_security_group_additional_rules = merge(
    {
      egress = {
        description                = "To node 1025-65535"
        protocol                   = "tcp"
        from_port                  = 1025
        to_port                    = 65535
        type                       = "egress"
        source_node_security_group = true
      }
      ingress = {
        description = "Internal Access for cluster"
        type        = "ingress"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = var.whitelist_cidr_blocks
      }
    },
    # Any addtional cluster-specific Cluster-SG rules can be passed in here as a variable from the outer repo
    {}
  )
  node_security_group_additional_rules = merge(
    {
      # Extend node-to-node security group rules. Recommended and required for the Add-ons
      ingress_self_all = {
        description = "Node to node all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        self        = true
      }
      # allow nodes to talk with kubeapi
      ingress_nodes_kubeapi = {
        description = "Node to kube API all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        source_cluster_security_group = true
      }
      # Recommended outbound traffic for Node groups
      egress_all = {
        description      = "Node all egress"
        protocol         = "-1"
        from_port        = 0
        to_port          = 0
        type             = "egress"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
      }

      # Allows Control Plane Nodes to talk to Worker nodes on Karpenter ports.
      # This can be extended further to specific port based on the requirement for others Add-on e.g., metrics-server 4443, spark-operator 8080, etc.
      # Change this according to your security requirements if needed
      ingress_nodes_karpenter_port = {
        description                   = "Cluster API to Nodegroup for Karpenter"
        protocol                      = "tcp"
        from_port                     = 8443
        to_port                       = 8443
        type                          = "ingress"
        source_cluster_security_group = true
      }
    },
    # Any addtional cluster-specific Node-SG rules can be passed in here as a variable from the outer repo
    {}
  )

  node_security_group_tags = {
    "karpenter.sh/discovery/${var.cluster_name}" = var.cluster_name
  }

  # Tags
  tags = {
    Environment = var.cluster_name
    version     = var.cluster_version
    Owner       = var.owner
    App         = "eks"
  }
}
