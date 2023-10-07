resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(
      distinct(concat(
        local.managed_node_group_aws_auth_config_map,
        var.map_roles,
      ))
    )
    mapAccounts = yamlencode(local.map_accounts)
  }

  depends_on = [module.aws_eks.cluster_id]
}
