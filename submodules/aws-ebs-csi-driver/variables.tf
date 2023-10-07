variable "owner" {
  description = "Name of cluster owner"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "eks_cluster_id" {
  description = "EKS Cluster ID"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "The OpenID Connect identity provider ARN"
  type        = string
}

variable "eks_oidc_issuer_url" {
  description = "The OpenID Connect identity issuer URL"
  type        = string
}
