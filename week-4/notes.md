# Week 4 Study Notes

## Gaps Carried from Week 3

1. **`apply -f` / `apply -k` over `create -f` / `create -k`** — Priority 1. Drill the full command form (`kubectl apply -f`); aliases come after mastery, not as the intervention.
2. **YAML error triage** — read parse errors before reaching for `kubectl explain`. Multi-doc files reset line numbers at `---`.
3. **No-imperative, no-explain resources require cold memory**: Kustomize (W3), Ingress (W4 D2), NetworkPolicy (W4 D3).
4. **`-k` takes a directory, not a file**. `-f` takes a file.
5. **`kubectl explain kustomization` does not work** — Kustomize has no API resource. Mental rule: client-side tools have no `explain`.
6. **Re-read prompt names literally** — `db-svc` vs `db-client`, env-var aliasing, container naming.
7. **`kubectl create secret generic`** — `generic` is required.

---

## Key Concepts

### NetworkPolicy: Service labels are not Pod labels (Day 3)

NetworkPolicy peer selectors match **Pod labels**. The Service's `metadata.labels` are irrelevant to NetworkPolicy matching even when the Service fronts the pods you want to gate.

Cross-NS PoC misfire on Day 3: `podSelector: tier=backend` selected zero pods because the actual backend pods had `app=backend` and the `tier=backend` label was on the Service object. The policy applied without error and looked correct in `describe netpol` — but selected nothing, so it was a no-op.

Mental check before applying any NP: `kubectl get pods -l <key>=<value> --show-labels` — confirm pods actually carry the label you're selecting on.

### NetworkPolicy is stateful (Day 3)

Compliant CNIs (Calico, Cilium, Weave) track connection state. Allowing ingress to a backend pod automatically permits the response packets going back to the caller. You don't need to add egress rules for response traffic — only for *initiating* new connections.

This means a "deny all egress" policy on the backend still allows it to serve responses to incoming traffic. The "egress" lockdown only governs *outbound-initiated* connections (DNS lookups, external API calls, etc.).

### Cross-namespace NetworkPolicy shape (Day 3)

Policy lives in the **receiving** namespace. To allow ingress from a specific app in a different namespace:

```yaml
ingress:
  - from:
      - podSelector:
          matchLabels:
            app: frontend
        namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: frontend
```

Both selectors under the same `-` peer = AND. Without `namespaceSelector`, `podSelector` only matches pods in the **same namespace as the policy** (default scope). The `kubernetes.io/metadata.name: <ns-name>` label is auto-applied by the API server to every namespace — reliable way to target a namespace by name without manually labeling it.

DNS-resolution failures ("bad address" on wget/curl) are a separate concern from policy block — DNS needs a Service to exist for the name to resolve. Without a Service, no NP is needed to "fail" the connection; it fails at name resolution before traffic even leaves.

### `kubectl logs --previous` reliability caveat (Day 3)

`--previous` works as long as containerd hasn't GC'd the dead container's log dir. For sub-second crashers (e.g., `echo dying; exit 1`), the container may exit so fast that logs are unavailable by the time `--previous` is queried — error:

```
unable to retrieve container logs for containerd://<id>
```

Fallback: `kubectl describe pod <name>` shows `Last State: Terminated` with reason and exit code, even when logs are gone. For real-world apps that run longer, `--previous` is reliable.

Repro tip: add `sleep 5` before the failing command (`echo dying; sleep 5; exit 1`) so the log buffer gets flushed.

### Pod immutability + `patch` vs `replace --force` (Day 3)

**On a running Pod, only these spec fields are mutable:**
- `spec.containers[*].image`
- `spec.initContainers[*].image`
- `spec.activeDeadlineSeconds`
- `spec.tolerations` (additions only)
- `spec.terminationGracePeriodSeconds`

Everything else — `command`, `args`, `env`, `envFrom`, `volumes`, `volumeMounts`, `resources`, probes (`readinessProbe`/`livenessProbe`/`startupProbe`), ports, `securityContext` — is immutable on a Pod. `metadata.labels` and `metadata.annotations` ARE mutable.

`kubectl patch` and `kubectl apply` both respect the immutability rules. They'll return:

```
spec: Forbidden: pod updates may not change fields other than spec.containers[*].image, ...
```

**To change an immutable field on a Pod:**

