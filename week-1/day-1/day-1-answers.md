# Week 1 — Day 1 Answers

Only open this to check your work after attempting each block.

---

## Block 2 — Reference Pod

Study this, then close the file and write it from memory.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-server
  labels:
    app: web
spec:
  containers:
  - name: web
    image: nginx:1.21
    ports:
    - containerPort: 80
```

---

## Block 3 — Field Mapping Answers

**Prompt A**: "Create a pod named `cache` running `redis:7` with label `tier=backend`"
- `metadata.name` → cache
- `metadata.labels` → tier: backend
- `spec.containers[0].name` → cache (or anything)
- `spec.containers[0].image` → redis:7

**Prompt B**: "Create a pod named `logger` with two containers: `app` running `busybox` that sleeps forever, and `log-sidecar` running `fluentd:v1.14`"
- `metadata.name` → logger
- `spec.containers[0].name` → app
- `spec.containers[0].image` → busybox
- `spec.containers[0].command` → needed (sleep forever)
- `spec.containers[1].name` → log-sidecar
- `spec.containers[1].image` → fluentd:v1.14

---

## Block 4 — Task Answers

### Quick Task: Pod with labels

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  labels:
    app: frontend
    tier: web
spec:
  containers:
  - name: app
    image: nginx:1.21
    ports:
    - containerPort: 80
```

### Medium Task: Multi-container sidecar pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-sidecar
  labels:
    app: demo
spec:
  containers:
  - name: main-app
    image: nginx:1.21
  - name: log-sidecar
    image: busybox
    command: ['sh', '-c', 'while true; do echo "sidecar running"; sleep 30; done']
```
