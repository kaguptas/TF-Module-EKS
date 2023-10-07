resource "helm_release" "rbac" {
  name      = "k8s-rbac"
  chart     = "${path.module}/helm-charts/"
}
