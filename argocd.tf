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

# 3. Deploy Sealed Secrets Controller Application into Argo CD
# Depends on Argo CD being installed and the decryption key being present in kube-system
resource "kubernetes_manifest" "argocd_sealed_secrets_app" {
  depends_on = [helm_release.argocd, kubernetes_manifest.sealed_secrets_key]

  manifest = yamldecode(file("${path.module}/../realestate-chart/sealed-secrets-controller.yaml"))
}

# 4. Deploy the Main RealEstate Microservices Application into Argo CD
# Depends on Argo CD and the Sealed Secrets app being triggered
resource "kubernetes_manifest" "argocd_realestate_app" {
  depends_on = [helm_release.argocd, kubernetes_manifest.argocd_sealed_secrets_app]

  manifest = yamldecode(file("${path.module}/../realestate-chart/argocd-app.yaml"))
}
