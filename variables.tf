#-------------------------------
# AWS config variables
#-------------------------------
variable "aws_region" {
  description = "AWS region for the resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "vpc_subnets_private" {
  description = "VPC subnets"
  type        = list(string)
}

variable "vpc_subnets_public" {
  description = "VPC subnets"
  type        = list(string)
}


#-------------------------------
# EKS variables
#-------------------------------
variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.24`)"
  type        = string
  default     = "1.27"
}

variable "cluster_kms_key_additional_admin_arns" {
  description = "A list of additional IAM ARNs that should have FULL access (kms:*) in the KMS key policy"
  type        = list(string)
  default     = []
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "Cluster IAM role path"
  type        = string
  default     = null
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
  type        = string
  default     = null
}

variable "cluster_service_ipv6_cidr" {
  description = "The IPV6 Service CIDR block to assign Kubernetes service IP addresses"
  type        = string
  default     = null
}


#-------------------------------
# EKS Cluster Security Groups
#-------------------------------
variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}


#-------------------------------
# EKS-managed Node Group
#-------------------------------
variable "managed_node_groups" {
  description = "Map of node group configuration variables"
  type = map(object({
    node_group_name         = string
    capacity_type           = string
    instance_types          = list(string)
    min_size                = number
    max_size                = number
    enable_metadata_options = optional(bool, false)
  }))
}

variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
  default     = {}
}

variable "node_security_group_tags" {
  description = "A map of additional tags to add to the node security group created"
  type        = map(string)
  default     = {}
}


#-------------------------------
# Auth
#-------------------------------
variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "addtl_map_role_list" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}


#-------------------------------
# Tags
#-------------------------------
variable "env" {
  description = "Environment"
  type        = string
}

variable "owner" {
  description = "Name of cluster owner"
  type        = string
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}


#-------------------------------
# Security Groups
#-------------------------------

variable "whitelist_cidr_blocks" {
  description = "CIDR blocks to whitelist for SG rules"
  type        = list(string)
}



#-------------------------------
# Service Accounts
#-------------------------------
variable "iam_trust_service_account_arn_map" {
  description = "Service accounts to insert in trust policy"
  type        = map(list(string))
}

variable "iam_policy_service_account_allow_resource_map" {
  description = "Resources to allow service account access to"
  type        = map(list(string))
}


#-------------------------------
# Karpenter
#-------------------------------
variable "karpenter_default_node_capacity" {
  description = "Capacity-type for the Karpenter nodes, 'spot' or 'on-demand'"
  type        = string
  default     = "on-demand"
}

variable "karpenter_default_node_instance" {
  description = "Instance-type for the Karpenter nodes"
  type        = list(string)
  default     = ["m6a.large"]
}

variable "karpenter_default_node_memory" {
  description = "The memory limit that should be managed by the Karpenter provisioner."
  type        = string
  default     = "40Gi"
}

variable "karpenter_default_node_cpu" {
  description = "The CPU limit that should be managed by the Karpenter provisioner."
  type        = string
  default     = "10"
}
