# Week 5 — Day 5 Answers

---

## Block 0 — Review + Ledger

### Ingress scaffold + hand-adds

```bash
kubectl create ingress my-ing --rule="app.local/*=web-svc:80" --dry-run=client -o yaml > ing.yaml
```

Then hand-add under `spec:` (sibling to `rules:`):

**`tls:` block:**
```yaml
spec:
  tls:
    - hosts:
        - app.local
      secretName: app-tls-secret    # a Secret of type kubernetes.io/tls must exist
  rules:
    - ...
```

**`defaultBackend:` block:**
```yaml
spec:
  defaultBackend:                   # catches requests matching no rule
    service:
      name: fallback-svc
      port:
        number: 80
  rules:
    - ...
```

Both are `spec`-level siblings to `rules` — **not** nested inside a rule or a path. The TLS Secret itself: `kubectl create secret tls app-tls-secret --cert=... --key=...` (or hand-write `type: kubernetes.io/tls` + `stringData: {tls.crt: ..., tls.key: ...}`).

Kustomize re-rep is Day 3 Block 0 reps 1–2 — same `labels:` `includeSelectors` toggle. Ledger one-liners:
- argv: `["sleep","3600"]`, `sh -c` only for shell features.
- `-f` file, `-k` directory.
- namespace-first: `-n <ns>` on the generator before first apply.
- `create` flags: `=` not `:`.
- literal names: `metadata.name` matches the prompt char-for-char.

---

## Block 1 — Image modify

### Setup — the "provided" Dockerfile (create blind if missing)
`yaml-practice/provided/Dockerfile`:
```dockerfile
FROM busybox:1.34
ENTRYPOINT ["echo", "tick"]
```
```bash
mkdir -p yaml-practice/provided
# write the file above
```

### Modified Dockerfile
```dockerfile
FROM busybox:1.36
ENTRYPOINT ["sh", "-c", "while true; do date; sleep 5; done"]
```
`sh -c` is JUSTIFIED here: a `while` loop with `;` separators is a shell construct, not a plain binary. (Contrast the carry: bare `["sleep","3600"]` needs no shell.)

```bash
docker build -t clock-app:v2 yaml-practice/provided
kind load docker-image clock-app:v2
```

`clock-pod.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: clock-pod
spec:
  containers:
    - name: clock
      image: clock-app:v2
      imagePullPolicy: IfNotPresent
```
```bash
kubectl apply -f clock-pod.yaml
kubectl logs -f clock-pod        # streaming timestamps every 5s
```

---

## Block 2 — Complex: multi-container + multi-volume + resources + NP

```bash
kubectl create namespace secure
kubectl config set-context --current --namespace=secure
```
`vault.yaml` (PVC + Pod, multi-doc):
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: vault-data
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: vault
  labels:
    app: vault
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
      resources:
        requests: {cpu: 50m, memory: 64Mi}
        limits: {cpu: 100m, memory: 128Mi}
      volumeMounts:
        - name: shared
          mountPath: /shared
        - name: data
          mountPath: /data
    - name: sidecar
      image: busybox
      command: ["sleep", "3600"]
      resources:
        requests: {cpu: 50m, memory: 64Mi}
        limits: {cpu: 100m, memory: 128Mi}
      volumeMounts:
        - name: shared
          mountPath: /shared
  volumes:
    - name: shared
      emptyDir: {}
    - name: data
      persistentVolumeClaim:
        claimName: vault-data
```
`vault-lockdown.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: vault-lockdown
spec:
  podSelector:
    matchLabels:
      app: vault
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: gateway
      ports:
        - protocol: TCP
          port: 8080
  policyTypes:
    - Ingress
```
Verify:
```bash
kubectl exec vault -c app -- sh -c 'echo hi > /shared/m'
kubectl exec vault -c sidecar -- cat /shared/m       # hi (shared emptyDir)
kubectl exec vault -c app -- printenv MY_POD_IP
kubectl exec vault -c app -- ls /data                # PVC mounted
kubectl describe netpol vault-lockdown               # rule renders; Calico enforces — can traffic-test
kubectl describe pod vault | grep -A4 -i limits
```
Default-deny: a `podSelector` with an ingress rule listing only `app: gateway` means everything else is denied by omission — that IS the lockdown.

---

## Block 3 — Cross-domain: STS + svc + CM + ResourceQuota

```bash
kubectl create namespace data
kubectl config set-context --current --namespace=data
```
`data-stack.yaml` (quota + limitrange + cm + headless svc + sts):
```yaml
apiVersion: v1
kind: ResourceQuota
metadata: {name: data-quota}
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    pods: "6"
---
apiVersion: v1
kind: LimitRange
metadata: {name: data-defaults}
spec:
  limits:
    - type: Container
      default: {cpu: 200m, memory: 256Mi}
      defaultRequest: {cpu: 100m, memory: 128Mi}
---
apiVersion: v1
kind: ConfigMap
metadata: {name: db-cfg}
data:
  DB_MODE: replica
---
apiVersion: v1
kind: Service
metadata: {name: db-headless}
spec:
  clusterIP: None
  selector: {app: db}
  ports:
    - port: 6379
---
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: db}
spec:
  serviceName: db-headless
  replicas: 2
  selector:
    matchLabels: {app: db}
  template:
    metadata:
      labels: {app: db}
    spec:
      containers:
        - name: redis
          image: redis:7
          envFrom:
            - configMapRef:
                name: db-cfg
          volumeMounts:
            - name: data
              mountPath: /data
  volumeClaimTemplates:
    - metadata: {name: data}
      spec:
        accessModes: [ReadWriteOnce]
        resources:
          requests:
            storage: 1Gi
```
```bash
kubectl get pods -l app=db                 # db-0, db-1
kubectl get pvc                            # data-db-0, data-db-1
kubectl exec db-0 -- printenv DB_MODE      # replica
kubectl describe quota data-quota          # used vs hard
```
Note: the LimitRange must exist so the StatefulSet's pods (no explicit resources) get defaulted and pass the quota — same Day 3 mechanic.

---

## Block 4 — Interpretation drills

1. StatefulSet (`volumeClaimTemplates` + `serviceName`).
2. LimitRange (`default` / `defaultRequest`, `type: Container`).
3. `resourceFieldRef: limits.cpu`.
4. `projected` volume (`secret` + `downwardAPI` sources).
5. `docker build -t tool:v3 .` → `kind load docker-image tool:v3` → pod with `:v3` + `imagePullPolicy: IfNotPresent`.
6. `command: ["sh","-c","while true; do ...; done"]` — `sh -c` justified (loop).
7. `emptyDir` with `medium: Memory`, shared mount in two containers.
8. ResourceQuota `pods: "6"`, `requests.cpu: "2"`.

---

## Block 5 — Self-mock

No answers — it's a rehearsal. Self-grade against Days 1–4 answers + the docs after. Log times and gaps to `notes.md`.
