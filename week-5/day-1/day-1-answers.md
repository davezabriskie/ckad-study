# Week 5 — Day 1 Answers

> Reference for after you've built each block. Net-new domain — reference-open is expected today.

---

## Block 0 — Weekly Review Sprint + NP Egress Remediation

### Step 1 — Mixed scaffold sprint

```bash
kubectl run web --image=nginx:1.21 --dry-run=client -o yaml > yaml-practice/sprint-1.yaml
# add readinessProbe.httpGet path:/ port:80, then:
kubectl apply -f yaml-practice/sprint-1.yaml

kubectl create deployment api --image=nginx:1.21 --replicas=2 --dry-run=client -o yaml > yaml-practice/sprint-2.yaml
# add resources.requests under the container, then apply

kubectl create service clusterip api-svc --tcp=80:80 --dry-run=client -o yaml > yaml-practice/sprint-3.yaml
# NOTE: create service clusterip sets selector to app=api-svc (the SERVICE name) — wrong.
# To front the api Deployment, prefer:  kubectl expose deployment api --name=api-svc --port=80
```

`sprint-1.yaml` probe block (under the container):
```yaml
    readinessProbe:
      httpGet:
        path: /
        port: 80
```

### Step 2 — Cold egress NetworkPolicy reps

**Rep 1 — `egress-to-db` (same-ns egress):**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: egress-to-db
spec:
  podSelector:
    matchLabels:
      app: api
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: db
      ports:
        - protocol: TCP
          port: 5432
  policyTypes:
    - Egress
```
Plain English: "api pods may open connections to db pods on TCP 5432; nothing else outbound is allowed."

**Rep 2 — `egress-to-metrics` (the AND peer):**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: egress-to-metrics
spec:
  podSelector:
    matchLabels:
      app: api
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              team: platform
          podSelector:           # SAME list item as namespaceSelector → AND
            matchLabels:
              role: metrics
      ports:
        - protocol: TCP
          port: 9090
  policyTypes:
    - Egress
```
**The trap:** `namespaceSelector` and `podSelector` under the **same `-`** = "metrics pods INSIDE platform namespaces" (AND). Two separate `-` items would mean "any pod in a platform namespace, OR any metrics pod anywhere" (OR).

**Rep 3 — `egress-locked` (AND peer + OR DNS exception):**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: egress-locked
spec:
  podSelector:
    matchLabels:
      app: api
  egress:
    - to:                                # peer 1 (AND inside)
        - namespaceSelector:
            matchLabels:
              team: platform
          podSelector:
            matchLabels:
              role: metrics
      ports:
        - protocol: TCP
          port: 9090
    - to:                                # peer 2 (separate -, so OR) = DNS
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
  policyTypes:
    - Egress
```
Plain English: "api pods may reach metrics pods inside platform namespaces on 9090, AND may reach kube-system on UDP 53 for DNS. Nothing else." `kubernetes.io/metadata.name` is the auto-applied namespace label — reliable way to target a namespace by name.

Verify (Calico enforces; read the rendered rule, optionally traffic-test):
```bash
kubectl describe netpol egress-locked
kubectl get netpol egress-locked -o yaml    # confirm spec is a MAP, peers are right
```

---

## Block 2 — emptyDir reps

**Rep 1 — shared (`emptydir-shared.yaml`):**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: scratch
spec:
  containers:
    - name: writer
      image: busybox
      command: ["sh", "-c", "echo hello > /data/msg && sleep 3600"]   # sh -c JUSTIFIED: redirect
      volumeMounts:
        - name: shared
          mountPath: /data
    - name: reader
      image: busybox
      command: ["sleep", "3600"]                                       # bare argv — no shell needed
      volumeMounts:
        - name: shared
          mountPath: /data
  volumes:
    - name: shared
      emptyDir: {}
```
```bash
kubectl exec scratch -c reader -- cat /data/msg     # -> hello
```
> Note the contrast: `writer` needs `sh -c` (it uses `>` redirect); `reader` does not (plain `sleep`).

**Rep 2 — memory-backed (`emptydir-mem.yaml`):**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mem-scratch
spec:
  containers:
    - name: app
      image: busybox
      command: ["sleep", "3600"]
      volumeMounts:
        - name: cache
          mountPath: /cache
  volumes:
    - name: cache
      emptyDir:
        medium: Memory
```
```bash
kubectl exec mem-scratch -- df -h /cache     # filesystem shows tmpfs
```

---

## Block 3 — PVC scaffold-from-memory + mount

**Rep 1 — PVC (`pvc-claim.yaml`):**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```
```bash
kubectl apply -f yaml-practice/pvc-claim.yaml
kubectl get pvc data-pvc          # STATUS Pending — see note below
```
> `resources.requests.storage` — note it's `storage`, not `memory`. Omitting `storageClassName` uses the cluster default (`standard` on kind).
>
> **`WaitForFirstConsumer` (important):** kind's `standard` storageClass (rancher local-path) defers binding until a **Pod consumes the PVC**. So a bare PVC sits `Pending` with `waiting for first consumer to be created before binding` — this is **correct, not a fault**. It flips to `Bound` the moment Rep 2's `data-pod` mounts it. Contrast a *real* Pending (wrong `storageClassName` / size unsatisfiable / no provisioner), which never clears even with a consumer. Diagnostic question: "is anything mounting this PVC yet?"

**Rep 2 — mount (`pvc-pod.yaml`):**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-pod
spec:
  containers:
    - name: web
      image: nginx:1.21
      volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: data-pvc
```
```bash
kubectl exec data-pod -- sh -c 'echo "<h1>pvc</h1>" > /usr/share/nginx/html/index.html'
kubectl exec data-pod -- curl -s localhost     # -> <h1>pvc</h1>
```

---

## Block 4 — Cross-domain: pod + emptyDir + resource limits

`buffer.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: buffer
spec:
  containers:
    - name: buffer
      image: busybox
      command: ["sleep", "3600"]
      resources:
        requests:
          cpu: 50m
          memory: 32Mi
        limits:
          cpu: 100m
          memory: 64Mi
      volumeMounts:
        - name: buf
          mountPath: /buffer
  volumes:
    - name: buf
      emptyDir: {}
```
```bash
kubectl exec buffer -- touch /buffer/x
kubectl describe pod buffer | grep -A4 -i limits
```

---

## Block 5 — Interpretation drill

- **A** → `emptyDir` (`emptyDir: {}`). Pod-lifetime, shared across containers.
- **B** → `emptyDir` with `medium: Memory` — tmpfs.
- **C** → a PV/PVC (`persistentVolumeClaim`). Survives pod deletion.
- **D** → the **PVC** (`PersistentVolumeClaim`). The pod references the claim, not the PV.

---

## Block 6 — kubectl explain notes

- `persistentvolumeclaim.spec.accessModes`: `ReadWriteOnce`, `ReadOnlyMany`, `ReadWriteMany`, `ReadWriteOncePod`.
- `pod.spec.volumes.emptyDir.medium`: `""` (disk, default) or `Memory` (tmpfs).
- `volumeMounts` is container-level; `volumes` is pod-level. They join by `name`.
