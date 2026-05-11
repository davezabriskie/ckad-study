# Week 3 — Day 1 Answers

---

## Block 1 — Task Interpretation Answers

**Prompt A** — fields:
- `kubectl create configmap my-cfg --from-file=app.properties`
- `volumes: [{name: cfg-vol, configMap: {name: my-cfg}}]`
- `volumeMounts: [{name: cfg-vol, mountPath: /etc/app}]`

**Prompt B** — fields:
- `env: [{name: DATABASE_PASSWORD, valueFrom: {secretKeyRef: {name: my-secret, key: DB_PASS}}}]`

**Prompt C** — fields:
- `kubectl create configmap my-cfg --from-literal=ENV=staging`
- `envFrom: [{configMapRef: {name: my-cfg}}]`

---

## Block 3 — ConfigMap Volume Mount Reference

### Rep 1: nginx-cfg ConfigMap + Deployment

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-cfg
data:
  default.conf: |
    server {
      listen 80;
      location / {
        return 200 'ok';
      }
    }
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
  labels:
    app: web-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-server
  template:
    metadata:
      labels:
        app: web-server
    spec:
      containers:
        - name: nginx
          image: nginx:1.21
          ports:
            - containerPort: 80
          volumeMounts:
            - name: nginx-config
              mountPath: /etc/nginx/conf.d
      volumes:
        - name: nginx-config
          configMap:
            name: nginx-cfg
```

**Note**: Mounting at `/etc/nginx/conf.d` overwrites the default nginx config. The `default.conf` key in the ConfigMap becomes the file `/etc/nginx/conf.d/default.conf` inside the container.

### Rep 2: subPath — mount one key as a single file

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-settings
data:
  app.conf: |
    log_level=warn
    workers=4
  LOG_LEVEL: warn
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  labels:
    app: app
spec:
  replicas: 1
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
                  name: app-settings
                  key: LOG_LEVEL
          volumeMounts:
            - name: settings-vol
              mountPath: /etc/app/app.conf
              subPath: app.conf
      volumes:
        - name: settings-vol
          configMap:
            name: app-settings
```

**Without `subPath`**: mounting at `/etc/app/app.conf` would mount the whole ConfigMap as a directory, hiding anything else under `/etc/app`.

**With `subPath: app.conf`**: only that one key is projected as a single file at the given path. The rest of `/etc/app` is untouched.

**Gotcha**: `subPath` mounts do NOT auto-update when the ConfigMap changes. Regular volume mounts do. If you need live updates, use a regular mount with a subdirectory instead.

**Key facts**:
- `volumes` is at `spec.template.spec` level (pod spec), not container level
- `volumeMounts` is inside the container spec
- Name in `volumeMounts.name` must match name in `volumes.name`
- Each key in the ConfigMap becomes a separate file in `mountPath`
- `--from-file=app.properties` creates a key named `app.properties` (the filename) with the file contents as the value

---

## Block 4 — Mixed Task Answers

### Quick: --from-file ConfigMap

```bash
cat > db.properties << EOF
host=postgres
port=5432
EOF

kubectl create configmap db-config --from-file=db.properties
kubectl describe configmap db-config   # key is "db.properties"
```

### Medium: backend Deployment with volume mount + probe + resources

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: nginx:1.21
          resources:
            requests:
              cpu: 100m
              memory: 64Mi
          readinessProbe:
            httpGet:
              path: /
              port: 80
          volumeMounts:
            - name: db-vol
              mountPath: /etc/db
      volumes:
        - name: db-vol
          configMap:
            name: db-config
```
