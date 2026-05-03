# Week 1 — Day 5 Answers

---

## Block 1 — Milestone Assessment Answers

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

### Task 2: gateway-svc service

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
  type: ClusterIP
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

---

## Block 2 — Deep Practice Answers

### Three-container shared volume pipeline

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pipeline
spec:
  volumes:
  - name: shared
    emptyDir: {}
  containers:
  - name: ingest
    image: busybox
    command: ['sh', '-c', 'while true; do echo "data-$(date)" >> /shared/data.txt; sleep 2; done']
    volumeMounts:
    - name: shared
      mountPath: /shared
  - name: transform
    image: busybox
    command: ['sh', '-c', 'while true; do cat /shared/data.txt >> /shared/processed.txt; sleep 3; done']
    volumeMounts:
    - name: shared
      mountPath: /shared
  - name: output
    image: busybox
    command: ['sh', '-c', 'tail -f /shared/processed.txt']
    volumeMounts:
    - name: shared
      mountPath: /shared
```

### Individual ConfigMap key injection (valueFrom)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config
data:
  DB_HOST: localhost
  DB_PORT: "5432"
  DB_NAME: myapp
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: db-app
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'env; sleep 3600']
    env:
    - name: DB_HOST
      valueFrom:
        configMapKeyRef:
          name: db-config
          key: DB_HOST
    - name: DB_PORT
      valueFrom:
        configMapKeyRef:
          name: db-config
          key: DB_PORT
```

Note: `valueFrom.configMapKeyRef` injects a single key. `envFrom.configMapRef` injects all keys. Know both.

### Full scenario answer

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-cfg
data:
  THEME: dark
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  initContainers:
  - name: init
    image: busybox
    command: ['sh', '-c', 'echo "config loaded"']
  containers:
  - name: app
    image: nginx:1.21
    envFrom:
    - configMapRef:
        name: frontend-cfg
    ports:
    - containerPort: 80
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
```
