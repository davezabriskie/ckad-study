# Week 3 — Day 4 Answers

---

## Block 1 — Task Interpretation Answers

**Prompt A**:
```bash
kubectl apply -k ./overlays/prod
```
`kustomization.yaml` in `overlays/prod` would contain `namePrefix: prod-`.

**Prompt B**:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
images:
  - name: nginx
    newTag: "1.22"
```

**Prompt C**:
```bash
kubectl diff -k ./overlays/prod
# or to just render without applying:
kubectl kustomize ./overlays/prod
```

---

## Block 3 — Kustomize Reference

### base/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: nginx:1.21
```

### base/service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
```

### base/kustomization.yaml
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
```

### overlays/prod/kustomization.yaml
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
namePrefix: prod-
commonLabels:
  env: prod
images:
  - name: nginx
    newTag: "1.22"
```

**What this does**:
- All resources get `prod-` prepended to their name
- All resources and their pod templates get `env: prod` label
- nginx image tag is patched to 1.22 — base file is NOT modified

---

## Block 4 — Staging Overlay

### overlays/staging/kustomization.yaml
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
namePrefix: staging-
commonLabels:
  env: staging
```

No `images` block — stays on `nginx:1.21` from base.

After applying both overlays you should see:
- `prod-web`, `prod-web-svc` with label `env=prod`
- `staging-web`, `staging-web-svc` with label `env=staging`
