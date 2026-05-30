# Week 4 — Day 4 Answers

> Reference. Block 2 (workflow) and Block 4 (cross-domain stack) are reference-open by design — keep this open while you build. **Block 3 is the exception: do NOT read its fault list until you've found and fixed both faults yourself.**

---

## Block 2 — Healthy Stack Scaffold

### Deployment `web`

```bash
kubectl create deployment web --image=nginx:1.21 --replicas=2 --dry-run=client -o yaml > yaml-practice/web-deploy.yaml
```

> `kubectl create deployment` is the imperative generator — fine for scaffolding the YAML. The success metric is no `apply` being replaced by `create -f`/`create -k`; the generator (`create deployment NAME`) is a different thing and is allowed. You still `kubectl apply -f` the result.

The generator labels pods `app: web` automatically (matches the selector). Final shape (artifacts stripped):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  labels:
    app: web
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

### Service `web-svc`

```bash
kubectl expose deployment web --name=web-svc --port=80 --target-port=80 --dry-run=client -o yaml > yaml-practice/web-svc.yaml
```

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

### Client pod

```bash
kubectl run client --image=busybox --labels=app=client --dry-run=client -o yaml -- sleep 3600 > yaml-practice/client.yaml
kubectl apply -f yaml-practice/web-deploy.yaml -f yaml-practice/web-svc.yaml -f yaml-practice/client.yaml
```

busybox ships `wget`, not `curl`. Test form: `kubectl exec client -- wget -qO- --timeout=2 web-svc`.

---

## Block 3 — Break/Fix Setup (apply blind) + Fault List (grade after)

### The setup manifest

