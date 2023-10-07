locals {
  ebs_controller_sa = "ebs-csi-controller-sa"
}

resource "aws_iam_policy" "ebs_policy" {
  name   = "${var.eks_cluster_id}-ebs-policy"
  policy = data.aws_iam_policy_document.ebs_policy.json
}

resource "aws_iam_role" "ebs_role" {
  name               = "${var.eks_cluster_id}-ebs_role"
  assume_role_policy = data.aws_iam_policy_document.iam_trusted_relation.json
}

resource "aws_iam_role_policy_attachment" "ebs_role_policy" {
  role       = aws_iam_role.ebs_role.name
  policy_arn = aws_iam_policy.ebs_policy.arn
}

resource "helm_release" "ebs_driver" {
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver/"
  chart      = "aws-ebs-csi-driver"
  version    = "2.12.1"

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.ebs_role.arn
  }
  set {
    name  = "controller.extraVolumeTags.ClusterName"
    value = var.cluster_name
  }
  set {
    name  = "controller.extraVolumeTags.Owner"
    value = var.owner
  }
}

resource "kubernetes_annotations" "gp2_non_default" {
  depends_on = [
    helm_release.ebs_driver
  ]
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = true
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
}

resource "kubernetes_storage_class" "gp3" {
  depends_on = [
    kubernetes_annotations.gp2_non_default, helm_release.ebs_driver
  ]
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  parameters = {
    type = "gp3"
  }
  volume_binding_mode = "WaitForFirstConsumer"
}
