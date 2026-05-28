# Week 4 — Day 3 Answers

> Reference. Day 3 Block 3 is reference-open by design — keep this file open while you work.

---

## Block 0 — Scaffold + Refine Sprint

### Rep 1 — Pod `client`

```bash
kubectl run client --image=busybox --labels=app=client --dry-run=client -o yaml -- sleep 3600 > yaml-practice/sprint-1.yaml
```

Strip dry-run artifacts. Final shape:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: client
  labels:
    app: client
spec:
  containers:
    - name: client
      image: busybox
      command: ["sleep", "3600"]
```

The `-- sleep 3600` after `--dry-run` flags becomes the container's `command`. Without it, the busybox container exits immediately (no default long-running process).

### Rep 2 — Pod `server`

```bash
kubectl run server --image=nginx:1.21 --labels=app=server --dry-run=client -o yaml > yaml-practice/sprint-2.yaml
```

Add `tcpSocket` probe:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: server
  labels:
    app: server
spec:
  containers:
    - name: server
      image: nginx:1.21
      readinessProbe:
        tcpSocket:
          port: 80
```

---

## Block 1 — Task Interpretation Drills

**Prompt A** ("`app: web` receives from `app: client` same namespace"):

```yaml
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: client
```

**Prompt B** ("Block all egress from `tier: db` except DNS UDP 53"):

```yaml
spec:
  podSelector:
    matchLabels:
      tier: db
  policyTypes: [Egress]
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
```

`policyTypes: [Egress]` + only this rule = everything else denied.

**Prompt C** ("Deny ALL ingress to ALL pods in current namespace"):

```yaml
spec:
  podSelector: {}              # selects everything in this namespace
  policyTypes: [Ingress]
  # no ingress: field → deny all ingress
```

The classic "default deny ingress" policy. `podSelector: {}` is the all-selector. Missing `ingress:` field means no allowed rules.

**Prompt D** ("`app: api` from any pod in namespace labeled `env: prod`"):

```yaml
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes: [Ingress]
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              env: prod
```

When `from:` has ONLY `namespaceSelector` (no `podSelector`), it means "any pod in matching namespaces."

**Prompt E** ("`tier: backend` from pods where `role` is `frontend` OR `worker`"):

```yaml
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector:
            matchExpressions:
              - key: role
                operator: In
                values: [frontend, worker]
```

`matchExpressions` with `operator: In` covers the OR logic. `matchLabels` cannot express "this OR that" for a single key.

---

## Block 3 — NetworkPolicy Reps

### Rep 1 — Ingress allow (matchLabels)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-client-to-server
spec:
  podSelector:
    matchLabels:
      app: server
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: client
```

Apply, then inspect:

```bash
kubectl describe netpol allow-client-to-server
```

Describe shows:
- Pod Selector: app=server (which pods are isolated by this policy)
- Allowing ingress traffic: from podSelector app=client
- Policy Types: Ingress

### Rep 2 — Egress allow DNS only

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-server-egress-dns-only
spec:
  podSelector:
    matchLabels:
      app: server
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
```

Key shape rules:
- `to:` and `ports:` are SIBLINGS under the egress rule (both at the same level). NOT nested.
- `kubernetes.io/metadata.name` is auto-set by the API server on every namespace — reliable selector for targeting specific namespaces by name.
- `protocol: UDP` for DNS — TCP 53 also exists (for large responses) but UDP covers >99% of queries. For exam, include both if asked; for "DNS only," UDP 53 is the standard answer.

### Rep 3 — Combined + matchExpressions

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-from-frontend-or-worker
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

Set-based operators:

| Operator | Meaning |
|---|---|
| `In` | label key's value is in the values list |
| `NotIn` | label key's value is NOT in the values list |
| `Exists` | label key is present (any value); `values:` omitted |
| `DoesNotExist` | label key is absent; `values:` omitted |

`matchLabels` and `matchExpressions` can coexist within the same `podSelector` — both must match (AND logic).

---

## Block 4 — Observability Notes

### `kubectl logs` flag matrix

| Flag | Effect |
|---|---|
| `-c <name>` | container in a multi-container pod. Modern kubectl (1.18+) defaults to `spec.containers[0]` and prints `Defaulted container "..." out of: ...` to stderr; not strictly required, but explicit `-c` avoids defaulting to the wrong one |
| `--previous` / `-p` | previous container's logs (after restart/crash) — critical for CrashLoopBackOff debug |
| `-f` | stream / follow (like `tail -f`) |
| `--tail=N` | last N lines |
| `--since=Nm` / `--since=Ns` | last N minutes / seconds |
| `--since-time=<RFC3339>` | logs since absolute timestamp (e.g. `2026-05-27T22:00:00Z`) |
| `-l <selector>` | pods matching a label selector (instead of by name) |
| `--all-containers` | all containers in the pod, prefixed with container name |

Common combinations:
```bash
kubectl logs deploy/api -f --tail=50          # follow last 50 lines from any pod in the deployment
kubectl logs -l app=api --all-containers      # all containers across all matching pods
kubectl logs my-pod -c sidecar --previous     # previous restart of sidecar specifically
```

### `kubectl top`

```bash
kubectl top pods                       # current namespace
kubectl top pods -A                    # all namespaces
kubectl top pods --sort-by=cpu         # sort by CPU desc
kubectl top pods --sort-by=memory      # sort by memory desc
kubectl top nodes                      # node-level CPU/memory
kubectl top pod <pod> --containers     # per-container breakdown within a pod
```

If `kubectl top` errors with "Metrics API not available," metrics-server isn't installed. On exam clusters it's installed. On kind/minikube you may need to install separately.

### `kubectl get events`

```bash
kubectl get events --sort-by=.lastTimestamp                    # chronological
kubectl get events --field-selector type=Warning               # warnings only
kubectl get events --field-selector involvedObject.name=<pod>  # events for one resource
kubectl get events -A --sort-by=.lastTimestamp | tail -20      # most recent across all ns
kubectl get events --watch                                     # stream new events
```

Why `--sort-by=.lastTimestamp` is important: default ordering is creation order, which interleaves old recurring events with brand-new ones. Sorting by `lastTimestamp` puts the most recent activity at the bottom — what you want for "what just broke."

### Debug priority order for "pod won't start"

1. `kubectl get pods` — what state? (Pending / ContainerCreating / ImagePullBackOff / CrashLoopBackOff / Running but NotReady)
2. `kubectl describe pod <pod>` — Events section at the bottom usually names the cause directly
3. `kubectl logs <pod> --previous` — for CrashLoopBackOff specifically, this is where the actual error lives
4. `kubectl get events --sort-by=.lastTimestamp | grep <pod>` — cluster-level context (scheduling failures, image pulls)

---

## Block 5 — kubectl explain notes

- `networkpolicy.spec.policyTypes` is `[]string` with values `Ingress` / `Egress`. Without this field, defaults are inferred (Ingress if `ingress:` is set, Egress if `egress:` is set) — but stating it explicitly is the safe form.
- `networkpolicy.spec.ingress[].from[]` and `egress[].to[]` are arrays of "peers." Each peer can have ANY combination of `podSelector`, `namespaceSelector`, `ipBlock`.
- **Within a single peer**: fields are ANDed (e.g., `podSelector: app=foo` AND `namespaceSelector: env=prod` means "pods labeled `app=foo` in namespaces labeled `env=prod`").
- **Across multiple peers in the same `from:`/`to:` array**: entries are ORed.
- This AND/OR distinction is the most common NetworkPolicy slip.
- `ipBlock` is for CIDR-based rules (egress to external IPs). Less common on CKAD but possible.
