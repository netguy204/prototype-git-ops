

[x] build the image with pack,
- push to gar
  - Image path: us-east1-docker.pkg.dev/prod-prototype/default
[x] deploy with argocd (alt)
  - port forward to api server: kubectl port-forward svc/argocd-server -n argocd 8080:443

- define with kustomize
[x] front with kong (alt)

Make me root
```
echo -n "
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: User
  name: el.wubo@gmail.com
  namespace: kube-system" | kubectl apply -f -
```

## ArgoCD
[Install argo](https://argo-cd.readthedocs.io/en/stable/getting_started/)
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Dedicated ingress for argo
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

## Kong
Install Kong
```
kubectl create -f https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/v2.8.0/deploy/single/all-in-one-dbless.yaml
```

Create app
```
/opt/homebrew/bin/argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default
```

Deploy (sync) it
```
/opt/homebrew/bin/argocd app sync guestbook
```

Add an ingress for it
```
echo "
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: guestbook-server-http-ingress
  annotations:
    konghq.com/protocols: http
    konghq.com/strip-path: 'true'
spec:
  ingressClassName: kong
  rules:
  - http:
      paths:
      - path: /guestbook
        pathType: Prefix
        backend:
          service:
            name: guestbook-ui
            port:
              number: 80
" | kubectl apply -f -
```

## Pack (local)

Set up a reasonable builder with buildpacks that support my rust app
- builder.toml

Build that builder
```
pack builder create paketocommunity/rust-builder --config builder.toml
```

Use that builder to build this
```
pack build rustyweb --builder paketocommunity/rust-builder
```

## KPack (global)

Install kpack
```
kubectl apply -f https://github.com/pivotal/kpack/releases/download/v0.9.2/release-0.9.2.yaml
```

Install kp cli: https://github.com/vmware-tanzu/kpack-cli/releases

Binding the necessary IAM role to kpack builder sa was hell. It was important to restart the controller to get the sa to become effective.

Then getting Image resources to access creds was hell.. I think the direct docker commands executed can't get at the creds provided by the sa... so created explicit ones

> cloud console: navigate to SA, add json key, download, base64

~/bin/kp secret create artifact-key --registry https://us-east1-docker.pkg.dev --registry-user _json_key_base64 --service-account kpack-bu
ilder