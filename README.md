# argo-poc

## Installation of tools on Arch linux

1. Install Docker and core K8s tools

```
sudo pacman -S docker kubectl helm
```

2. Install k3d and ArgoCD CLI from the AUR

```
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

3. Enable and start Docker

```
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

4. Install ArgoCD using helm
```
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --wait
```

5. Create namespace for ArgoCD
```
kubectl create namespace argocd
```

## Helm cheat sheet

Execute all helm commands inside helm-directory


Build a chart eg. apps/podinfo:

```
helm dependency build apps/podinfo
```

Render a template to see the resulting Kubernetes yamls eg. apps/podinfo:

```
helm template podinfo ./apps/podinfo --debug
```

Deploy to local arch linux Kubernets cluster the podinfo example:

```
helm upgrade --install podinfo ./apps/podinfo \
  -f ./apps/podinfo/values.yaml \
  -f ./environments/local-arch-linux/podinfo-values.yaml \
  --namespace podinfo-poc --create-namespace
```

