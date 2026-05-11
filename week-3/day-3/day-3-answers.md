# Week 3 — Day 3 Answers

---

## Block 1 — Task Interpretation Answers

**Prompt A**:
```bash
helm install my-nginx bitnami/nginx --set replicaCount=3
```

**Prompt B**:
```bash
helm upgrade my-nginx bitnami/nginx --set replicaCount=5
```

**Prompt C**:
```bash
helm list
helm get values my-nginx
```

---

## Block 3 — Helm Reference Commands

```bash
# 1. Add repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# 2. Install with defaults
helm install web bitnami/nginx
kubectl get pods   # verify running

# 3. Check values in use
helm get values web          # only overridden values
helm show values bitnami/nginx   # all chart defaults

# 4. Upgrade with --set
helm upgrade web bitnami/nginx --set replicaCount=2
kubectl get deployment   # verify replicas

# 5. Find the right key and upgrade
helm show values bitnami/nginx | grep -i replica
helm upgrade web bitnami/nginx --set replicaCount=3

# 6. Uninstall
helm uninstall web
kubectl get pods   # should be empty
```

**`helm upgrade --install` vs `helm upgrade`**:
- `helm upgrade` fails if the release doesn't exist yet
- `helm upgrade --install` creates it if missing, upgrades if it exists
- Prefer `helm upgrade --install` — it's idempotent

**`helm get values` vs `helm show values`**:
- `helm get values <release>` — values that were overridden for this specific release
- `helm show values <chart>` — all default values the chart supports

---

## Block 4 — values.yaml approach

```yaml
# values.yaml
replicaCount: 3
```

```bash
helm install prod bitnami/nginx -f values.yaml
# or
helm upgrade --install prod bitnami/nginx -f values.yaml
```

Value override precedence (last wins):
1. Chart defaults (`values.yaml` in the chart)
2. `-f custom-values.yaml`
3. `--set key=value`

So `--set` always wins over a values file.