Write this to `yaml-practice/broken-stack.yaml` and `kubectl apply -f` it **without studying it**. (Yes, it's in front of you here — the discipline is to copy it in, apply, and debug from cluster state, not from re-reading the YAML.)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop-api
  labels:
    app: shop-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: shop-api
  template:
    metadata:
      labels:
        app: shop-api          # <-- fault A lives in the interaction with the Service
    spec:
      containers:
        - name: nginx
          image: nginx:1.21
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: shop-api
spec:
  selector:
    app: shop-backend          # FAULT A: selector doesn't match pod label (app: shop-api)
  ports:
    - port: 80
      targetPort: 8080         # FAULT B: nginx listens on 80, not 8080
```

### Fault list — READ ONLY AFTER YOU'VE FIXED BOTH

- **Fault A — selector mismatch.** Service `selector: app=shop-backend`, but the Deployment's pods are labeled `app=shop-api`. Result: `kubectl get endpoints shop-api` → `<none>`. Isolated by **step 1 (empty endpoints)** → **step 2/3 (describe svc Selector vs `get pods --show-labels`)**. Fix: edit the Service selector to `app: shop-api`.
- **Fault B — wrong targetPort.** After fixing A, endpoints populate but `exec wget` still hangs/refuses: the Service forwards to `targetPort: 8080`, but nginx listens on `80`. Isolated by **step 5 (exec fails despite populated endpoints)**. Fix: edit `targetPort` to `80`.

Fix commands:

```bash
kubectl edit svc shop-api          # change selector app -> shop-api, targetPort 8080 -> 80
# or targeted patch:
kubectl patch svc shop-api -p '{"spec":{"selector":{"app":"shop-api"},"ports":[{"port":80,"targetPort":80}]}}'
```

Confirm fixed:

```bash
kubectl get endpoints shop-api                      # now lists 2 IPs
kubectl exec client -- wget -qO- --timeout=2 shop-api   # nginx welcome page
```

> Teaching point: the two faults sit on **different steps of the workflow**. A is a *selection* fault (endpoints empty). B is a *port* fault (endpoints present, connection fails). If you'd guessed instead of walking the steps, you'd likely have fixed A, seen endpoints appear, declared victory, and missed B. The workflow's value is that it doesn't let you stop early.

Cleanup: `kubectl delete -f yaml-practice/broken-stack.yaml`

---

## Block 4 — Cross-Domain Stack

```bash
kubectl create namespace shop
```

### ConfigMap `shop-config`

```bash
kubectl -n shop create configmap shop-config --from-literal=APP_COLOR=blue --from-literal=APP_MODE=prod --dry-run=client -o yaml > yaml-practice/shop-config.yaml
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: shop-config
  namespace: shop
data:
  APP_COLOR: blue
  APP_MODE: prod
```

### Deployment `shop-backend` (with `envFrom`)

```bash
kubectl -n shop create deployment shop-backend --image=nginx:1.21 --replicas=2 --dry-run=client -o yaml > yaml-practice/shop-backend.yaml
```

Add the `tier: backend` pod label (the generator only sets `app: shop-backend`) and the `envFrom`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop-backend
  namespace: shop
  labels:
    app: shop-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: shop-backend
  template:
    metadata:
      labels:
        app: shop-backend
        tier: backend            # second label — NP selects on this
    spec:
      containers:
        - name: nginx
          image: nginx:1.21
          envFrom:
            - configMapRef:
                name: shop-config
```

> `envFrom` + `configMapRef` injects **all** keys as env vars (key name = var name). The alternative — `env: [{name: APP_MODE, valueFrom: {configMapKeyRef: {name: shop-config, key: APP_MODE}}}]` — injects **one** key and lets you rename it. `envFrom` for "all keys," `valueFrom.configMapKeyRef` for "one key, maybe renamed." (That's Block 5 Prompt E.)

### Service `shop-backend-svc`

```bash
kubectl -n shop expose deployment shop-backend --name=shop-backend-svc --port=80 --target-port=80 --dry-run=client -o yaml > yaml-practice/shop-backend-svc.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: shop-backend-svc
  namespace: shop
spec:
  selector:
    app: shop-backend
  ports:
    - port: 80
      targetPort: 80
```

### NetworkPolicy `allow-frontend-or-worker-to-backend` (matchExpressions)

No imperative scaffold — hand-write:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-or-worker-to-backend
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchExpressions:
              - key: role
                operator: In
                values:
                  - frontend
                  - worker
```

> Name check: `allow-` not `all-`. `matchExpressions` not `matchLabels` (set-based OR over `role`).

Apply all four:

```bash
kubectl apply -f yaml-practice/shop-config.yaml \
  -f yaml-practice/shop-backend.yaml \
  -f yaml-practice/shop-backend-svc.yaml \
  -f yaml-practice/shop-np.yaml
```

---

## Block 5 — Interpretation Drill Answers

**Prompt A** (endpoints `<none>` despite running pods):
1. **Selector mismatch** — Service selector doesn't match pod labels.
2. **Pods not Ready** — failing readiness probe drops them from endpoints.
Distinguish: `kubectl get pods -l <selector> --show-labels`. If pods don't appear → label/selector mismatch (cause 1). If they appear but `READY 0/1` → probe failure (cause 2). `describe svc` shows the Selector to compare against.

**Prompt B** ("bad address" from `wget`):
**No — it's DNS, not a NetworkPolicy block.** "bad address" = name resolution failed (the Service doesn't exist, wrong name, or wrong namespace in the FQDN). A NetworkPolicy block produces a **timeout** (connection hangs), because the name resolves but packets are dropped. Day 3 lesson.

**Prompt C** (`role=frontend` OR `role=worker`):
**matchExpressions** — `{key: role, operator: In, values: [frontend, worker]}`. `matchLabels` can't express OR across values of a single key; it's pure AND-equality.

**Prompt D** (endpoints populated, DNS resolves, but `wget` hangs to timeout):
1. **Wrong `targetPort`** — Service forwards to a port the container isn't listening on.
2. **NetworkPolicy gating the path** — a default-deny or restrictive policy is dropping the packets (timeout signature, per Prompt B). (On kindnet, NP won't actually enforce — but on the exam cluster it will.)

**Prompt E** (`APP_MODE` from a ConfigMap as env var — two shapes):
1. **`envFrom: [{configMapRef: {name: ...}}]`** — pulls *every* key in the ConfigMap as an env var, var name = key name. Pick when you want all keys and the names already suit you.
2. **`env: [{name: APP_MODE, valueFrom: {configMapKeyRef: {name: ..., key: APP_MODE}}}]`** — pulls *one* specific key, and lets you rename the env var. Pick when you want a subset or a different var name than the key.