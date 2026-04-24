# Week 1 — Day 2 Answers

Only open this to check your work after attempting each block.

---

## Block 2 — Reference Pods

Study these, then close the file and write them from memory.

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

### Init Container Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  initContainers:
  - name: init-setup
    image: busybox
    command: ['sh', '-c', 'echo initialized > /work/status']
    volumeMounts:
    - name: shared-data
      mountPath: /work
  containers:
  - name: main-app
    image: nginx:1.21
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  volumes:
  - name: shared-data
    emptyDir: {}
```

**Watch out for**: `spec.initContainers` (not `spec.containers`) for the init container. The `volumes` entry lives at the pod level (`spec.volumes`), not inside any container — both containers reference it by name via `volumeMounts`.

---

## Block 3 — Field Mapping Answers

**Prompt A**: "Create a pod named `web-logger` with a main container `web` running `nginx:1.21` on port 80 and a sidecar `logger` running `busybox` that continuously prints a log line every 5 seconds"
- `metadata.name` → web-logger
- `spec.containers[0].name` → web
- `spec.containers[0].image` → nginx:1.21
- `spec.containers[0].ports[0].containerPort` → 80
- `spec.containers[1].name` → logger
- `spec.containers[1].image` → busybox
- `spec.containers[1].command` → needed (`sh -c 'while true; do echo ...; sleep 5; done'`)

**Prompt B**: "Create a pod named `data-processor` where two containers share a volume: `writer` writes to `/data/out`, `reader` reads from `/data/out`. Use emptyDir mounted at `/data` for both."
- `metadata.name` → data-processor
- `spec.containers[0].name` → writer
- `spec.containers[0].volumeMounts[0].mountPath` → /data
- `spec.containers[1].name` → reader
- `spec.containers[1].volumeMounts[0].mountPath` → /data
- `spec.volumes[0].name` → (any name, referenced by both mounts)
- `spec.volumes[0].emptyDir` → {}

**Prompt C**: "Create a pod with an init container that writes `ready` to `/work/status`, then a main nginx container mounts the same volume"
- `spec.initContainers[0].name` → init (or anything)
- `spec.initContainers[0].image` → busybox
- `spec.initContainers[0].command` → needed (`sh -c 'echo ready > /work/status'`)
- `spec.initContainers[0].volumeMounts[0].mountPath` → /work
- `spec.containers[0].name` → main (or anything)
- `spec.containers[0].image` → nginx:1.21
- `spec.containers[0].volumeMounts[0].mountPath` → /usr/share/nginx/html
- `spec.volumes[0]` → emptyDir volume shared between both

---

## Block 4 — Task Answers

### Quick Task: Pod with resource limits

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
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

### Complex Task: ConfigMap + Pod with env injection

**ConfigMap:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: production
  LOG_LEVEL: info
```

**Pod (injecting individual keys):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configured-app
spec:
  containers:
  - name: app
    image: nginx:1.21
    env:
    - name: APP_ENV
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_ENV
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: LOG_LEVEL
```

**Alternate: inject all keys at once with `envFrom`:**

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

Know both forms — the exam may specify individual key injection or bulk injection.
