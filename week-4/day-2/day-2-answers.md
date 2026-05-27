# Week 4 — Day 2 Answers

> Reference. Open only after attempting from memory.

---

## Block 0 — Scaffold + Refine Sprint

### Rep 1 — Pod `db` with `exec` readinessProbe

```bash
kubectl run db --image=redis:7 --labels=app=db --dry-run=client -o yaml > yaml-practice/sprint-1.yaml
```

Strip dry-run artifacts, then add to the container spec:

```yaml
    readinessProbe:
      exec:
        command:
          - redis-cli
          - ping
      initialDelaySeconds: 5
      periodSeconds: 10
```

Final shape:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: db
  labels:
    app: db
spec:
  containers:
    - name: db
      image: redis:7
      readinessProbe:
        exec:
          command: ["redis-cli", "ping"]
        initialDelaySeconds: 5
        periodSeconds: 10
```

`exec` probe succeeds when the command exits 0. `redis-cli ping` returns `PONG` and exit 0 when redis is ready.

### Rep 2 — Deployment `api` with httpGet probe

```bash
kubectl create deployment api --image=nginx:1.21 --replicas=2 --dry-run=client -o yaml > yaml-practice/sprint-2.yaml
```

Strip `strategy: {}` and `status: {}`. Add to the container:

```yaml
    readinessProbe:
      httpGet:
        path: /
        port: 80
```

### Rep 3 — ClusterIP Service `api-svc`

```bash
kubectl create service clusterip api-svc --tcp=80:80 --dry-run=client -o yaml > yaml-practice/sprint-3.yaml
```

Fix selector to `app: api`. Strip unused port `name: 80-80` and `status: loadBalancer: {}`.

---

## Block 1 — Task Interpretation Drills

**Prompt A** ("Route `shop.example.com/` to Service `web` port 80"):
→ `spec.rules[0].host: shop.example.com`
→ `spec.rules[0].http.paths[0].path: /`
→ `spec.rules[0].http.paths[0].pathType: Prefix`
→ `spec.rules[0].http.paths[0].backend.service.name: web`
→ `spec.rules[0].http.paths[0].backend.service.port.number: 80`

**Prompt B** ("`/api/*` to api, `/*` to web — `/api` first"):
→ Two entries in `spec.rules[0].http.paths`. List `/api` BEFORE `/`. Most Ingress controllers match by longest prefix, but explicit ordering is the safer signal.

**Prompt C** ("TLS termination using Secret `shop-tls`"):
→ `spec.tls[0].hosts: [shop.example.com]`
→ `spec.tls[0].secretName: shop-tls`
→ Secret must be type `kubernetes.io/tls` with keys `tls.crt` and `tls.key`.

**Prompt D** ("Unmatched traffic to Service `fallback` port 8080"):
→ `spec.defaultBackend.service.name: fallback`
→ `spec.defaultBackend.service.port.number: 8080`
→ Lives at `spec.defaultBackend`, NOT inside any `rules[]` entry.

---

## Block 3 — Ingress Cold Reps

### Rep 1 — Path-based, single host, single backend

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ing
spec:
  rules:
    - host: shop.example.com
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

Common slips:
- `apiVersion: networking.k8s.io/v1` — not `extensions/v1beta1` (deprecated and removed). Memorize the FULL version string.
- `pathType` is **required** in `networking.k8s.io/v1`. Values: `Prefix`, `Exact`, `ImplementationSpecific`.
- `backend.service.port.number` is nested THREE levels — `backend` → `service` → `port` → `number`. Easy to flatten incorrectly.

### Rep 2 — Multi-path, single host, two backends

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-ing
spec:
  rules:
    - host: shop.example.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-svc
                port:
                  number: 80
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-svc
                port:
                  number: 80
```

`/api` listed first. Longest-prefix-wins is the convention but explicit ordering keeps the intent visible.

### Rep 3 — TLS termination, multi-doc with Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: shop-tls
type: kubernetes.io/tls
data:
  tls.crt: ZHVtbXktY2VydA==
  tls.key: ZHVtbXkta2V5
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ing
spec:
  tls:
    - hosts:
        - shop.example.com
      secretName: shop-tls
  rules:
    - host: shop.example.com
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

The dummy cert/key in `data:` are base64 of "dummy-cert" and "dummy-key" — won't actually serve TLS but parses as a valid `kubernetes.io/tls` Secret. The Ingress applies clean.

Slips to watch:
- TLS Secret type must be **exactly** `kubernetes.io/tls`. Not `Opaque`.
- `tls[0].hosts` is an array of strings; `tls[0].secretName` is a single string. Don't swap shapes.
- `tls:` lives at `spec.tls`, parallel to `spec.rules`. Not nested inside a rule.
- If `kubectl apply -f` errors with a line number, REMEMBER: multi-doc files reset line counts at `---`. "Line 5 mapping values not allowed" might be line 5 of the Ingress doc (file line ~13), not file line 5.

---

## Block 4 — Mixed Tasks

### Quick — pure recall

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: quick-ing
spec:
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /v1
            pathType: Prefix
            backend:
              service:
                name: api-v1
                port:
                  number: 8080
```

### Medium — full chain

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop
  labels:
    app: shop
spec:
  replicas: 2
  selector:
    matchLabels:
      app: shop
  template:
    metadata:
      labels:
        app: shop
    spec:
      containers:
        - name: nginx
          image: nginx:1.21
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
          readinessProbe:
            httpGet:
              path: /
              port: 80
---
apiVersion: v1
kind: Service
metadata:
  name: shop-svc
spec:
  type: ClusterIP
  selector:
    app: shop
  ports:
    - port: 80
      targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: shop-ing
spec:
  rules:
    - host: shop.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: shop-svc
                port:
                  number: 80
```

Apply. Verify:

```bash
kubectl get all -l app=shop
kubectl get endpoints shop-svc       # 2 IPs after probes pass
kubectl describe ingress shop-ing    # check Backends section
```

`describe ingress` Backends column will show the Service name and resolved endpoints. On a local cluster without an Ingress controller, the Address field stays empty — Ingress resource exists, no real traffic.

---

## Block 5 — kubectl explain notes

- `ingress.spec.rules[].http.paths[].pathType` — required field. Values: `Prefix`, `Exact`, `ImplementationSpecific`.
- `ingress.spec.tls[].secretName` references a Secret of type `kubernetes.io/tls` in the same namespace.
- `ingress.spec.defaultBackend.service.{name,port}` — same shape as a rule backend, but lives at spec level, not inside rules.
- `ingress.spec.ingressClassName` (string) — names which IngressClass / controller handles this Ingress. On EKS this is typically `alb`. On exam usually not required unless prompt specifies it.
