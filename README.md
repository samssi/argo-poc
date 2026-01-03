# argo-poc

## Automated installation of ArgoCD

Execute these in the helm/-directory

0. Cleanup local Kubernetes setup

```
k3d cluster delete -a
k3d cluster create poc-cluster \
  -p "8080:80@loadbalancer" \
  -p "8443:443@loadbalancer"
```

1. Create namespace for ArgoCD

```
kubectl create ns argocd
```

2. Add ssh key for ArgoCD and to the repository

```
cat <<EOF > repo-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@github.com:samssi/argo-poc.git
  sshPrivateKey: |
$(cat ~/.ssh/argocd | sed 's/^/    /')
EOF

kubectl apply -f repo-secret.yaml
rm repo-secret.yaml
```

3. Install ArgoCD helm template from the repo

``` 
helm upgrade --install argocd ./bootstrap/argocd \
  -n argocd \
  -f ./bootstrap/argocd/values.yaml
```

4. Let ArgoCD to take over by provisining the bootstrap app

```
kubectl apply -f root-app.yaml
```

5. Login to ArgoCD

Use k9s and make a port forward to ArgoCD server

Username is admin, fetch the password using this command:

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

## Installation of tools on Arch linux and initial manual installation of ArgoCD (not needed, this was how the initial setup was done)

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
```

6. Get ArgoCD login secret

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Username is: admin

7. Create and add private ssh key for ArgoCD as Kubernetes secret

```
cat <<EOF > repo-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@github.com:samssi/argo-poc.git
  sshPrivateKey: |
$(cat ~/.ssh/argocd | sed 's/^/    /')
EOF

kubectl apply -f repo-secret.yaml
rm repo-secret.yaml
```

8. Provision the root-app.yaml to Kubernetes cluster

```
kubectl apply -f root-app.yaml
```

The ArgoCD now can connect to the repo and self configure itself!

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