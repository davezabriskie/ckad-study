# Week 3 — Day 2 Answers

---

## Block 1 — Task Interpretation Answers

**Prompt A** — fields:
- `kubectl create secret generic my-secret --from-literal=username=admin --from-literal=password=s3cr3t`
- `envFrom: [{secretRef: {name: my-secret}}]`

**Prompt B** — fields:
- `volumes: [{name: tls-vol, secret: {secretName: tls-secret}}]`
- `volumeMounts: [{name: tls-vol, mountPath: /etc/tls}]`

**Prompt C** — fields:
- `envFrom: [{configMapRef: {name: my-cfg}}]`
- `env: [{name: MY_KEY, valueFrom: {secretKeyRef: {name: my-secret, key: MY_KEY}}}]`

---

## Block 3 — Secret Reference YAML

### Secret YAML form (base64 encoded)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=        # echo -n "admin" | base64
  password: cG9zdGdyZXMxMjM=  # echo -n "postgres123" | base64
```

> Use `kubectl create secret generic` imperatively to avoid manual base64 encoding.

### Rep 1: envFrom (all keys)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-client
  labels:
    app: db-client
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db-client
  template:
    metadata:
      labels:
        app: db-client
    spec:
      containers:
        - name: client
          image: nginx:1.21
          envFrom:
            - secretRef:
                name: db-secret
```

### Rep 2: valueFrom single key (with rename)
```yaml
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: password
```

### Rep 3: volume mount
```yaml
spec:
  containers:
    - name: client
      image: nginx:1.21
      volumeMounts:
        - name: db-creds
          mountPath: /etc/db-creds
  volumes:
    - name: db-creds
      secret:
        secretName: db-secret   # note: secretName, not name
```

**Key difference from ConfigMap volume**: field is `secret.secretName` not `configMap.name`.

---

## Block 4 — Full Stack Reference

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-cfg
data:
  ENV: prod
  LOG_LEVEL: info
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
stringData:
  API_KEY: abc123   # stringData accepts plain text — kubectl encodes it
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
          env:
            - name: APP_API_KEY
              valueFrom:
                secretKeyRef:
                  name: app-secret
                  key: API_KEY
          readinessProbe:
            httpGet:
              path: /
              port: 80
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

**`stringData` vs `data`**: `stringData` accepts plain text values — kubectl base64-encodes them on apply. Easier than manual encoding. Read back always shows `data` (encoded).
