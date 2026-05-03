# Week 1 — Day 4 Answers

---

## Block 2 — YAML Marathon Reference

### 1. Basic pod with labels

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  labels:
    app: my-app
    env: dev
spec:
  containers:
  - name: app
    image: nginx:1.21
    ports:
    - containerPort: 80
```

### 2. Pod with resource limits

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: limited-pod
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

### 3. Multi-container sidecar (no shared volume)

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

### 4. Multi-container with shared emptyDir volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-vol-pod
spec:
  volumes:
  - name: data
    emptyDir: {}
  containers:
  - name: writer
    image: busybox
    command: ['sh', '-c', 'while true; do date >> /data/log.txt; sleep 5; done']
    volumeMounts:
    - name: data
      mountPath: /data
  - name: reader
    image: busybox
    command: ['sh', '-c', 'tail -f /data/log.txt']
    volumeMounts:
    - name: data
      mountPath: /data
```

### 5. Init container + main container

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

---

## Block 3 — Milestone Dry Run Answers

### Task 1: api pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: api
  labels:
    app: api
    tier: backend
spec:
  containers:
  - name: api
    image: nginx:1.21
    ports:
    - containerPort: 80
```

### Task 2: api-svc service

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
  type: ClusterIP
```

### Task 3: processor shared volume pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: processor
spec:
  volumes:
  - name: data
    emptyDir: {}
  containers:
  - name: producer
    image: busybox
    command: ['sh', '-c', 'while true; do date >> /data/out.txt; sleep 3; done']
    volumeMounts:
    - name: data
      mountPath: /data
  - name: consumer
    image: busybox
    command: ['sh', '-c', 'tail -f /data/out.txt']
    volumeMounts:
    - name: data
      mountPath: /data
```

### Task 4: init-web pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-web
spec:
  initContainers:
  - name: wait
    image: busybox
    command: ['sh', '-c', 'sleep 2']
  containers:
  - name: web
    image: nginx:1.21
```

### Task 5: ConfigMap + pod + service

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-cfg
data:
  ENV: staging
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
  labels:
    app: app
spec:
  containers:
  - name: app
    image: nginx:1.21
    envFrom:
    - configMapRef:
        name: app-cfg
    ports:
    - containerPort: 80
```

```yaml
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

## Block 4 — Troubleshooting Scenarios

### Scenario 1: ImagePullBackOff

Apply this broken manifest:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: broken-image
spec:
  containers:
  - name: app
    image: nginx:999-doesnotexist
```

Diagnose: `kubectl describe pod broken-image` → look at Events section

Fix: Edit the image to `nginx:1.21`
```bash
kubectl delete pod broken-image
# fix the yaml and re-apply, or:
kubectl run broken-image --image=nginx:1.21
```

---

### Scenario 2: Service with no endpoints (label mismatch)

Apply both of these:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: label-mismatch
  labels:
    app: backend
spec:
  containers:
  - name: app
    image: nginx:1.21
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mismatch-svc
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
```

Diagnose:
```bash
kubectl get endpoints mismatch-svc   # shows <none>
kubectl describe svc mismatch-svc    # selector shows app=frontend
kubectl get pod label-mismatch --show-labels  # shows app=backend
```

Fix: Change service selector to `app: backend` (or patch the pod label — service selector is easier)
```bash
kubectl patch svc mismatch-svc -p '{"spec":{"selector":{"app":"backend"}}}'
kubectl get endpoints mismatch-svc   # should now show the pod IP
```

---

### Scenario 3: Pod stuck in Init:0/1

Apply this broken manifest:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: stuck-init
spec:
  initContainers:
  - name: setup
    image: busybox
    command: ['sh', '-c', 'exit 1']
  containers:
  - name: app
    image: nginx:1.21
```

Diagnose:
```bash
kubectl get pod stuck-init          # shows Init:0/1
kubectl logs stuck-init -c setup    # shows the init container failed
kubectl describe pod stuck-init     # shows exit code 1 in Events
```

Fix: The init container exits with error. Delete and recreate with a valid command:
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
