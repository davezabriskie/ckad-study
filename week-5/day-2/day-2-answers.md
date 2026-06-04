# Week 5 — Day 2 Answers

> Block 0 Steps 2–3 are cold tests — only open this after you've committed your answer.

---

## Block 0 — Weekly Review Sprint

### Step 2 — Cold Ingress (`web-ingress`)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
    - host: app.local
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
The nesting that trips cold: `backend.service.port.number` (port is an object with `number:`, not a bare value). If that's where you stalled, that's the rep to repeat — it's the W4 cold debt.

Imperative cross-check (NOT for the cold rep — for after):
```bash
kubectl create ingress web-ingress --rule="app.local/*=web-svc:80" --dry-run=client -o yaml
```

### Step 3 — Cold NP (`allow-web-from-monitoring`)
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-from-monitoring
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: monitoring
      ports:
        - protocol: TCP
          port: 80
  policyTypes:
    - Ingress
```
Plain English: "web pods accept inbound connections from monitoring pods (same namespace) on TCP 80; all other inbound is denied."

---

## Block 2 — PV/PVC binding

**Rep 1 — dynamic (`pv-dyn.yaml`):**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dyn-pvc
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 2Gi
```
```bash
kubectl apply -f pv-dyn.yaml
kubectl get pvc dyn-pvc      # Pending — WaitForFirstConsumer (kind standard SC); NO PV yet
```
It stays `Pending` with no consumer (the Day 1 lesson). Add a pod that mounts it:
```yaml
# dyn-consumer.yaml
apiVersion: v1
kind: Pod
metadata:
  name: dyn-consumer
spec:
  containers:
    - name: app
      image: busybox
      command: ["sleep", "3600"]
      volumeMounts:
        - name: d
          mountPath: /data
  volumes:
    - name: d
      persistentVolumeClaim:
        claimName: dyn-pvc
```
```bash
kubectl apply -f dyn-consumer.yaml
kubectl get pvc dyn-pvc      # now Bound (pod scheduled → local-path provisioned the PV)
kubectl get pv               # the now-auto-created PV: RECLAIM POLICY Delete, STORAGECLASS standard
```

**Rep 2 — static (`pv-static.yaml`, multi-doc):**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: manual-pv
spec:
  capacity:
    storage: 2Gi
  accessModes: [ReadWriteOnce]
  storageClassName: manual
  hostPath:
    path: /tmp/manual-pv
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: manual-pvc
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: manual
  resources:
    requests:
      storage: 2Gi
```
```bash
kubectl get pv manual-pv pvc manual-pvc    # both Bound to each other
```
Why it pairs: matching `storageClassName: manual` (and accessModes + capacity ≥ request) binds `manual-pvc` to `manual-pv` instead of triggering the default provisioner. Mismatch `storageClassName` = PVC stuck `Pending` (the debug knob).

---

## Block 3 — Resource requests/limits

**Rep 1 (`resources-deploy.yaml`)** — resources go on the container, inside the pod template:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sizer
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sizer
  template:
    metadata:
      labels:
        app: sizer
    spec:
      containers:
        - name: nginx
          image: nginx:1.21
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 250m
              memory: 256Mi
```
```bash
kubectl describe pod -l app=sizer | grep -A6 -i requests
```

**Rep 2 — OOMKilled demo:**
```yaml
    resources:
      limits:
        memory: 64Mi
# container that allocates >64Mi → Reason: OOMKilled in `describe`
```

---

## Block 4 — `valueFrom` sources

**Rep 1 — `fieldRef` (`valuefrom-fieldref.yaml`):**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: whoami
spec:
  containers:
    - name: app
      image: busybox
      command: ["sleep", "3600"]
      env:
        - name: MY_POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
```
```bash
kubectl exec whoami -- printenv MY_POD_IP MY_POD_NAME MY_NODE_NAME
```

**Rep 2 — `resourceFieldRef` (`valuefrom-resource.yaml`):**
```yaml
      resources:
        limits:
          memory: 128Mi
        requests:
          cpu: 100m
      env:
        - name: MEM_LIMIT
          valueFrom:
            resourceFieldRef:
              containerName: app          # optional; defaults to the current container
              resource: limits.memory
        - name: CPU_REQUEST
          valueFrom:
            resourceFieldRef:
              resource: requests.cpu
```
`resourceFieldRef` requires the container to actually declare that resource — referencing `limits.memory` with no memory limit errors at create.

---

## Block 5 — Interpretation drill

- **A** → (1) no PV matches the `storageClassName`/size/accessModes; (2) the `storageClassName` is wrong or there's no provisioner for it. (Also: all matching PVs already Bound.)
- **B** → `valueFrom.fieldRef.fieldPath: status.podIP`.
- **C** → `valueFrom.resourceFieldRef.resource: limits.memory`.
- **D** → `requests.memory: 128Mi` + `limits.memory: 256Mi`.

---

## Block 6 — explain notes

The four `env[].valueFrom` sources: `configMapKeyRef`, `secretKeyRef`, `fieldRef` (pod metadata), `resourceFieldRef` (container resources). `fieldRef` paths CKAD cares about: `metadata.name`, `metadata.namespace`, `metadata.labels['key']`, `status.podIP`, `spec.nodeName`, `spec.serviceAccountName`.
