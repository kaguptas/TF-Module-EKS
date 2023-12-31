variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = ""
}

variable "eks_endpoint" {
  description = "EKS OIDC Provider URL"
  type        = string
  default     = ""
}

variable "eks_oidc_provider_url" {
  description = "EKS OIDC Provider URL"
  type        = string
  default     = ""
}

variable "worker_node_iam_role" {
  description = "Karpenter node IAM role name"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "String list of private subnets ID's"
  type        = string
  default     = ""
}

variable "karpenter_default_node_capacity" {
  description = "Capacity-type for the Karpenter nodes, 'spot' or 'on-demand'."
  type        = string
}

variable "karpenter_default_node_instance" {
  description = "Instance-type for the Karpenter nodes"
  type        = list(string)
}

variable "karpenter_default_node_cpu" {
  description = "The CPU limit that should be managed by the Karpenter provisioner."
  type        = string
}

variable "karpenter_default_node_memory" {
  description = "The memory limit that should be managed by the Karpenter provisioner."
  type        = string
}

variable "tags" {
  description = "The memory limit that should be managed by the Karpenter provisioner."
  type        = map(string)
}
