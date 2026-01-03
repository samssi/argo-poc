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

4. Install ArgoCD

```
helm dependency build ./bootstrap/argocd

helm upgrade --install argocd ./bootstrap/argocd \
  --namespace argocd \
  --create-namespace \
  --wait
```

5. Generate self signed certificate

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=argocd.samssi.com"

kubectl create secret tls argocd-server-tls \
  --cert=tls.crt \
  --key=tls.key \
  -n argocd

# Clean up the temporary files
rm tls.crt tls.key
``

6. Get ArgoCD secrets

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
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

Update deployment manually:

```
helm upgrade --install argocd ./bootstrap/argocd -n argocd
```

Restart proxy traefik:

```
kubectl rollout restart deployment traefik -n kube-system
```