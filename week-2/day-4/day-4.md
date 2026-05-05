# Week 2 — Day 4 (Tuesday May 5)

**Total time**: 75 min | Blue/Green + Canary + ConfigMaps intro

> Jobs + CronJobs were covered in Day 3. This day covers the two deployment patterns from the CKAD plan (blue/green, canary) and introduces ConfigMaps, which are required for the Day 5 tasks and the Week 2 milestone.

---

## Block 0 — Scaffold + Refine Sprint (15 min)

Mandatory Week 2+. Generate scaffold, then add non-default fields before applying.

**Rep 1**: Deployment `api`, image `nginx:1.21`, 2 replicas.
Add: `resources.requests` + `resources.limits`, `readinessProbe` (httpGet, path `/`, port 80).

```bash
kubectl create deployment api --image=nginx:1.21 --replicas=2 --dry-run=client -o yaml > yaml-practice/sprint-1.yaml
```

**Rep 2**: Job `batch`, image `busybox`, command `echo done`.
Add: `completions: 3`, `parallelism: 1`, `restartPolicy: Never`.

```bash
kubectl create job batch --image=busybox --dry-run=client -o yaml -- sh -c 'echo done' > yaml-practice/sprint-2.yaml
```

Target: both files applied cleanly with no kubectl errors.

---

## Block 1 — Blue/Green Deployment (20 min)

The pattern: two Deployments run simultaneously; a single Service controls which version receives traffic by switching its selector.

**Step 1**: Create both versions
```bash
kubectl create deployment web-v1 --image=nginx:1.21 --replicas=3 --dry-run=client -o yaml > yaml-practice/web-v1.yaml
```

Edit `web-v1.yaml` before applying — both Deployments share `app: web`, differentiated only by `version`:
```yaml
selector:
  matchLabels:
    app: web
    version: v1
template:
  metadata:
    labels:
      app: web
      version: v1
```

Repeat for `web-v2` with `nginx:1.22` and `version: v2`. Save to `yaml-practice/web-v2.yaml`.

Apply both:
```bash
kubectl apply -f yaml-practice/web-v1.yaml
kubectl apply -f yaml-practice/web-v2.yaml
```

**Step 2**: Create a Service that targets v1
```bash
kubectl create service clusterip web-svc --tcp=80:80 --dry-run=client -o yaml > yaml-practice/web-svc.yaml
```

Edit selector to match v1 — use both labels, not just `version`, to avoid accidentally matching unrelated pods:
```yaml
selector:
  app: web
  version: v1
```

Apply and verify endpoints point to v1 pods:
```bash
kubectl apply -f yaml-practice/web-svc.yaml
kubectl get endpoints web-svc
```

**Step 3**: Switch traffic to v2 imperatively
```bash
kubectl patch service web-svc -p '{"spec":{"selector":{"version":"v2"}}}'
kubectl get endpoints web-svc   # should now show v2 pod IPs
```

**Key concept**: The Service selector is the only lever. Both Deployments run the whole time — you're just redirecting the Service.

Check against `day-4-answers.md` → Block 1.

---

## Block 2 — Canary Deployment (15 min)

The pattern: stable and canary Deployments share a common label. The Service selects on that shared label, routing traffic proportionally by replica count.

**Setup**: Reset to just `web-v1` running (3 replicas, label `app=web`). Update the Service selector to just `app=web`.

**Step 1**: Create the canary Deployment
```bash
kubectl create deployment web-canary --image=nginx:1.22 --replicas=1 --dry-run=client -o yaml > yaml-practice/web-canary.yaml
```

Edit labels — canary pods must share `app=web` with v1 so the Service picks them up:
```yaml
selector:
  matchLabels:
    app: web
template:
  metadata:
    labels:
      app: web
```

Apply. Now Service sees 4 pods total: 3 v1 + 1 canary = ~75/25 split.

**Step 2**: Adjust the ratio
```bash
kubectl scale deployment web-canary --replicas=2   # now ~60/40
kubectl scale deployment web-v1 --replicas=2        # now ~50/50
```

**Step 3**: Promote canary (once validated)
```bash
kubectl scale deployment web-v1 --replicas=0   # drain stable
kubectl scale deployment web-canary --replicas=3
```

**Key concept**: No special Kubernetes feature. Just shared labels + replica ratio. The exam may ask you to implement this from scratch.

Check against `day-4-answers.md` → Block 2.

---

## Block 3 — Udemy: ConfigMaps (10 min)

Watch the **ConfigMaps** section. Focus on:
- What a ConfigMap is — key/value store decoupled from the pod
- `kubectl create configmap` imperative form
- Two injection patterns:
  - `envFrom` + `configMapRef` — inject all keys as env vars
  - `env` + `valueFrom.configMapKeyRef` — inject a single key
- Volume mount pattern (know it exists, don't memorize today)

---

## Block 4 — ConfigMap YAML + Injection (15 min)

**Study the reference** in `day-4-answers.md` → Block 4 first. Close it. Then write from memory.

**Rep 1**: Create ConfigMap `app-cfg` with `ENV=prod` and `LOG_LEVEL=warn`.

Imperative:
```bash
kubectl create configmap app-cfg --from-literal=ENV=prod --from-literal=LOG_LEVEL=warn
```

Also write as YAML. Save to `yaml-practice/configmap-1.yaml`.

**Rep 2**: Deployment `app`, 2 replicas, `nginx:1.21`, label `app=app`. Inject all keys from `app-cfg` via `envFrom`.

Save to `yaml-practice/deploy-envfrom.yaml`.

**Rep 3**: Same Deployment, inject only `LOG_LEVEL` via `valueFrom.configMapKeyRef`.

Save to `yaml-practice/deploy-valuefrom.yaml`.

Verify:
```bash
kubectl exec deploy/app -- env | grep -E 'ENV|LOG_LEVEL'
```

---

## Block 5 — kubectl explain (5 min)

No looking up syntax first — use explain as the lookup.

```bash
kubectl explain deployment.spec.template.spec.containers.envFrom
kubectl explain deployment.spec.template.spec.containers.env
kubectl explain service.spec.selector
```

---

## End-of-Session Checklist

Fill in `week-2/notes.md` Day 4 tracking:
- [ ] Blue/green: Service selector switch works, endpoints confirmed?
- [ ] Canary: shared label understood, replica ratio adjusted?
- [ ] ConfigMap: both imperative and YAML form from memory?
- [ ] `envFrom` injection clean?
- [ ] `valueFrom.configMapKeyRef` single-key injection clean?
- [ ] Areas to improve?