# Week 5 Study Notes

## Gaps Carried from Week 4

1. **Cold NetworkPolicy egress authoring (#1 gap)** — spec-as-map (not a list), combined `namespaceSelector`+`podSelector` in ONE peer = AND vs two `-` peers = OR, `policyTypes`. 3 cold egress reps Day 1; 1 NP cold every review sprint.
2. **Cold Ingress with a real delay** — no `explain` open. Day 2 review sprint.
3. **Kustomize selector + field drill** — `includeSelectors`/`includeTemplates` both default false; selectors immutable; `images.newTag`; `replicas`; `namePrefix`. Day 3 full, Day 5 re-rep.
4. **Namespace-first** — `-n <ns>` on the generator before first apply. Quotas/LimitRanges are namespace-scoped.
5. **Bare `command` argv** — `["sleep","3600"]`; `sh -c` only for shell features.
6. **`create` flag `=` not `:`**.
7. **"Applies clean ≠ correct"** — read NP / quota / limitrange rules back in plain English.
8. **Literal-prompt-name discipline** — light spot-check (trending closed).

---

## Environment (kind)

- **NetworkPolicy: back on kindnet (Calico removed W5 Day 2).** Calico BIRD daemon crashed mid-session; cluster recreated with default kindnet. NP reps verify at `describe netpol` + plain-English read-back only.
- **Image load**: `docker build -t app:v1 .` → `kind load docker-image app:v1` → pod uses non-`latest` tag + `imagePullPolicy: IfNotPresent`/`Never` (else `ErrImagePull`).
- **PVCs** dynamically provision via the `standard` (local-path) storageClass; plain PVC binds with no PV. Static-PV practice = hand-written `hostPath` PV.
- **Pod immutability** extends to `volumes`/`resources` — use `replace --force` or a Deployment.

---

## Key Concepts

### QoS Classes (Day 2)
Derived automatically — no field to write. Three tiers based on `requests`/`limits`:
- **`Guaranteed`** — `requests` == `limits` for every resource on every container
- **`Burstable`** — `requests` < `limits` (most common)
- **`BestEffort`** — no requests or limits at all

Eviction order under node pressure: BestEffort → Burstable → Guaranteed. Exam pattern: "ensure this pod is not first evicted" → set `requests` == `limits`.

### `resourceFieldRef` CPU millicore gotcha (Day 2)
`resourceFieldRef` returns CPU in **whole cores, truncated** — `requests.cpu: 10m` → `CPU_REQUEST: 0` (or `1` depending on divisor field). Not useful at millicore values. Memory is returned in **bytes** and is accurate (`128Mi` → `134217728`). Use `fieldRef` for pod metadata; `resourceFieldRef` for memory limits/requests.

### `restartPolicy: Never` on demo pods (Day 2)
Any pod meant to crash (OOMKill, CrashLoop demo) needs `restartPolicy: Never` so the terminal state is readable in `describe`. Default `Always` restarts it immediately and the `Reason: OOMKilled` is only visible in `Last State` (still there, but cluttered). `restartPolicy: Never` = one clean death.

### `hostPath` PV capacity is not enforced (Day 2)
`df` inside a pod mounted on a `hostPath` PV shows the **node filesystem size**, not the declared `capacity.storage`. `hostPath` has no quota enforcement. Real capacity check: `kubectl get pv` / `kubectl describe pvc`. Cloud-backed PVs (EBS, GCE PD) carve a real disk and `df` shows the correct size.

### `sh -c` three-item rule (Day 2)
With `sh -c`, the argv list must have exactly **three items**: `sh`, `-c`, `<whole script as one string>`. A fourth item becomes `$0` in the shell, not a chained command. The multi-line YAML list format makes this easy to miscount:
```yaml
command:       # WRONG — "sleep 60" becomes $0
  - sh
  - -c
  - df -h /
  - sleep 60
command:       # RIGHT — both commands in one string
  - sh
  - -c
  - df -h /; sleep 60
```

### Static vs dynamic PV binding (Day 2)
- **Dynamic** (`WaitForFirstConsumer`): bare PVC stays `Pending` until a pod mounts it; provisioner then creates the PV. Observed on kind's `standard` SC.
- **Static**: PV hand-written first; PVC binds via matching `storageClassName` + `accessModes` + `capacity ≥ request`. Immediate bind, no provisioner needed.
- Pairing lever: `storageClassName` mismatch = PVC stuck `Pending` forever.

---

## kubectl Commands for Week 5

_To be filled in as the week progresses._

---

## Daily Progress Tracking

### Day 1 (Tuesday June 2 + Wednesday June 3 — split across two nights)
- **COMPLETE.** Ran Block 0 + 2 Tue night (the high-focus blocks), finished the tail (Block 3 + 4) Wed night. Net ~65 min of hands-on across two sittings.
- Env change: **swapped kindnet → Calico** (`calico.yaml` v3.27.0) — NetworkPolicy is now ENFORCED on this cluster, not just authored. Update the W5 "kindnet won't gate" assumption; NP reps can be traffic-verified going forward.
- YAML Speed: Block 0 scaffold sprint 3/3 clean; 3 egress NP reps all landed (iteration-heavy + reference-open — egress-to-db 3 cycles, egress-to-metrics ~5 + 3 `explain`, egress-locked ~4 + `explain`). PVC first exposure ~6 min / ~8 `explain` / ~6 apply cycles.
- Tasks Completed: Block 0 (scaffold sprint + 3 cold egress NP reps) + Block 2 (emptyDir shared + memory-backed) + Block 3 (PVC + mount) + Block 4 (`buffer` emptyDir + limits). **Block 1 (Udemy Volumes) — still owed** (conceptual TL;DW delivered in-session as substitute). **Block 5 (interpretation drill) — not run separately; fold into Day 2.** Block 6 (explain) covered through heavy inline usage all session.
- Block 2 detail:
  - **shared-scratch** ✓ — writer/reader loop on a shared `emptyDir`, verified live via `logs -c reader`. `sh -c` correctly used (loops + `>>` + `$(date)` = genuine shell features).
  - **memory-backed** ✓ — `emptyDir: {medium: Memory}`, tmpfs confirmed via `df -h /cache`.
  - **`sh -c` reflex — 4th occurrence**: `command: [sh, -c, sleep 3600]` on mem-scratch. `sleep 3600` is a plain binary — wants bare `["sleep","3600"]`. Tell: used `sh -c` *correctly* in shared-scratch (needed) and *unnecessarily* here (not needed). Rule is "only for shell features," not "never." Carry into Day 4 image block.
  - Process win: navigated **pod immutability** — changing `emptyDir.medium` on a running pod is forbidden, so delete + re-apply (the Day 1 immutability lesson, applied live).
- Block 3 + 4 detail (Jun 3):
  - **PVC + data-pod** ✓ — both structurally correct; pod references the PVC via `volumes[].persistentVolumeClaim.claimName` (not the PV). Verified live: empty PVC mount masked nginx's index → **403**, then `echo > index.html` served content (the 403-then-content sequence is itself proof the mount took).
  - **Two free debug reps:** (1) **`WaitForFirstConsumer`** — kind's `standard` SC (rancher local-path) defers binding until a Pod consumes the PVC, so a bare PVC sits `Pending` correctly; (2) **provisioner gone** — `ExternalProvisioning` stuck because last night's `k delete pod,namespace,...,--all` (history 8949) deleted the `local-path-storage` namespace, taking the provisioner with it. Cluster-scoped `standard` SC survived, so PVCs accepted but never provisioned. **Fix:** reapplied `local-path-provisioner` v0.0.24 → bound immediately.
  - **`delete ...,namespace,... --all` is a footgun** — `--all` distributes across *every* resource type in the list → nukes ALL namespaces, not just stray ones. Scope cleanups with `-n <ns>` or named resources. (New persistent-error candidate.)
  - **`buffer`** ✓ — emptyDir `/buffer` + requests 50m/32Mi, limits 100m/64Mi. **`sh -c` reflex CORRECTED**: wrote bare `command: ["sleep","3600"]` after the mem-scratch slip earlier the same session. Carry retiring without a forced rep.
  - **PVC shape friction (first exposure):** probed `pvc.spec.storage` before finding `resources.requests.storage`. The 4-key shape to automate: `accessModes` (list) · `resources.requests.storage` · `storageClassName` (optional). Consolidation, not a cold test.
  - **`explain` case-sensitivity recurred** — `persistantvolumeclaim`/`volumemounts` failed before camelCase `persistentVolumeClaim`/`volumeMounts`. Same W4 lesson. And `k create data-pod` → must be `k run` (no bare-pod generator).
- Big win — **the #1 W4 carry is structurally resolved**:
  - `spec` written as a **map**, not a list, on all three NP reps (the W4-milestone collapse). Retired.
  - **AND peer correct** on egress-to-metrics + egress-locked: `namespaceSelector` + `podSelector` under one `-` (no second dash) = "metrics pods INSIDE platform namespaces." This is the exact OR-vs-AND point that collapsed at the W4 milestone — now right.
- Areas to improve:
  - **"Applies clean ≠ correct" — caught one live.** egress-locked DNS peer first used `key: name` for the namespace match; namespaces carry **`kubernetes.io/metadata.name`**, not `name`, so the rule applied with zero error but selected nothing (silently broken DNS egress on Calico). **Fixed** to `kubernetes.io/metadata.name`. Lesson held: read the rule back in plain English before trusting the apply.
  - **Service port dry-run artifact** — `name: 80-80` left on `svc.yaml` (from `--tcp=80:80`). The recurring W4 slip; strip on `:wq`.
  - **NP indentation drift** — egress-to-metrics used a 7-space dash / irregular steps. Parsed and applied, but inconsistent indent is an exam footgun. Tighten to clean 2-space steps.
  - Win to bank: svc selector hand-edited from `app=api-svc` (the `create service` default that matches nothing) to `app: api` — the W4 Day-4 lesson applied unprompted.

### Day 2 (Wednesday June 3)
- **COMPLETE.** ~2.5 hrs across the evening. Block 1 (Udemy PV video) watched at work / deferred — conceptual TL;DW delivered in-session.
- YAML Speed: Block 0 — Ingress scaffolded (one-shot `--rule` syntax ✓), NP cold hand-written (✓); Block 2 — PV/PVC shape learned from scratch via `explain`; Block 4 — fieldRef + resourceFieldRef all six vars populated first try.
- Tasks Completed: Block 0 (scaffold sprint + Ingress + NP) + Block 2 (static PV/PVC + dynamic PVC + consumer pod) + Block 3 (resources Deployment + OOMKilled demo) + Block 4 (fieldRef + resourceFieldRef).
- **Cluster event:** kind cluster recreated mid-session after Calico BIRD daemon crashed (CNI networking broke after yesterday's swap). Back on kindnet — NP traffic not enforced but all storage/resource work unaffected.
- Block 0 detail:
  - **Ingress scaffolded, not cold hand-written** (history 9120→9121: started vim, then `create ingress --rule` overwrote it). `--rule` syntax correct in one shot. **Cold hand-write metric reframed** → scaffold + hand-add `tls:` / `defaultBackend:` (Day 5 drill). The exam instinct (scaffold first) is correct.
  - **NP genuinely cold hand-written** (9126 vim → 9127 apply, no scaffold). Map shape held. ✓
  - **`strategy: {}` dry-run artifact** left in deploy.yaml + `name: 80-80` in svc.yaml. Same W4 strip-on-save miss, now three sessions running. Must strip before `:wq`.
  - **NP indent drift** again — 7-space dash under `from:`. Parser forgives it; exam grader might not. 2-space clean steps.
- Block 2 detail:
  - **Dynamic PVC** — `WaitForFirstConsumer` lesson applied: observed `Pending` → added consumer pod → `Bound`. ✓
  - **Static PV hand-written from scratch** ✓ — `capacity.storage` (not `resources.requests`), `storageClassName: manual`, `hostPath`. PVC paired via matching `storageClassName` + `volumeName`. Both `Bound`.
  - **`hostPath` `df` quirk:** shows node filesystem size (~3.9G tmpfs), not the declared PV capacity. `hostPath` doesn't enforce size. Real check: `kubectl get pv/pvc` for the Kubernetes-layer capacity.
  - **`storage: 1.95M`** typo on manual-pvc (should be `2Gi`). Use binary suffix `Gi`/`Mi`, not decimal `M`/`G`.
  - **`sh -c` three-item rule surfaced:** with `sh -c`, argv must have exactly three items — `sh`, `-c`, `<whole script as one string>`. A fourth item becomes `$0` in the shell, not a chained command. The multi-line list format makes this easy to get wrong.
- Block 3 detail:
  - **`sizer` Deployment** ✓ — `requests`/`limits` on container in pod template. `strategy: {}` artifact left in.
  - **OOMKilled demo** ✓ — `Reason: OOMKilled, Exit Code: 137` confirmed in `describe`. Pod restarted 4× (no `restartPolicy: Never`) but `Last State` still showed OOMKilled. **Lesson: add `restartPolicy: Never` to OOMKill demos** so the dead state is readable.
  - **`QoS Class: Burstable`** observed (requests < limits). Three tiers: `Guaranteed` (req==lim), `Burstable` (req<lim), `BestEffort` (none). Eviction order: BestEffort → Burstable → Guaranteed. Not written on exam — derived from the resources block.
  - **`tr "\0"` quoting bug** — double quotes consumed by outer shell layer; `tr` got `\0` as one token. Fixed with awk-based allocator instead.
- Block 4 detail:
  - **`fieldRef`** ✓ — `status.podIP`, `metadata.name`, `spec.nodeName`, `metadata.labels['run']` all populated correctly. `apiVersion: v1` on one fieldRef (dry-run artifact) — harmless but strip it.
  - **`resourceFieldRef`** ✓ — `MEM_LIMIT: 134217728` (= 128Mi in bytes, correct). **`CPU_REQUEST: 1` gotcha:** `resourceFieldRef` returns CPU in whole cores, truncated — `10m` → `0` (or rounded to `1` depending on divisor). Not useful at millicore values; `fieldRef` metadata is the reliable pattern.
  - **`metadata.labels['run']` fieldPath** — valid syntax for exposing a specific label. Returned `whoami` (the `run: whoami` label `kubectl run` auto-adds).
- Areas to improve:
  - **Strip dry-run artifacts** (`strategy: {}`, `name: 80-80`, `apiVersion: v1` on fieldRef) — now four sessions running. Make it the gate before `:wq`.
  - **NP indent drift** — 2-space clean steps, every rep.
  - **`restartPolicy: Never`** on any demo pod meant to die (OOMKill, CrashLoop) — so the terminal state is readable.
  - **`resourceFieldRef` CPU millicore limitation** — useful for memory, not for sub-1-core CPU values.

### Day 3 (Thursday June 4)
- YAML Speed: _____
- Tasks Completed: ____/____
- Areas to improve:

### Day 4 (Friday June 5)
- YAML Speed: _____
- Tasks Completed: ____/____
- Areas to improve:

### Day 5 (Saturday June 6)
- YAML Speed: _____
- Tasks Completed: ____/____
- Areas to improve:

### Day 6 (Sunday June 7) — Milestone
- Milestone Result: _____
- Total Time: _____
- See `week-5/milestone-results.md` for per-task detail.
