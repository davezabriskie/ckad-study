# Week 4 — Day 5 Answers (self-grade for cold reps)

> Closed reference. Block A reuses `day-4/day-4-answers.md` → Block 5. Blocks B and C self-grade here. Open only after attempting cold.

---

## Block B — Cold Networking Reps

### Rep 1 — Ingress, cold

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ing
spec:
  rules:
    - host: shop.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-svc
                port:
                  number: 80
```

Cold-recall trip points:
- `apiVersion: networking.k8s.io/v1` (not `extensions/v1beta1` — long retired).
- `pathType` is **required** in v1 and sits as a sibling of `path` (values `Prefix` / `Exact` / `ImplementationSpecific`).
- Backend is `backend.service.name` + `backend.service.port.number` — the port is **nested under `port.number`**, not a bare `port:`. This is the #1 cold slip.
- `rules` → each rule has `host` + `http.paths[]`. TLS (not needed here) would be a sibling `tls:` block with `hosts: []` + `secretName`.

Scaffold to check yourself *after* the cold attempt:
```bash
kubectl create ingress web-ing --rule="shop.local/*=web-svc:80" --dry-run=client -o yaml
```

### Rep 2 — NetworkPolicy, cold (ingress rule)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-from-client
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: client
```

Cold-recall trip points:
- `podSelector` (top-level) = which pods this policy applies to. `ingress.from[].podSelector` = the allowed source. Two different selectors, easy to conflate.
- `from:` is a **list of peers**; each peer is a `-` item that can hold `podSelector` / `namespaceSelector` / `ipBlock`. Multiple peers = OR.
- `policyTypes: [Ingress]` is `[]string` — and required for correct behavior even though it can be inferred.

> **Probe reinforcement (optional)** — `exec` liveness shape, only if Day 2's felt shaky:
> ```yaml
> livenessProbe:
>   exec:
>     command: ["cat", "/tmp/healthy"]   # array, not string. exit 0 = healthy
>   initialDelaySeconds: 5
>   periodSeconds: 5
> ```
> Probe-type cheat: `httpGet` (path+port, 2xx/3xx), `tcpSocket` (port opens), `exec` (command exits 0). Metric already met — this is shape-reinforcement only.

---

## Block C — Forced Reps

### Rep 1 — Kustomize (the immutable-selector fix)

`base/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:1.21
```

`base/service.yaml`:

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
```

`base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
```

`overlay-dev/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../base
labels:
  - pairs:
      env: dev
    includeSelectors: false      # keep OUT of selectors (immutable-selector fix)
    includeTemplates: true       # DO add to pod template labels
```

**Why these two flags are the whole game:** the older `commonLabels:` field (and `labels` with `includeSelectors: true`) injects the label into `spec.selector.matchLabels` AND the Service `selector`. Those are **immutable** after first apply, so the second `apply -k` errors with `field is immutable`. The fix is the flag pair:
- `includeSelectors: false` — keeps `env: dev` out of both selectors → re-apply is clean.
- `includeTemplates: true` — still stamps `env: dev` onto the pod template labels (what you usually want; otherwise the label only lands on top-level `metadata.labels` and never reaches the running pods).

Both default to `false` on the `labels:` transformer, so omitting `includeTemplates` silently drops the label from the pods. This is your `notes.md` pattern #3 ("CKAD-pragmatic default").

> If your kustomize version only has `commonLabels:`, the equivalent escape is to put `env: dev` as a plain `commonAnnotations:` or add it via a patch to metadata only — anything that keeps it out of the selector. The render check `kubectl kustomize overlay-dev/` shows you exactly where the label landed before you apply.

Verify two cycles:
```bash
kubectl kustomize overlay-dev/          # render, confirm env: dev NOT in selector
kubectl apply -k overlay-dev/
kubectl apply -k overlay-dev/           # second apply — must be clean, no immutable error
```

### Rep 2 — Literal names

1. `inventory-db-service`
2. `inventory-db-config`
3. `inventory-api-backend` (NOT `inventory-backend-api`)
4. `allow-api-to-db` (NOT `allow-db-to-api` — direction matters)
5. `inventory-db-creds`

Grade: exact string match, every hyphen and word in order. Any deviation = a milestone-grader miss.
