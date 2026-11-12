# 1. Pre-inject the Minikube Sealed Secrets private key into kube-system
# This ensures that any SealedSecret in Git can be unsealed immediately on EKS
resource "kubernetes_manifest" "sealed_secrets_key" {
  depends_on = [module.eks]

  manifest = jsondecode(file("${path.module}/sealed-secrets-key.json"))
}

# 2. Install Argo CD via Helm
resource "helm_release" "argocd" {
  depends_on = [module.eks]

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.0.0"

  set {
    name  = "server.service.type"
    value = "NodePort" # Save money by not using a LoadBalancer for the Argo UI
  }
}

# 3. Automatically deploy Argo CD Applications once Argo CD is ready
resource "terraform_data" "deploy_argocd_apps" {
  depends_on = [helm_release.argocd, kubernetes_manifest.sealed_secrets_key]

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}
      kubectl apply -f ${path.module}/../realestate-chart/sealed-secrets-controller.yaml
      kubectl apply -f ${path.module}/../realestate-chart/argocd-app.yaml
    EOT
  }
}
