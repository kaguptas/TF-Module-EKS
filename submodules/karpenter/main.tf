locals {
  values = {
    subnetSelectorKey = var.subnetSelectorKey
    subnetSelectorValue = var.subnetSelectorValue
    securityGroupSelectorKey = var.securityGroupSelectorKey
    securityGroupSelectorValue = var.securityGroupSelectorValue
    instanceProfile = var.instanceProfile
    defaultProvisionerCapacityType = var.defaultProvisionerCapacityType
    defaultProvisionerInstanceType = var.defaultProvisionerInstanceType
    cpu = var.cpu
    memory = var.memory

    tags = var.tags
  }
}

resource "helm_release" "provisioners" {
  name       = "provisioners"
  chart      = "${path.module}/helm-charts/"
  namespace  = "default"

  values     = [ yamlencode(local.values) ]
}
