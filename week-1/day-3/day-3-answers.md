# Week 1 — Day 3 Answers

---

## Block 2 — Reference YAML

### Multi-container pod with init container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-app
spec:
  initContainers:
  - name: setup
    image: busybox
    command: ['sh', '-c', 'echo "init complete"']
  containers:
  - name: app
    image: nginx:1.21
```

### Service

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
  type: ClusterIP
```

---

## Block 3 — Field Mapping Answers

**Prompt A**: Pod with resource requests/limits
- `metadata.name` → worker
- `spec.containers[0].image` → busybox
- `spec.containers[0].resources.requests.cpu` → 100m
- `spec.containers[0].resources.requests.memory` → 64Mi
- `spec.containers[0].resources.limits.cpu` → 200m
- `spec.containers[0].resources.limits.memory` → 128Mi

**Prompt B**: Shared volume between sidecar containers
- `metadata.name` → log-app
- `spec.volumes[0]` → emptyDir named `shared-data`
- `spec.containers[0]` → main, writes to `/data/out.txt`, mounts shared-data
- `spec.containers[1]` → sidecar, tails `/data/out.txt`, mounts shared-data
- both containers need `volumeMounts` with same volume name

---

## Block 4 — Task Answers

### Quick: Pod with resource limits

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
        cpu: "200m"
        memory: "128Mi"
```

### Quick: Pod with init container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-app
spec:
  initContainers:
  - name: setup
    image: busybox
    command: ['sh', '-c', 'echo "ready" > /tmp/status']
  containers:
  - name: app
    image: nginx:1.21
```

### Medium: Multi-container with shared volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: log-pipe
spec:
  volumes:
  - name: shared-data
    emptyDir: {}
  containers:
  - name: writer
    image: busybox
    command: ['sh', '-c', 'while true; do date >> /data/log.txt; sleep 5; done']
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: reader
    image: busybox
    command: ['sh', '-c', 'tail -f /data/log.txt']
    volumeMounts:
    - name: shared-data
      mountPath: /data
```

### Cross-domain: ConfigMap + Pod + Service

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: site-config
data:
  APP_ENV: production
  LOG_LEVEL: info
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  labels:
    app: web
spec:
  containers:
  - name: app
    image: nginx:1.21
    envFrom:
    - configMapRef:
        name: site-config
    ports:
    - containerPort: 80
```

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
  type: ClusterIP
```
