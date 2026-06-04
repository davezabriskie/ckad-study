# Week 5 — Day 3 Answers

---

## Block 0 — Kustomize Drill

Base (`base/`): `deployment.yaml` (web, `app: web` selector + pod label) + `service.yaml` (web-svc, `app: web` selector) + `kustomization.yaml` with `resources: [deployment.yaml, service.yaml]`.

**Rep 1 — labels, selectors untouched (overlay `kustomization.yaml`):**
```yaml
resources:
  - ../base
labels:
  - pairs:
      env: dev
    includeSelectors: false      # default — metadata.labels only
```
`kubectl kustomize overlay/` → `env: dev` appears on `metadata.labels` only, NOT in `spec.selector`. Safe to re-apply.

**Rep 2 — the immutable trap:**
```yaml
labels:
  - pairs:
      env: dev
    includeSelectors: true       # writes into Deployment spec.selector + Service selector
```
First `apply -k` works. Change `env: dev`→`env: prod`, apply again → `The Deployment "web" is invalid: spec.selector: Invalid value: ...: field is immutable`. One-liner: **Deployment selectors are immutable after creation; `includeSelectors: true` rewrites the selector on every label change, so the second apply collides.**

**Rep 3 — images:**
```yaml
images:
  - name: nginx        # the base image name, no tag
    newTag: "1.25"     # NOT version:/tag: — the field is newTag
```

**Rep 4 — prefix/suffix/namespace/replicas:**
```yaml
namePrefix: dev-
nameSuffix: -v2
namespace: web-dev
replicas:
  - name: web         # the BASE resource name (before prefix/suffix)
    count: 4
```

**Rep 5 — configMapGenerator:**
```yaml
configMapGenerator:
  - name: app-cfg
    literals:
      - LOG_LEVEL=debug
      - MAX_CONN=100
```
Rendered name = `app-cfg-<hash>` (e.g. `app-cfg-9f8b7c6d2t`). The hash forces a rollout when the CM changes; reference it by base name in `configMapRef` and kustomize rewrites the reference.

---

## Block 2 — StatefulSet + headless service

**Rep 1 — headless Service (`sts-svc.yaml`):**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-headless
spec:
  clusterIP: None          # headless — no VIP, DNS returns pod IPs
  selector:
    app: nginx-sts
  ports:
    - port: 80
```

**Rep 2 — StatefulSet (`sts-set.yaml`):**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web-sts
spec:
  serviceName: web-headless      # REQUIRED — ties to the headless svc
  replicas: 2
  selector:
    matchLabels:
      app: nginx-sts
  template:
    metadata:
      labels:
        app: nginx-sts
    spec:
      containers:
        - name: nginx
          image: nginx:1.21
          ports:
            - containerPort: 80
          volumeMounts:
            - name: www
              mountPath: /usr/share/nginx/html
  volumeClaimTemplates:          # one PVC per replica, NOT a volumes: entry
    - metadata:
        name: www
      spec:
        accessModes: [ReadWriteOnce]
        resources:
          requests:
            storage: 1Gi
```
```bash
kubectl get pods -l app=nginx-sts     # web-sts-0, web-sts-1 (ordered, 0 then 1)
kubectl get pvc                       # www-web-sts-0, www-web-sts-1
```
Cold-write essentials: `serviceName` (required), `volumeClaimTemplates` (a top-level list under `spec`, sibling to `template` — NOT a `volumes:` entry), and the headless Service it names. PVCs are named `<template>-<sts>-<ordinal>`.

---

## Block 3 — ResourceQuota + LimitRange

```bash
kubectl create namespace quota-demo
kubectl config set-context --current --namespace=quota-demo    # namespace-first
```

**Rep 1 — ResourceQuota (`quota.yaml`):**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    pods: "4"
```

**Rep 2 — rejection:**
```bash
kubectl run noreq --image=nginx:1.21
# Error from server (Forbidden): pods "noreq" is forbidden: failed quota: compute-quota:
#   must specify limits.cpu,limits.memory,requests.cpu,requests.memory
```
"Applies clean ≠ correct" inverse: the quota makes the API *reject* under-specified pods. The pod never lands.

**Rep 3 — LimitRange default (`limitrange.yaml`):**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: defaults
spec:
  limits:
    - type: Container
      default:                 # default LIMITS
        cpu: 500m
        memory: 512Mi
      defaultRequest:          # default REQUESTS
        cpu: 200m
        memory: 256Mi
```
```bash
kubectl apply -f yaml-practice/limitrange.yaml
kubectl run noreq --image=nginx:1.21          # now ADMITTED
kubectl get pod noreq -o yaml | grep -A6 resources
# requests/limits stamped by LimitRanger → quota satisfied
```
Read it back: "the pod declared no requests, but LimitRanger defaulted them to 200m/256Mi, which the quota then counted — so it was admitted."

> Cleanup: `kubectl config set-context --current --namespace=default` when done, or you'll build Day 4 in `quota-demo`.

---

## Block 4 — downwardAPI volume + cross-domain

**Rep 1 — downwardAPI (`downwardapi.yaml`):**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: meta
  labels:
    app: meta
    tier: demo
spec:
  containers:
    - name: app
      image: busybox
      command: ["sleep", "3600"]
      volumeMounts:
        - name: podinfo
          mountPath: /etc/podinfo
  volumes:
    - name: podinfo
      downwardAPI:
        items:
          - path: name
            fieldRef:
              fieldPath: metadata.name
          - path: labels
            fieldRef:
              fieldPath: metadata.labels
```
```bash
kubectl exec meta -- cat /etc/podinfo/name      # meta
kubectl exec meta -- cat /etc/podinfo/labels    # app="meta"\ntier="demo"
```
Same `fieldPath` sources as Day 2's `fieldRef` env vars — delivered as files instead. (Note: `status.podIP` works in env `fieldRef` but NOT in a downwardAPI volume — volumes only support `metadata.*` and `resourceFieldRef`.)

**Rep 2 — cross-domain stack:** StatefulSet `cache-sts` (`redis:7`, 2 replicas, `serviceName: cache-headless`) + headless `cache-headless` (`clusterIP: None`) + ConfigMap `cache-cfg` injected via `envFrom`/`env`. Same StatefulSet shape as Block 2 with the CM wired in.

---

## Block 5 — Interpretation drill

- **A** → StatefulSet (`volumeClaimTemplates` for per-pod storage, `serviceName` for stable identity).
- **B** → a **headless** Service (`clusterIP: None`).
- **C** → a **ResourceQuota** that requires requests caused the rejection; a **LimitRange** (`defaultRequest`/`default`) fixes it without touching the pod.
- **D** → a `downwardAPI` volume with `fieldRef: metadata.labels`.

---

## Block 6 — explain notes

- `statefulset.spec`: `serviceName` (required), `volumeClaimTemplates` (list of PVC specs), `selector`, `template`, `replicas`.
- `resourcequota.spec.hard`: keys like `requests.cpu`, `limits.memory`, `pods`, `configmaps`, `services`, `persistentvolumeclaims`.
- `limitrange.spec.limits[]`: `type` (`Container`/`Pod`/`PersistentVolumeClaim`), `default`, `defaultRequest`, `max`, `min`.
- `downwardAPI` volume items: `metadata.*` and `resourceFieldRef` only (no `status.podIP`).
