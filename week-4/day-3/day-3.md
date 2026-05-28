# Week 4 — Day 3 (Wednesday May 27)

**Total time**: ~80 min | NetworkPolicy reps + observability block

> Unlike Ingress (which Day 2 revealed has `kubectl create ingress`), **NetworkPolicy has no imperative scaffold**. The YAML shape lives in muscle memory, full stop. Today's load: 3 NetworkPolicy reps (reference open while you build the structure), one of which uses `matchExpressions` (set-based selectors), plus a 25-min observability block — `kubectl logs` variations, `top`, `events`.

---

## Day 3 Opener (2 min, before any block)

- [ ] Strip dry-run artifacts on save (`strategy: {}`, `status: {}`, unused `name:` on port). Day 1 lesson held on `deploy.yaml` Day 2 but `svc.yaml` slipped. Make `:wq` the gate.
- [ ] Re-read prompt names literally — fourth occurrence of that slip on Day 2. The grader is mechanical.
- [ ] One failed flag → `--help` immediately.
- [ ] Verify Ingress imperative scaffold still in head: `kubectl create ingress NAME --rule="host/path*=svc:port"` (Day 2 find). Not needed today, just hold the muscle.

---

## Block 0 — Scaffold + Refine Sprint (10 min)

Two reps, fast.

1. Pod `client`, image `busybox`, label `app: client`. Add `command: ["sleep", "3600"]` so it stays up for connectivity testing later.
2. Pod `server`, image `nginx:1.21`, label `app: server`. Add a `tcpSocket` readinessProbe on port 80.

Save to `yaml-practice/sprint-{1,2}.yaml`. Apply.

> Today's NetworkPolicy reps reference these pods (`app: client` and `app: server`). Block 0 makes the cluster state line up with the rep content.

---

## Block 1 — Task Interpretation Drills (5 min)

15 seconds each. Name the **YAML shape** — `podSelector`, `policyTypes`, `ingress.from` / `egress.to`, selector form.

**Prompt A**: "Allow pods with label `app: web` to receive traffic only from pods labeled `app: client` in the same namespace"

**Prompt B**: "Block all egress from pods labeled `tier: db` except to DNS (UDP 53)"

**Prompt C**: "Deny ALL ingress traffic to ALL pods in the current namespace"

**Prompt D**: "Allow ingress to `app: api` from any pod in a namespace labeled `env: prod`"

**Prompt E**: "Allow ingress to `tier: backend` from pods whose `role` label is `frontend` OR `worker` (use set-based selector)"

Check against `day-3-answers.md` → Block 1.

---

## Block 2 — NetworkPolicy overview (TL;DW — no Udemy access tonight)

Covered via in-chat text overview (2026-05-27). Key takeaways:

