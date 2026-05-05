# Week 2 — Day 4 Answers

---

## Block 1 — Blue/Green Reference YAML

### web-v1 Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
      version: v1
  template:
    metadata:
      labels:
        app: web
        version: v1
    spec:
      containers:
        - name: web
          image: nginx:1.21
```

### web-v2 Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-v2
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
      version: v2
  template:
    metadata:
      labels:
        app: web
        version: v2
    spec:
      containers:
        - name: web
          image: nginx:1.22
```

### Service (initially targeting v1)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    app: web
    version: v1
  ports:
    - port: 80
      targetPort: 80
```

### Traffic switch to v2
```bash
kubectl patch service web-svc -p '{"spec":{"selector":{"version":"v2"}}}'
```

**Pattern summary**: Both Deployments always run. The Service selector is the only control. Rollback = patch selector back to v1.

---

## Block 2 — Canary Reference YAML

### Stable Deployment (with shared label)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-v1
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
```

### Canary Deployment (same shared label, different image)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-canary
spec:
  replicas: 1
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
          image: nginx:1.22
```

### Service (selects shared label only)
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

**Ratio control**:
- 3 stable + 1 canary = 75/25
- 2 stable + 2 canary = 50/50
- 0 stable + 3 canary = full promotion

**Pattern summary**: No special K8s feature. Shared label + replica count = traffic split. Promote by draining stable replicas and scaling canary up.

---

## Block 4 — ConfigMap Reference YAML

### ConfigMap YAML form
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-cfg
data:
  ENV: prod
  LOG_LEVEL: warn
```

### Deployment with envFrom (all keys)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  labels:
    app: app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
        - name: app
          image: nginx:1.21
          envFrom:
            - configMapRef:
                name: app-cfg
```

### Deployment with valueFrom (single key)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  labels:
    app: app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
        - name: app
          image: nginx:1.21
          env:
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: app-cfg
                  key: LOG_LEVEL
```

**Key distinction**:
- `envFrom` → `configMapRef` — all keys injected, env var names come from ConfigMap keys
- `env` → `valueFrom.configMapKeyRef` — one key, you control the env var name