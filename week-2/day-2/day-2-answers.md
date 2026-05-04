# Week 2 — Day 2 Answers

Only open this to check your work after attempting each block.

---

## Block 1 — YAML Fluency Reference

### 1. Basic pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  labels:
    app: my-app
spec:
  containers:
  - name: app
    image: nginx:1.21
```

### 2. Pod with resource limits

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: limited
spec:
  containers:
  - name: app
    image: nginx:1.21
    resources:
      requests:
        cpu: "100m"
        memory: "64Mi"
      limits:
        cpu: "500m"
        memory: "128Mi"
```

### 3. Multi-container sidecar pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
spec:
  containers:
  - name: main
    image: nginx:1.21
  - name: sidecar
    image: busybox
    command: ['sh', '-c', 'while true; do echo "running"; sleep 10; done']
```

### 4. Pod with init container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
spec:
  initContainers:
  - name: init
    image: busybox
    command: ['sh', '-c', 'echo "init done"']
  containers:
  - name: app
    image: nginx:1.21
```

### 5. ConfigMap + pod with env injection

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: production
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configured-app
spec:
  containers:
  - name: app
    image: nginx:1.21
    envFrom:
    - configMapRef:
        name: app-config
```

---

## Block 3 — Reference Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deploy
  labels:
    app: web
spec:
  replicas: 3
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
        ports:
        - containerPort: 80
```

**The structure to memorize**:
- `spec.replicas` — how many pods
- `spec.selector.matchLabels` — how the Deployment finds its pods
- `spec.template` — the pod blueprint (everything under here is standard pod spec)
- `spec.template.metadata.labels` — must match `selector.matchLabels` exactly

`apiVersion: apps/v1` — not `v1`. Deployments live in the `apps` API group.

---

## Block 4 — Interpretation Answers

**Prompt A**: "Create a Deployment named `backend` with 3 replicas running `redis:7`, labeled `app=backend`"
- `apiVersion` → apps/v1
- `metadata.name` → backend
- `spec.replicas` → 3
- `spec.selector.matchLabels` → app: backend
- `spec.template.metadata.labels` → app: backend
- `spec.template.spec.containers[0].image` → redis:7

**Prompt B**: "Expose the `backend` Deployment within the cluster on port 6379"
- `kind` → Service
- `spec.selector` → app: backend (must match Deployment's pod labels)
- `spec.ports[0].port` → 6379
- `spec.ports[0].targetPort` → 6379

---

## Block 5 — Task Answers

### Quick: api Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  labels:
    app: api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: nginx:1.21
```

### Medium: api-svc Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-svc
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 80
```

If `kubectl get endpoints api-svc` shows `<none>`, the service selector doesn't match the pod labels — compare `kubectl describe svc api-svc` selector against `kubectl get pods --show-labels`.
