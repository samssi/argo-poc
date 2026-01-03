# Create namespace
kubectl create namespace argocd

# Add and install ArgoCD via Helm
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --wait

