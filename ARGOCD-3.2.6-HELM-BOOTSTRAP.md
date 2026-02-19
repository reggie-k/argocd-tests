# Argo CD 3.2.6 from Helm + self-managed Application

Chart version **9.3.7** (from argo-helm) has Argo CD appVersion **v3.2.6**. Other chart versions with the same app version: 9.3.5, 9.3.6.

## 1. Bootstrap: install Argo CD 3.2.6 with Helm

Run once so that Argo CD is running and can later manage itself:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create namespace argocd

# Use chart version 9.3.7 for Argo CD app 3.2.6
helm install argocd argo/argo-cd \
  --namespace argocd \
  --version 9.3.7
```

Wait for Argo CD to be ready (e.g. `kubectl -n argocd get pods -w`), then get the initial admin password and (optionally) expose the server:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
```

## 2. Create the Application that manages this installation

After Argo CD is up, apply the Application so that Argo CD manages its own release (GitOps for the Argo CD Helm release). The Application **name must be `argocd`** so the Helm release name is `argocd` and rendered resources get `app.kubernetes.io/instance=argocd`, matching the bootstrap install (otherwise Service selectors won't match the pods and you'll get connection refused to the repo server).

If you previously applied the app with name `argocd-self-managed`, delete it first: `kubectl delete application argocd-self-managed -n argocd`

```bash
kubectl apply -f apps/argocd-self-managed-helm-3.2.6.yaml
```

From then on, Argo CD will keep the `argocd` Helm release in sync with the chart version and values defined in that Application. You can change values or `targetRevision` in the Application (or in Git if you store this file in a repo and point Argo at it) and sync.

## Note

- The first install is done with `helm install` so there is a running Argo CD.
- The Application targets the same chart/version so the **Helm release** is adopted and managed by Argo CD; you can remove the need for manual `helm upgrade` by using this Application.
