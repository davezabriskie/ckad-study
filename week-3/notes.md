# Week 3 Study Notes

## Gaps Carried from Week 2

- **CronJob schedule syntax**: `*/N * * * *` = every N minutes, `N * * * *` = at minute N of every hour
- **Service imperative scaffold**: `kubectl create service clusterip <name> --tcp=<port>:<port> --dry-run=client -o yaml`
- **Probe type discipline**: read the task twice — `readinessProbe` removes from endpoints (no restart), `livenessProbe` restarts the container
- **`Pod.spec.containers` is always plural** — typo `container` (singular) in explain path wastes time

---

## Key Concepts

### ConfigMap — Volume Mount Pattern

```yaml
# In pod/deployment spec:
containers:
  - name: app
    volumeMounts:
      - name: config-vol
        mountPath: /etc/config
volumes:
  - name: config-vol
    configMap:
      name: my-cfg
```

- Each ConfigMap key becomes a file in `mountPath`
- File contents = the key's value
- Useful for config files (nginx.conf, app.properties, etc.)
- Changes to the ConfigMap propagate to the volume automatically (with a delay)

### ConfigMap — All Three Injection Patterns

| Pattern | Field | Use when |
|---|---|---|
| All keys as env vars | `envFrom.configMapRef` | Simple, you control the ConfigMap key names |
| Single key as env var | `env.valueFrom.configMapKeyRef` | Need to rename, or only want one key |
| Mount as files | `volumes.configMap` + `volumeMounts` | App reads config from filesystem |

### Secrets

- Same three injection patterns as ConfigMaps — just swap `configMapRef` → `secretRef`, `configMapKeyRef` → `secretKeyRef`
- Values in YAML must be base64 encoded: `echo -n "value" | base64`
- `kubectl create secret generic` with `--from-literal` handles encoding automatically
- `type: Opaque` is the default generic secret type
- Other types: `kubernetes.io/tls`, `kubernetes.io/dockerconfigjson` — know they exist

### Helm

- Package manager for Kubernetes — installs pre-built application charts
- `helm upgrade --install` is preferred over `helm install` — creates if not exists, upgrades if it does
- Values override order (last wins): chart defaults → `-f values.yaml` → `--set key=value`
- `helm get values <release>` shows only the overridden values, not all defaults

### Kustomize

- Built into `kubectl` — no separate install needed
- `kubectl apply -k ./dir` applies everything in the kustomization
- `kustomization.yaml` is the entry point — must list `resources`
- Overlays patch base resources without modifying them

## kubectl Commands for Week 3

```bash
# ConfigMap
kubectl create configmap my-cfg --from-literal=key=val
kubectl create configmap my-cfg --from-file=config.properties
kubectl create configmap my-cfg --from-env-file=.env

# Secret
kubectl create secret generic my-secret --from-literal=username=admin --from-literal=password=pass
kubectl create secret generic my-secret --from-file=tls.crt
echo -n "admin" | base64   # encode a value manually

# Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-release bitnami/nginx
helm upgrade --install my-release bitnami/nginx --set replicaCount=2
helm upgrade --install my-release bitnami/nginx -f values.yaml
helm list
helm get values my-release
helm status my-release
helm uninstall my-release

# Kustomize
kubectl apply -k ./overlays/prod
kubectl diff -k ./overlays/prod   # preview changes before applying
```

---

## Daily Progress Tracking

### Day 1 (Monday May 11)
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:

### Day 2 (Tuesday May 12)
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:

### Day 3 (Wednesday May 13)
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:

### Day 4 (Thursday May 14)
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:

### Day 5 (Friday May 15)
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:

### Day 6 (Saturday May 17) — Milestone
- Milestone Result: PASS / FAIL
- Tasks Completed: ____/6
- Total Time: _____ min
- Areas to improve:
