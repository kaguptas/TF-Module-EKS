#-------------------------------
# EKS Cluster Module Outputs
#-------------------------------
output "eks_cluster_arn" {
  description = "Amazon EKS Cluster Name"
  value       = module.aws_eks.cluster_arn
}

output "eks_cluster_id" {
  description = "Amazon EKS Cluster Name"
  value       = module.aws_eks.cluster_id
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.aws_eks.cluster_certificate_authority_data
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.aws_eks.cluster_endpoint
}

output "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = try(split("//", module.aws_eks.cluster_oidc_issuer_url)[1], "EKS Cluster not enabled") # TODO - remove `split()` since `oidc_provider` coverss https:// removal
}

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.aws_eks.oidc_provider
}

output "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = module.aws_eks.oidc_provider_arn
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.aws_eks.cluster_id}"
}

output "eks_cluster_status" {
  description = "Amazon EKS Cluster Status"
  value       = module.aws_eks.cluster_status
}

output "eks_cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.aws_eks.cluster_version
}

output "cluster_addons" {
  description = "The EKS-managed add-ons for the cluster"
  value       = module.aws_eks.cluster_addons
}

#-------------------------------
# Cluster Security Group
#-------------------------------
output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.aws_eks.cluster_primary_security_group_id
}

output "cluster_security_group_id" {
  description = "EKS Control Plane Security Group ID"
  value       = module.aws_eks.cluster_security_group_id
}

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = module.aws_eks.cluster_security_group_arn
}

#-------------------------------
# EKS Worker Security Group
#-------------------------------
output "worker_node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the worker node shared security group"
  value       = try(module.aws_eks.node_security_group_arn, "EKS Node groups not enabled")
}

output "worker_node_security_group_id" {
  description = "ID of the worker node shared security group"
  value       = try(module.aws_eks.node_security_group_id, "EKS Node groups not enabled")
}

#--------------------------------
# EKS Managed Node Groups Outputs
#--------------------------------
output "eks_managed_node_groups" {
  description = "Outputs from EKS Managed node groups "
  value       =  try(module.aws_eks.eks_managed_node_groups, "EKS Node groups not enabled")
}


#--------------------------------
# Tags
#--------------------------------

output "tags" {
  description = "Shared tags to attach"
  value       = local.tags
}

#--------------------------------
# Service Account Roles
#--------------------------------
output "sa_iam_role_arns" {
  description = "List of Service Account IAM role ARNs"
  value = values(aws_iam_role.sa_role).*.arn
}
