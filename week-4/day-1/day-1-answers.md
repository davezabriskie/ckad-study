# Week 4 — Day 1 Answers

> Reference. Open only after attempting from memory.

---

## Block 0 — Intervention + Scaffold Sprint

### Step 1 — `kca` / `kck` aliases

Append to `~/.zshrc`:

```bash
# CKAD: prefer apply over create — idempotent reapply, no delete-recreate cycles
alias kca='kubectl apply -f'
alias kck='kubectl apply -k'
```

Reload:

```bash
source ~/.zshrc
```

Sanity check:

```bash
type kca   # → kca is an alias for kubectl apply -f
type kck   # → kck is an alias for kubectl apply -k
```

### Step 2 — Kustomize cold reference

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml          # base: list files
  # - ../../base             # overlay form: list the base directory

namePrefix: prod-

labels:
  - pairs:
      env: prod
    includeSelectors: false  # don't touch immutable selectors
    includeTemplates: true   # do label the pod template

images:
  - name: nginx              # match base image name (no tag)
    newTag: "1.22"
```

Reminders:
- `kubectl explain kustomization` does NOT work — Kustomize is client-side, no API resource. Memorize this shape.
- `kubectl apply -k <DIR>` — directory, not file. `-f` is files, `-k` is directories.
- Modern `labels:` over deprecated `commonLabels:` (avoids the immutable-selector trap).

### Step 3 — Scaffold sprint

**Rep 1 — Pod with tcpSocket probe**:

```bash
kubectl run web --image=nginx:1.21 --dry-run=client -o yaml > yaml-practice/sprint-1.yaml
```

Then add to the container spec:

```yaml
    readinessProbe:
      tcpSocket:
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
```

**Rep 2 — Deployment with resources**:

```bash
kubectl create deployment api --image=nginx:1.21 --replicas=3 --dry-run=client -o yaml > yaml-practice/sprint-2.yaml
```

Then add to the container spec:

```yaml
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
```

**Rep 3 — ClusterIP Service**:

```bash
kubectl create service clusterip api-svc --tcp=80:80 --dry-run=client -o yaml > yaml-practice/sprint-3.yaml
```

Then fix the selector — `kubectl create service` defaults the selector to `app=<name>`, but here you want `app=api`:

```yaml
spec:
  selector:
    app: api
```

Apply all three:

```bash
kca yaml-practice/sprint-1.yaml
kca yaml-practice/sprint-2.yaml
kca yaml-practice/sprint-3.yaml
```

---

## Block 1 — Task Interpretation Drills

**Prompt A** ("Expose Deployment `cache` inside the cluster only, on port 6379"):
→ **ClusterIP** — `spec.type: ClusterIP` (default). Internal only.

**Prompt B** ("Expose Deployment `web` on every node at port 30080"):
→ **NodePort** — `spec.type: NodePort`, `spec.ports[0].nodePort: 30080`. Range 30000–32767.

**Prompt C** ("Expose Deployment `api` to the public internet with a cloud load balancer"):
→ **LoadBalancer** — `spec.type: LoadBalancer`. Provisions an external LB on cloud clusters; stays Pending on local clusters.

**Prompt D** ("Create a Service `db` that resolves to `db.internal.example.com` from inside the cluster"):
→ **ExternalName** — `spec.type: ExternalName`, `spec.externalName: db.internal.example.com`. No selector, no ports, no endpoints. Pure DNS CNAME.

---

## Block 3 — Service Type Variety

### Rep 1 — ClusterIP

```bash
kubectl create service clusterip web-svc --tcp=80:80 --dry-run=client -o yaml > yaml-practice/svc-clusterip.yaml
```

Then fix the selector to `app: web` (default would be `app: web-svc`).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  type: ClusterIP        # default; explicit is fine
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
```

### Rep 2 — NodePort (write directly)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-np
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080      # lives under the port entry, not at service level
```

Note: `kubectl create service nodeport` exists but doesn't accept `--node-port`. Hand-write the YAML when a specific nodePort is required.

### Rep 3 — LoadBalancer

```bash
kubectl create service loadbalancer web-lb --tcp=80:80 --dry-run=client -o yaml > yaml-practice/svc-loadbalancer.yaml
```

Then fix the selector to `app: web`.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-lb
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
```

On local clusters: `EXTERNAL-IP` stays `<pending>`. That's expected — you're verifying YAML shape, not the LB itself.

### Rep 4 — ExternalName (write directly)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: db-ext
spec:
  type: ExternalName
  externalName: db.internal.example.com
```

No `selector`. No `ports`. No endpoints will appear. This is a pure DNS CNAME — pods in the cluster querying `db-ext.<ns>.svc.cluster.local` get `db.internal.example.com` back.

### Apply + inspect

```bash
kca yaml-practice/svc-clusterip.yaml
kca yaml-practice/svc-nodeport.yaml
kca yaml-practice/svc-loadbalancer.yaml
kca yaml-practice/svc-externalname.yaml

kubectl get svc
kubectl get endpoints
```

Endpoints column: ClusterIP / NodePort / LoadBalancer will have endpoints if `app=web` pods exist (from Block 0 Step 3 you have a Pod `web` with that label). ExternalName has no endpoints — it's not a selector-driven Service.

---

## Block 4 — Mixed Tasks

### Quick — Service named `cache`

```bash
kubectl expose deployment cache --name=cache --port=6379 --target-port=6379 --dry-run=client -o yaml > yaml-practice/cache-svc.yaml
kca yaml-practice/cache-svc.yaml
```

Note: `--name=cache` (Service name) — the Deployment is also `cache`. Legal. Re-read prompts literally; don't auto-suffix `-svc` when the prompt doesn't say to.

### Medium — frontend cross-domain

**ConfigMap** (`yaml-practice/frontend-cm.yaml`):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-cfg
data:
  index.html: |
    <!DOCTYPE html>
    <html><body><h1>Hello from ConfigMap</h1></body></html>
```

**Deployment** (`yaml-practice/frontend-deploy.yaml`):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: nginx
          image: nginx:1.21
          ports:
            - containerPort: 80
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 3
            periodSeconds: 5
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
      volumes:
        - name: html
          configMap:
            name: frontend-cfg
```

**Service** (`yaml-practice/frontend-svc.yaml`):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 80
```

Apply:

```bash
kca yaml-practice/frontend-cm.yaml
kca yaml-practice/frontend-deploy.yaml
kca yaml-practice/frontend-svc.yaml
```

Verify:

```bash
kubectl get pods -l app=frontend            # should show 2/2 Ready after probe passes
kubectl get endpoints frontend-svc          # should list 2 pod IPs
kubectl exec deploy/frontend -- curl -s localhost   # → ConfigMap HTML
```

If endpoints is empty with pods Running, check pod READY column. `readinessProbe` gates endpoint membership.

---

## Block 5 — kubectl explain notes

- `service.spec.type` valid values: `ClusterIP`, `NodePort`, `LoadBalancer`, `ExternalName`. Default `ClusterIP`.
- `service.spec.ports[].nodePort` is in range 30000–32767 by default.
- `endpoints` is a top-level resource (`v1 Endpoints`) — auto-created and managed for selector-driven Services. Empty endpoints with running pods is the classic "selector mismatch OR pods not Ready" signal — this is the W4 debug workflow on Day 4.
