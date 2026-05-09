# Week 2 — Day 5 Answers

---

## Block 1 — Full Stack Reference

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-cfg
data:
  ENV: prod
  LOG_LEVEL: warn
---
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
---
apiVersion: v1
kind: Service
metadata:
  name: app-svc
spec:
  selector:
    app: app
  ports:
    - port: 80
      targetPort: 80
```

---

## Block 2 — Rollout + Rollback Reference

```bash
kubectl create deployment backend --image=redis:7 --replicas=3
kubectl set image deployment/backend redis=redis:7.2
kubectl rollout status deployment/backend
kubectl describe deployment backend | grep Image
kubectl rollout undo deployment/backend
kubectl rollout status deployment/backend
kubectl describe deployment backend | grep Image   # confirm back on redis:7
```

---

## Block 3 — Task Interpretation Answers

**Prompt A** — fields:
- `kind: Deployment`, `name: api`, `replicas: 2`, `image: nginx:1.21`
- `selector.matchLabels: app=api`, `template.labels: app=api`
- Service: `kind: Service`, `selector: app=api`, `port: 80`, `targetPort: 80`

**Prompt B** — fields:
- `kind: Job`, `name: db-init`, `image: busybox`
- `command: ['sh', '-c', 'echo "database initialized"']`
- `restartPolicy: Never`, `completions: 1`

**Prompt C** — fields:
- `kind: ConfigMap`, `name: cfg`, `data.DB: postgres`
- Deployment: `envFrom.configMapRef.name: cfg`
