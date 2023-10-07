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
