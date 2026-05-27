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
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:

### Day 4 (Thursday May 28)
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:

### Day 5 (Friday May 29)
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:

### Day 6 (Saturday May 30) — Milestone
- Milestone Result: PASS / FAIL
- Tasks Completed: ____/____
- Total Time: _____ min
- Areas to improve:
