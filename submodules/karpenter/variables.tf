variable "subnetSelectorKey" {
  description = "Subnet selector tag key"
  type        = string
}

variable "subnetSelectorValue" {
  description = "Subnet selector tag value"
  type        = string
}

variable "securityGroupSelectorKey" {
  description = "Security group selector tag key"
  type        = string
}

variable "securityGroupSelectorValue" {
  description = "Security group selector tag value"
  type        = string
}

variable "instanceProfile" {
  description = "IAM instance profile for the Karpenter nodes"
  type        = string
}

variable "defaultProvisionerCapacityType" {
  description = "Capacity-type for the Karpenter nodes, 'spot' or 'on-demand'."
  type        = string
}

variable "defaultProvisionerInstanceType" {
  description = "Instance-type for the Karpenter nodes"
  type        = list(string)
}

variable "cpu" {
  description = "The CPU limit that should be managed by the Karpenter provisioner."
  type        = string
}

variable "memory" {
  description = "The memory limit that should be managed by the Karpenter provisioner."
  type        = string
}

variable "tags" {
  description = "The memory limit that should be managed by the Karpenter provisioner."
  type        = map(string)
}