- **Default state**: without any NetworkPolicy, all pod-to-pod traffic is allowed
- **Isolation trigger**: the moment one NetworkPolicy selects a pod, that pod flips to default-deny; only explicitly-allowed traffic flows
- **`policyTypes`** is required to behave correctly. List `Ingress`, `Egress`, or both. If you define an `egress:` rule but don't list `Egress` in `policyTypes`, the rule is ignored
- **Peer types**: `podSelector` (same-namespace pods), `namespaceSelector` (any pod in matching namespaces), `ipBlock` (CIDR — egress to externals)
- **AND vs OR semantic** (the #1 slip):
  - Within a single `from:`/`to:` entry → AND (fields under the same `-`)
  - Across multiple peer entries → OR (sibling list items)
- **`podSelector: {}`** = all pods in the namespace
- **DNS exception** is universal in default-deny-egress: allow UDP 53 (and TCP 53) to namespace `kube-system` via `kubernetes.io/metadata.name` label
- **CNI dependency**: kindnet does NOT enforce NetworkPolicy. Calico, Cilium, Weave do. On `kind` your YAML applies cleanly but traffic isn't gated — you're validating shape, not isolation
- **`matchExpressions`** for set-based selection: operators `In` / `NotIn` / `Exists` / `DoesNotExist`. Same shape everywhere a selector lives

**TODO for tomorrow**: catch the Udemy NetworkPolicy section and any lab solutions in Day 4 Block 2 (see `day-4.md` opener).

---

## Block 3 — NetworkPolicy Reps (20 min)

Three reps. **Reference open** (`day-3-answers.md` → Block 3) — first exposure, build the structure, understand the shape. Cold reps reserved for Day 5/6.

**Rep 1 — Ingress allow (matchLabels)**

NetworkPolicy `allow-client-to-server` in the current namespace:
- Selects pods labeled `app: server`
- Allows ingress from pods labeled `app: client`
- `policyTypes: [Ingress]`

Save to `yaml-practice/np-1-ingress.yaml`. Apply.

**Rep 2 — Egress allow with DNS (matchLabels)**

NetworkPolicy `allow-server-egress-dns-only`:
- Selects pods labeled `app: server`
- Allows egress ONLY to DNS (UDP port 53) in `kube-system` namespace (label `kubernetes.io/metadata.name: kube-system`)
- `policyTypes: [Egress]`

This isolates the `server` pod from all egress except DNS resolution. Save to `yaml-practice/np-2-egress.yaml`. Apply.

**Rep 3 — Combined + `matchExpressions` (set-based)**

NetworkPolicy `allow-backend-from-frontend-or-worker`:
- Selects pods where `tier: backend`
- Allows ingress from pods where label `role` is **`In` ("frontend", "worker")** — use `matchExpressions`, NOT `matchLabels`
- `policyTypes: [Ingress]`

Save to `yaml-practice/np-3-matchexpr.yaml`. Apply.

> `matchExpressions` is the W4 carry rule: at least one NetworkPolicy rep per session uses set-based selectors. This is the rep that closes it. Form: `matchExpressions: [{key: role, operator: In, values: [frontend, worker]}]`.

After applying all three, inspect:

```bash
kubectl get netpol
kubectl describe netpol allow-client-to-server
kubectl describe netpol allow-backend-from-frontend-or-worker
```

`describe` shows how the policy resolved — pods selected, rules normalized. Useful structural view.

> On local clusters without a CNI that enforces NetworkPolicy (kindnet does NOT by default; Calico, Cilium, Weave do), the resource applies cleanly but doesn't actually gate traffic. That's OK — you're verifying YAML shape, not end-to-end isolation.

---

## Block 4 — Observability Commands (25 min)

The 15% domain. Pair with the debugging workflow that comes Day 4.

### `kubectl logs` — beyond `kubectl logs <pod>`

Build cluster state first (~2 min):

```bash
kubectl run logger --image=busybox -- sh -c "while true; do echo \$(date) hello; sleep 1; done"
```

Then drill the flag variations on `logger`:

```bash
kubectl logs logger
kubectl logs logger -f                  # stream / follow
kubectl logs logger --tail=10           # last 10 lines
kubectl logs logger --since=30s         # last 30 seconds
kubectl logs logger --since-time=2026-05-27T22:00:00Z   # absolute time
```

Multi-container scenario (~2 min) — apply a pod with two containers and read each:

```bash
kubectl run multi --image=nginx:1.21 --dry-run=client -o yaml > yaml-practice/multi.yaml
```

Edit to add a sidecar (any image, e.g. `busybox` running `sleep 3600`). Apply. Then:

```bash
kubectl logs multi -c nginx
kubectl logs multi -c <sidecar-name>
kubectl logs multi                    # modern kubectl (1.18+): defaults to spec.containers[0],
                                      # prints "Defaulted container ..." to stderr. Older versions errored
```

Then crash + recover scenario (~2 min):

```bash
kubectl run crasher --image=busybox -- sh -c "echo dying; exit 1"
# wait ~30 sec for the restart loop
kubectl logs crasher                  # current attempt
kubectl logs crasher --previous       # last restart's logs — critical for debug
kubectl delete pod crasher
```

### `kubectl top` — resource usage

```bash
kubectl top pods
kubectl top nodes
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory
kubectl top pods -A                   # all namespaces
```

> Requires metrics-server installed in the cluster. If `kubectl top pods` returns "Metrics API not available," that's the install status, not your command. On EKS, metrics-server is usually a separate Helm install. For exam: assume it's installed.

### `kubectl get events` — the "what just happened" lookup

```bash
kubectl get events --sort-by=.lastTimestamp
kubectl get events --field-selector type=Warning
kubectl get events --field-selector involvedObject.name=<pod>
kubectl get events -A --sort-by=.lastTimestamp | head -20
```

Plus the inline form:

```bash
kubectl describe pod <pod>            # Events section at the bottom
```

`describe` shows events scoped to that resource. For "why won't this pod start," `describe` is usually faster than filtering `get events`.

### Quick break/fix drill

Create a pod that will fail and walk the observability tools to identify why:

```bash
kubectl run badimg --image=nginx:nonexistent
```

Then, without using `kubectl describe`, find the cause using ONLY:
- `kubectl get events --sort-by=.lastTimestamp`
- `kubectl logs badimg --previous` (if any)

Expected finding: events show `Failed to pull image "nginx:nonexistent"` with reason `ErrImagePull` or `ImagePullBackOff`.

Clean up:

```bash
kubectl delete pod badimg logger multi
```

---

## Block 5 — kubectl explain drill (5 min)

```bash
kubectl explain networkpolicy.spec
kubectl explain networkpolicy.spec.podSelector
kubectl explain networkpolicy.spec.ingress
kubectl explain networkpolicy.spec.ingress.from
kubectl explain networkpolicy.spec.egress.to
kubectl explain networkpolicy.spec.policyTypes
```

Note: `policyTypes` is `[]string` — array of strings, values `Ingress`/`Egress`. NOT a single string.

Also useful for set-based selectors:

```bash
kubectl explain networkpolicy.spec.podSelector.matchExpressions
```

`matchExpressions` shape: array of `{key, operator, values}`. Operators: `In`, `NotIn`, `Exists`, `DoesNotExist`.

---

## End-of-Session Checklist

Fill in `week-4/notes.md` Day 3 tracking:
- [x] Three NetworkPolicy reps written — rep 3 used `matchExpressions` (closed W4 set-based-selector carry)
- [x] DNS egress rule shape (UDP 53 to kube-system) — landed on rep 2 after 5 vim cycles working out the to/ports sibling indentation
- [x] `policyTypes` correctly set on every rep ✓ — no slips on this
- [x] `kubectl logs --previous` used and understood; surfaced the containerd-GC caveat on fast crashers
- [x] `kubectl top pods` — not installed on this cluster (metrics-server absent), command shape memorized
- [x] `kubectl get events --sort-by=.lastTimestamp` used for break/fix drill
- [x] Dry-run artifacts — N/A (hand-wrote NP YAMLs; no `--dry-run` scaffolds today)
- [x] Areas to improve logged in `notes.md` Day 3

**Bonus PoC**: cross-namespace NetworkPolicy setup (frontend + backend ns) — FE→BE-only ingress, FE egress locked to BE+DNS. Two structural learnings:
- Service `metadata.labels` are NOT used for NetworkPolicy matching (pod labels only)
- Without `namespaceSelector`, `from.podSelector` only matches same-namespace pods
