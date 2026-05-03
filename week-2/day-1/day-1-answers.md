# Week 2 — Day 1 Answers

Only open this to check your work after attempting each block.

---

## Block 2 — Reference YAML

### Service (ClusterIP)

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

`type: ClusterIP` is the default — you don't need to write it, but it's valid to include.

### Sidecar Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-demo
  labels:
    app: demo
spec:
  containers:
  - name: main-app
    image: nginx:1.21
    ports:
    - containerPort: 80
  - name: logger
    image: busybox
    command: ['sh', '-c', 'while true; do echo "$(date) log entry"; sleep 10; done']
```

**The fix from Day 2**: both containers are in `spec.containers`. `spec.initContainers` is only for containers that run once before the main containers start — a sidecar runs alongside indefinitely.

---

## Block 3 — Troubleshooting Fixes

### Scenario 1: ImagePullBackOff

The image `nginx:999-doesnotexist` doesn't exist on Docker Hub. `kubectl describe pod broken-image` shows a `Failed to pull image` event.

Fix — delete and recreate with a valid image:
```bash
kubectl delete pod broken-image
kubectl run broken-image --image=nginx:1.21
```

Or edit the YAML and re-apply.

---

### Scenario 2: Service with no endpoints

The pod has label `app=backend`. The service selector is `app=frontend`. They don't match, so the service has no endpoints.

Diagnose:
```bash
kubectl get endpoints mismatch-svc   # <none>
kubectl describe svc mismatch-svc    # Selector: app=frontend
kubectl get pod label-mismatch --show-labels  # app=backend
```

Fix — patch the service selector to match the pod:
```bash
kubectl patch svc mismatch-svc -p '{"spec":{"selector":{"app":"backend"}}}'
kubectl get endpoints mismatch-svc   # now shows the pod IP
```

This is the single most common service bug on the exam. Always check `kubectl get endpoints` when a service isn't routing.

---

### Scenario 3: Pod stuck in Init:0/1

The init container runs `exit 1` — it always fails. Kubernetes retries it indefinitely, keeping the pod in `Init:0/1`.

Diagnose:
```bash
kubectl get pod stuck-init           # Init:0/1
kubectl logs stuck-init -c setup     # (empty or error)
kubectl describe pod stuck-init      # Events show "Back-off restarting failed container"
```

Fix — delete and recreate with a command that exits cleanly:
```bash
kubectl delete pod stuck-init
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: stuck-init
spec:
  initContainers:
  - name: setup
    image: busybox
    command: ['sh', '-c', 'echo "setup done"']
  containers:
  - name: app
    image: nginx:1.21
```

---

## Block 4 — Milestone Answers

### Task 1: gateway pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gateway
  labels:
    app: gateway
    env: prod
spec:
  containers:
  - name: gateway
    image: nginx:1.21
    ports:
    - containerPort: 80
```

### Task 2: gateway-svc

```yaml
apiVersion: v1
kind: Service
metadata:
  name: gateway-svc
spec:
  selector:
    app: gateway
  ports:
  - port: 80
    targetPort: 80
```

### Task 3: twin multi-container pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: twin
spec:
  containers:
  - name: primary
    image: nginx:1.21
  - name: monitor
    image: busybox
    command: ['sh', '-c', 'while true; do echo "monitoring"; sleep 10; done']
```

### Task 4: staged init container pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: staged
spec:
  initContainers:
  - name: init
    image: busybox
    command: ['sh', '-c', 'echo "ready"']
  containers:
  - name: app
    image: nginx:1.21
```

### Task 5: ConfigMap + pod + service

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: env-cfg
data:
  ENVIRONMENT: production
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: prod-app
  labels:
    app: prod-app
spec:
  containers:
  - name: app
    image: nginx:1.21
    envFrom:
    - configMapRef:
        name: env-cfg
    ports:
    - containerPort: 80
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: prod-svc
spec:
  selector:
    app: prod-app
  ports:
  - port: 80
    targetPort: 80
```
