# Week 3 — Day 5 Answers

---

## Block 1 — Task Interpretation Answers

**Prompt A**:
- `kubectl create secret generic my-secret --from-literal=KEY=val`
- `volumes: [{name: sec-vol, secret: {secretName: my-secret}}]`
- `volumeMounts: [{name: sec-vol, mountPath: /etc/secrets}]`

**Prompt B**:
```bash
helm upgrade --install my-release bitnami/chart -f values.yaml --set replicaCount=2
```

**Prompt C**:
```yaml
namePrefix: test-
images:
  - name: redis
    newTag: "7.2"
```

**Prompt D** — fields:
- `volumes: [{name: cfg-vol, configMap: {name: app-cfg}}]`
- `volumeMounts: [{name: cfg-vol, mountPath: /etc/config}]`
- `env: [{name: MY_KEY, valueFrom: {secretKeyRef: {name: my-secret, key: MY_KEY}}}]`

---

## Block 2 — Full Stack Reference

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-cfg
data:
  ENV: prod
  LOG_LEVEL: warn
  MAX_CONN: "50"
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
stringData:
  DB_PASSWORD: hunter2
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
          env:
            - name: DATABASE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: app-secret
                  key: DB_PASSWORD
          readinessProbe:
            httpGet:
              path: /
              port: 80
          volumeMounts:
            - name: config-vol
              mountPath: /etc/config
      volumes:
        - name: config-vol
          configMap:
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