```bash
# Path 1: delete + recreate (fastest for ad-hoc pods)
kubectl delete pod <name>
kubectl run <name> --image=... -- <new command>

# Path 2: edit YAML + replace --force (preserves the file)
kubectl get pod <name> -o yaml > pod.yaml
# vim pod.yaml — edit any field
kubectl replace --force -f pod.yaml          # = delete + recreate in one command
```

`kubectl replace --force` destroys the pod and creates a new one with the new spec — no immutability constraint because the original is gone. Different from `kubectl replace` (no `--force`), which does in-place replace and IS subject to immutability.

**Patch vs Replace mental model:**

| Command | Behavior | Respects immutability? |
|---|---|---|
| `kubectl apply -f` | strategic merge with the apply config | yes |
| `kubectl patch` | JSON patch / strategic merge / merge | yes |
| `kubectl edit` | edit + apply | yes |
| `kubectl replace -f` | in-place full-object replace | yes |
| `kubectl replace --force -f` | delete then create — pod is reborn | **no** (because it's a new pod) |

**Why this matters — and why you almost never run bare Pods in real-world Kubernetes:**

**Deployments solve this for you.** A Deployment's `spec.template.spec.containers` is fully mutable — patch it, the Deployment creates new pods with the new template and reaps old ones via rolling update. No "delete + recreate" gymnastics. Same for StatefulSets, DaemonSets.

```bash
# On a Deployment, changing command works directly:
kubectl set image deploy/myapp myapp=newimage:tag                  # image
kubectl patch deploy/myapp -p '{"spec":{"template":{"spec":{"containers":[{"name":"myapp","command":["sh","-c","..."]}]}}}}'  # command
# Both trigger rolling restart with new spec
```

The exam will surface this — if a question says "change the command on this pod," reach for delete + recreate or `replace --force`. If it's a Deployment, patch the template.

### Ingress has an imperative scaffold (discovered Day 2)

The W4 plan said Ingress had no `kubectl --dry-run` shortcut. Wrong. `kubectl create ingress` exists and produces a usable scaffold:

```bash
kubectl create ingress NAME --rule="host/path*=svc:port" --dry-run=client -o yaml > ing.yaml
```

Rule syntax:
- `host/path*=svc:port` — `*` after path → `pathType: Prefix`
- `host/path=svc:port` — no `*` → `pathType: Exact`
- Multiple rules: repeat `--rule=...` flags
- TLS: append `,tls=secretName` inside a rule — `--rule="shop.example.com/*=web-svc:80,tls=tls-secret"`

Generated YAML field order is `backend, path, pathType` (alphabetical) rather than the more idiomatic `path, pathType, backend`. Functionally identical; reorder in vim if you prefer the readable form.

**What you still need to write by hand:**
- `defaultBackend` block (no flag for it)
- The TLS Secret itself (`kubectl create secret tls NAME --cert=... --key=...` exists but needs real files; for practice, hand-write with `type: kubernetes.io/tls` + `stringData: {tls.crt, tls.key}`)
- Multi-host rules where each host has different `tls.hosts` lists

**Discovery path**: `kubectl create -h` → noticed `ingress` in the resource list → `kubectl create ingress -h` showed the `--rule` syntax. Same reflex as `--help` on a failed flag — when uncertain, ask `kubectl create -h` first.

### Kustomize — looking it up when you can't `explain` it

Kustomize is client-side. No API resource, no `kubectl explain kustomization`. Two lookup paths:

1. **kubernetes.io docs are open-tab on the CKAD exam.** Bookmark:
   `https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/`
   That page is your Kustomize `explain`. Every transformation key with examples.

2. **`kubectl kustomize <dir>`** — renders the merged output without touching the cluster. Fast feedback loop during practice: if a key is wrong, the render drops it silently or errors. Use before every `apply -k`.

#### The CKAD-relevant key surface (memorize — it's small)

| Key | What it does |
|---|---|
| `resources:` | files (base) or directories (overlay) to compose |
| `namePrefix:` / `nameSuffix:` | rename all resources |
| `labels:` | add labels (with `includeSelectors` / `includeTemplates` flags) |
| `images:` | patch image `newTag` and/or `newName` |
| `patches:` | strategic-merge or JSON-6902 patches |

#### `images:` shape

```yaml
images:
  - name: nginx           # match base image name (no tag)
    newTag: "1.22"        # patch tag only
    # newName: nginx-fork # optional: swap image name/repo
```

`name:` matches the **image name as written in the base**, not a resource name. If base has `image: nginx:1.21`, match with `name: nginx`.

#### `labels:` — `includeSelectors` / `includeTemplates` mechanics

What each flag writes to:

| Target | `includeSelectors: true` | `includeTemplates: true` |
|---|---|---|
| Deployment `spec.selector.matchLabels` | ✓ adds label | — |
| Deployment `spec.template.metadata.labels` (pod labels) | — | ✓ adds label |
| Service `spec.selector` | ✓ adds label | — |
| All resources `metadata.labels` | always ✓ (just from `pairs:`) | — |

#### The immutable-selector trap

- **Deployment `spec.selector` is immutable after creation.** First apply with `includeSelectors: true` works; any subsequent apply that changes the label set errors with `spec.selector: field is immutable`. Recovery: `kubectl delete deployment` + re-apply.
- **Service `spec.selector` is mutable.** Safe to mutate via Kustomize labels.

#### Three practical patterns

1. **Labels on pods + Service selector, not Deployment selector**: `includeSelectors: false, includeTemplates: true`, plus a separate `patches:` block for the Service selector. Verbose but survives re-apply.
2. **Fresh cluster, one-shot apply, label everything**: `includeSelectors: true, includeTemplates: true`. Knows you'll delete + re-apply Deployments if labels change.
3. **CKAD-pragmatic default**: `includeSelectors: false, includeTemplates: true`. The form that survives re-apply, which matters when iterating on an overlay.

---

## kubectl Commands for Week 4

_To be filled in as the week progresses._

---

## Daily Progress Tracking

### Day 1 (Sunday May 24)
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:
  - **Kustomize `labels:` flags slipped again** — wrote overlay without `includeSelectors: false` / `includeTemplates: true`. Third week in a row this exact form trips. Now elevated to Day 5 weak-spot drill: write a base with a Service + Deployment, overlay adds env label, must survive re-apply
  - **`images:` patch path needed a lookup** — `name:` matches base image name (no tag), `newTag:` patches the tag. Now in `notes.md` → Key Concepts
  - **Kustomize lookup pattern surfaced** — kubernetes.io docs are open-tab on the exam; that page IS the Kustomize `explain`. `kubectl kustomize <dir>` is the practice-time lookup
  - **`kca` alias set but unused in same session** — Block 0 Step 3 typed `kubectl apply -f` three times after the alias was added in Step 1. Worst-case habit outcome: aliased and not reinforced. Make `kca`/`kck` the next reflex starting Day 2
  - **Flag-guess loop before `--help`** — `--tcpPorts=80:80` → `--tcpPort=80:80` → `--help` → `--tcp=80:80`. Reflex to build: one failed flag → `--help` immediately, don't retry-with-variations
  - **Dry-run artifacts left in saved YAML** — `strategy: {}`, `status: {}`, unused `name: 80-80` on a port (W3 Day 2 lesson recurring). Strip these before `:wq`. **Now seen across 3 blocks tonight (0, 3, 4)** — promote to Day 2 opener checklist
  - **Probe `host:` field trap** — `host: localhost` on a tcpSocket probe broke readiness (kubelet probes from node netns, not pod). Default behavior (omit `host:`) targets pod IP. Rule: never set `host:` on a probe unless you have a specific reason
  - **Probe fields are immutable on a running Pod** — `kubectl apply` errors with "spec: Forbidden". Use `kubectl replace --force -f` to cycle, or `delete pod + apply`. Labels ARE mutable, but probe/container spec changes require a cycle

---

### Day 2 Opener Checklist (carry from Day 1)

Before any apply on Day 2:
- [ ] Drill `kubectl apply -f` (full form) — not `kubectl create -f`. Aliases come after mastery; not enforced here
- [ ] Strip dry-run artifacts on save: `strategy: {}`, `status: {}`, unused port `name:` entries. Make `:wq` the gate, not a future cleanup
- [ ] Re-read the prompt literally before typing — resource names, port numbers, label keys
- [ ] If a flag fails, `--help` immediately. No retry-with-variations.

### Day 2 (Tuesday May 26 — slipped from Mon May 25; Tue rest absorbed it)
- YAML Speed: 3/3 Ingress reps + quick + medium structurally correct; 2-3 patch cycles per cross-domain
- Tasks Completed: Block 0, 1, 2, 3, 4 complete. Block 5 covered implicitly through usage (explain hit during Block 0 exec probe + Block 3 ingress structure)
- Areas to improve:
  - **Literal-prompt-name slip** — Ingress named `medium` vs prompt's `shop-ing`. Fourth occurrence (W3 Task 2 `db-svc`, Block 3 rep 2 backend, Block 4 medium Ingress name + missing top-level Deployment label). Recurring genuine gap; the grader is mechanical
  - **Service missing `selector`** in Block 4 medium v1 — chain broken at apply time, endpoints would be empty. Caught + fixed in patch
  - **Missing `type: kubernetes.io/tls`** on rep 3 TLS Secret — defaults to Opaque. Strict TLS handlers would reject; tolerant controllers accept
  - **Dry-run artifact `name: 80-80`** slipped through on Block 0 svc.yaml. Day 1 lesson held on `deploy.yaml` (stripped `strategy: {}` / `status: {}`) but not on service
  - **`exec` probe wrapped in `sh -c`** unnecessarily — direct `["redis-cli", "ping"]` is cleaner since you're invoking a binary, not a shell pipeline
  - **3 `explain` calls** on `Pod.spec.containers.readinessProbe.exec` before the shape stuck — exec probe is `exec.command: [array of strings]`, that's the whole structure
- Big find: imperative `kubectl create ingress` scaffold (see Key Concepts below)

### Day 3 (Wednesday May 27)
- YAML Speed: 3/3 NetworkPolicy reps structurally correct after iteration (rep2 took 5 vim cycles on egress shape, rep3 first-try). Cross-NS PoC clean after one label-mismatch fix
- Tasks Completed: Block 0 (2 scaffolds), Block 2 (NP overview text TL;DW — no Udemy access), Block 3 (3 NP reps incl. matchExpressions), Block 4 (observability drill: logs flags, multi-container, --previous, top, events, set image, patch). Block 5 (explain) covered implicitly. Block 1 (drills) deferred per new rule — drills go after learning, not before
- Bonus: cross-namespace PoC built (frontend + backend ns, FE→BE-only ingress, FE egress locked to BE+DNS)
- Areas to improve:
  - **Literal-prompt-name slip — 5th W4 occurrence**: rep2 named `all-server-egress-dns-only` vs prompt `allow-server-egress-dns-only`. Now a load-bearing milestone risk; needs Day 5 forced rep
  - **`-k` vs `-f` slip resurfaced** (Day 3 Block 0 line 8413). Same W3 milestone Task 5 issue. `-f` files, `-k` directories
  - **Service labels are not Pod labels** — cross-NS PoC initially had `podSelector: tier=backend` matching the Service's metadata label, not the Pod labels. NetworkPolicy peer selectors match POD labels only; Service labels are irrelevant for NP
  - **`set image` container name confusion** — `kubectl set image pod/X container=image:tag` requires the container's *name as declared in spec*, which defaults to the pod name from `kubectl run` but is independent of it. Iterated several times before landing
  - **JSON patch syntax** — containers must be an array `[{name: ..., command: ...}]`, each entry needs `name:` to identify which container to patch. And Pod fields beyond `image` are immutable regardless
  - **DNS resolution ≠ NetworkPolicy** — "bad address" from wget is DNS failure (no Service exists), not NP block. NP block would be a timeout, not an address error
  - **kindnet doesn't enforce NetworkPolicy** — applies cleanly, doesn't gate traffic. Verification stays at YAML + `describe netpol` on this cluster
- Big finds this session:
  - **YAML triage W3 lesson held**: multi-doc parse error at "line 17" = line 17 of the second doc, file line 36. Did the math, found the misindented `ports:`
  - **Modern kubectl logs defaults**: `kubectl logs <multi-container-pod>` doesn't error; defaults to `spec.containers[0]` with stderr notice. Doc updated
  - **`--previous` can fail on fast crashers** — containerd may GC the dead container before kubelet can fetch logs. Fallback: `describe pod` shows Last State + exit code regardless
  - **`netpol` is the canonical short name** — avoid typing `networkpolicy` (and avoid the `netowkrpolicy` typo)
- Things to work on tomorrow (Day 4):
  - Watch Udemy NetworkPolicy + lab solutions (owed from tonight's Block 2 sub)
  - Connectivity debugging workflow with deliberate breakage (endpoints → describe svc → selector → READY → exec curl)
  - Cross-domain NP + Deploy + Svc + CM stack with one `matchExpressions` rep
  - Calibration recall test (interpretation drills) AFTER reps, per the new ordering rule

### Day 4 (ran Friday May 29 — schedule slipped one day from planned Thu May 28)
- YAML Speed: cross-domain `shop` stack built reference-open (CM via generator, Deployment scaffold+edit for `tier` label & `envFrom`, Service, hand-written NetworkPolicy). NP `matchExpressions` rep clean — `describe` confirmed `role in (frontend,worker)`
- Tasks Completed: metrics-server install on kind (Day 3 gap closed), Block 2 (5-step debug workflow on healthy stack), Block 3 (break/fix — 2 stacked faults found + fixed, no peeking), Block 4 (cross-domain shop stack, all verifications green). **Not done**: Block 1 Udemy NP video (jumped straight to metrics-server + Block 2 — still owed), Block 5 interpretation drills (deferred — both roll to Day 5)
- Bonus: closed the W4 set-based-selector carry again (`matchExpressions` in Block 4 NP)
- Areas to improve:
  - **Namespace discipline — the predicted miss**: built the entire Block 4 stack in `default`, ran the `-n shop` verify, got empty results, then had to create `shop` and re-apply. Left orphan copies in `default` to clean. Exam habit: `kubectl config set-context --current --namespace=shop` once, or `-n shop` on the *generators* so YAML is stamped from the start
  - **`kubectl create service clusterip` sets selector to the SERVICE name, not the deployment's pods** — `create service clusterip shop-backend-svc` → `selector: app=shop-backend-svc`, which matches nothing (pods are `app=shop-backend`). `kubectl expose deployment` is the right generator: it inherits the deployment's selector. Use `expose`, not `create service`, when fronting an existing deployment
  - **`targetPort` fix direction (Block 3 Fault B)**: burned ~3 min trying to set the Service to `8080` (the broken value) before landing on `80`. Rule: a wrong `targetPort` is fixed by pointing it at whatever the container actually LISTENs on (nginx → 80), not by matching the broken number
  - **`kubectl patch` strategic-merge appends on the `ports` array** — merge key is `port`. Patching `port: 8080` when the existing entry is `port: 80` ADDS a second port instead of replacing → multi-port Service → `spec.ports[1].name: Required value`. Match the existing `port` key to update in place, or just `kubectl edit`
  - **Literal-name slip continues — `shop-svc` typed twice** in Block 3 exec tests (svc is `shop-api`; also fat-fingered `shop-backend` for `shop-backend-svc`). Same W4 naming pattern. Day 5 forced rep is now well-earned
  - **`kubectl explain` field paths are case-sensitive & lowercase** — `NetworkPolicy.spec.Ingress` fails; `networkpolicy.spec.ingress.from.podSelector.matchExpressions` works. `matchExpressions` is plural (typed singular several times)
- Big finds this session:
  - **`create service` vs `expose` selector behavior** — see above. The single most useful Service-generator distinction; `expose` inherits, `create service` invents `app=<name>`
  - **Endpoints show `targetPort`, not `port`** — the IP:port pairs in `kubectl get endpoints` are pod-side (targetPort). When they diverge from the Service `port`, endpoints quietly reveal where traffic is actually being sent. Populated endpoints + failing `exec` = look at the port, not the selector
  - **`v1 Endpoints` is deprecated in v1.33+ → `discovery.k8s.io/v1 EndpointSlice`** — `kubectl get endpoints` still works for CKAD; modern view is `kubectl get endpointslices`. Don't be startled by the warning
  - **metrics-server on kind needs `--kubelet-insecure-tls`** — kind kubelet serving certs aren't signed by the cluster CA, so the scrape TLS handshake fails and the pod never goes Ready. Patch the deployment arg. Local-only convenience; exam clusters have it pre-installed (closes Day 3 "server absent" gap)
  - **The two-fault break/fix landed its lesson**: fixing the selector (Fault A) populated endpoints and made the stack LOOK healthier, but `wget` still failed (Fault B, targetPort). Did NOT stop early — walked the full workflow. Best move: sanity-checking against known-good `web-svc` to isolate the problem to `shop-api`
- Things to work on tomorrow (Day 5 — milestone prep + weak-spot drilling):
  - **Owed forward**: Udemy NP video (Block 1) + Block 5 interpretation drills (cold recall test)
  - **Probe-variety gap**: only `tcpSocket` used this week (Day 3). No `exec` probe yet — fill it Day 5 per the success metric
  - Forced rep — Kustomize labels + Service + Deployment (third week running)
  - Forced rep — literal-prompt-name discipline (now 7+ occurrences W3+W4 incl. today's `shop-svc`)
  - Namespace discipline drill — set context namespace, verify resources land where intended

### Day 5 (Friday May 29)
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:

### Day 6 (Saturday May 30) — Milestone
- Milestone Result: PASS / FAIL
- Tasks Completed: ____/____
- Total Time: _____ min
- Areas to improve:
