# Week 5 — Plan (June 2–7)

> **STATUS: IN PROGRESS** — started Tue Jun 2 (normally a rest day, used as Day 1 to recover the W4 slip). Six-day straight run Tue→Sun, no rest interruption; next rest is Tue Jun 9 (after the milestone).

> Week 4 milestone hit Sun May 31 (PASS 7/7, ~37 min, conditional on NetworkPolicy authoring). Week 5 focus: **storage (persistent + ephemeral) + resource management + container images** — all net-new content, plus front-loaded remediation of the W4 #1 gap (cold NetworkPolicy egress authoring).

## Calendar

| Day | Date | Length | Theme |
|---|---|---|---|
| Day 1 | Tue Jun 2 | ~75 min | Volumes intro (emptyDir + PVC basics) + **NP egress remediation** |
| Day 2 | Wed Jun 3 | ~75 min | PV/PVC binding + resource requests/limits + `fieldRef` |
| Day 3 | Thu Jun 4 | ~75 min | StatefulSets + headless svc + ResourceQuota/LimitRange |
| Day 4 | Fri Jun 5 | ~75 min | Ephemeral volumes deep (`projected`) + image block intro |
| Day 5 | Sat Jun 6 | 2–3 hr | Image modify deep + complex cross-domain + milestone prep |
| Day 6 | Sun Jun 7 | 2+ hr | **Week 5 Milestone** |

---

## Gaps Carried from Week 4

From `week-4/milestone-results.md`, `week-4/notes.md`, and the weak-spot register:

1. **Cold NetworkPolicy egress authoring — the #1 gap.** At the milestone, a cold egress NP collapsed: `spec` written as a **list** not a map; combined `namespaceSelector` + `podSelector` written as two `-` peers (**OR**) when the task needed one peer (**AND**); DNS port typo. Survived 8+ `explain` calls. **Priority 1**: 3 cold egress NP reps Day 1 Block 0, then 1 NP cold in every day's review sprint until the map shape and the one-peer-AND are automatic.
2. **Cold Ingress with a real delay.** W4 Ingress reps were all reference-propped or warm (drilled <1 hr prior). The May 31 → Jun 3 gap gives a genuine cold window. Day 2 review sprint writes one Ingress cold **with no `explain` open** — the honest cold measurement the W4 metric never got. See memory `feedback_cold_test_validity`.
3. **Kustomize selector + field drill** — the 3-week stumble. Reference-open, ~15 min, render with `kubectl kustomize <dir>` before any apply. Full drill spec in `ckad-plan.md` → Week 5 Weekly Review. Runs Day 3 (full) + a lighter re-rep Day 5.
4. **Namespace-first habit.** Stamp `-n <ns>` on the generator (or set the context namespace) *before* the first apply. W4 left stray `default`-ns dupes twice (Day 4 + milestone T3). Especially load-bearing in W5: **ResourceQuota/LimitRange are namespace-scoped** — a quota in the wrong namespace is invisible.
5. **Bare `command` argv — drop the reflexive `sh -c`.** `command`/`args` are argv, one token per element: `["sleep","3600"]`, not `["sleep 3600"]` and not `["sh","-c","sleep 3600"]`. `sh -c` only for shell features (pipe/redirect/`&&`/`$VAR`). 3× confirmed reflex in W4. Day 4 image block is the natural home (Dockerfile CMD/ENTRYPOINT vs pod command/args).
6. **`create` flag syntax: `=` not `:`** (`--from-literal=key=value`, `--image=nginx`). YAML colon muscle memory leaking into the CLI. Spot-check in scaffold sprints.
7. **"Applies clean ≠ correct."** A semantically-wrong manifest applies with zero error — the API never validates intent. Read every NP rule, **and every ResourceQuota/LimitRange**, back in plain English before calling it done.
8. **Literal-prompt-name discipline** — trending closed (D5 5/5 + milestone all-exact), not declared closed. Light spot-check this week (milestone names exact), not a dedicated forced-rep block.

---

## This Week's Focus

Volumes (persistent + ephemeral), PVC/PV, StatefulSets, resource requests/limits, ResourceQuota, LimitRange, container image build/modify. Maps to **Application Design and Build (20%)** + **Application Environment, Configuration and Security (25%)**.

**Scaffold rule exceptions (write from memory — no useful generator):** PVC, StatefulSet `volumeClaimTemplates`, headless Service (`clusterIP: None`), ResourceQuota, LimitRange, and the carried Ingress/NetworkPolicy.

---

## Weekly Review (15 min) — runs at the top of each day as Block 0

**Mixed Sprint**: scaffold pod + deployment + service (imperative + one custom field each); write **one Ingress and one NetworkPolicy cold**. The NP cold rep is the #1-carry remediation — egress on Days 1–2, then mixed.

**Kustomize selector + field drill** (Day 3 full, ~15 min reference-open; Day 5 lighter re-rep). Render each rep with `kubectl kustomize <dir>` before any apply. Five reps:
1. `labels:` with `includeSelectors: false` (default) — metadata only, selectors untouched. Re-apply-safe.
2. `labels:` with `includeSelectors: true` — apply **twice**, observe `spec.selector: field is immutable` on the Deployment (the trap, on purpose). Explain in one line.
3. `images:` — bump tag via **`newTag: "1.25"`** (the field is `newTag`, NOT `version`/`tag`); `name:` matches the base image name.
4. `namePrefix:`/`nameSuffix:` + `namespace:` + `replicas:` from the overlay, base untouched.
5. `configMapGenerator:` from literals — note the **hash suffix** kustomize appends.

CKAD-safe default = `includeSelectors: false`. Avoid legacy `commonLabels:` (forces selectors true, no opt-out).

---

## Environment notes (kind — read before Day 1)

This study cluster is **kind**. Three things that bite in Week 5:

- **NetworkPolicy: back on kindnet (Calico removed W5 Day 2).** Calico was installed Day 1 but the BIRD BGP daemon crashed mid-Day-2 session, breaking pod networking entirely. Cluster recreated with default kindnet. NP reps verify at `describe netpol` + plain-English read-back; traffic enforcement not available. For real NP traffic verification: killercoda.
- **Image-load footgun.** `docker build -t app:v1 .` → `kind load docker-image app:v1`. Then the pod **must** use a non-`latest` tag + `imagePullPolicy: IfNotPresent` (or `Never`). A `latest` tag defaults `imagePullPolicy: Always` → kind tries Docker Hub → `ErrImagePull`. This is the #1 kind image gotcha.
- **PVCs dynamically provision** via the built-in `standard` (local-path) storageClass — a plain PVC binds with no hand-written PV. For *static*-PV practice, hand-write a `hostPath` PV. Both shapes appear this week.

**Pod immutability (carried from W4 probes — same class for storage):** adding a `volume`/`volumeMount`/`resources` block to a *running Pod* is forbidden (`spec: Forbidden: pod updates may not change fields other than...`). Use `kubectl replace --force -f` to cycle the pod, or put the spec in a **Deployment** (whose pod template is fully mutable).

---

## Mixed task types (VARIABLE DIFFICULTY)

- **Quick**: Scaffold pod + add volume mount; add resource limits to an existing Deployment; add an `emptyDir` to a pod.
- **Medium**: StatefulSet + PVC + headless service; pod with `downwardAPI` exposing pod name as a file; pod with `fieldRef` exposing its IP as `MY_POD_IP`.
- **Complex**: Multi-container pod + multiple volume types + resource constraints + NetworkPolicy.
- **Cross-domain**: StatefulSet + service + configmap + ResourceQuota.
- **Image build**: Modify a provided Dockerfile (base image or entrypoint), rebuild, `kind load`, run in a pod.

Cross-domain target: **40% of tasks**. Debug/fix tasks ship a **pre-broken manifest** to apply blind (per `feedback_debug_tasks_ship_broken_yaml`).

---

## Milestone (Day 6)

Complete storage + resource + image mix in a **30-minute flexible window**:
- 2 quick tasks (PVC scaffold + resource limits)
- 1 ephemeral volume task (`emptyDir` or `downwardAPI`)
- 1 medium cross-domain combination
- 1 complex stateful application scenario with resource constraints
- 1 image task (modify Dockerfile + rebuild + run)

Results → `week-5/milestone-results.md`.

---

## Week 5 Success Metrics

- [ ] Write a **cold egress NetworkPolicy** (spec-as-map, one-peer-AND vs separate-peer-OR, `policyTypes`) in <2 min with no `explain` — closes the W4 #1 gap
- [ ] **Ingress scaffold + hand-add**: `create ingress --rule` cold in one shot (✓ already) + hand-add a `tls:` block and a `defaultBackend:` block to a scaffolded Ingress — Day 5 drill
- [x] Write a **PVC** + mount it into a pod from memory — Day 1 (reference-open first exposure; ~6 min, target automaticity later)
- [ ] Write a **StatefulSet** (`serviceName` + `volumeClaimTemplates`) + headless service from memory
- [x] Add `resources.requests`/`limits` (CPU + memory) to a Deployment — Day 2; OOMKilled demo confirmed (Exit Code 137, QoS Burstable)
- [ ] Create a **ResourceQuota** + **LimitRange**; observe a quota rejection and a LimitRanger default injection
- [ ] Use all three ephemeral volume types this week: `emptyDir` (incl. `medium: Memory`), `downwardAPI`, `projected`
- [x] Use `valueFrom: fieldRef` (`MY_POD_IP`) and `resourceFieldRef` at least once each — Day 2; `resourceFieldRef` CPU millicore truncation gotcha noted
- [ ] **Image**: modify a Dockerfile, rebuild, `kind load`, run in a pod with the correct `imagePullPolicy`
- [ ] Zero `sh -c` wraps on plain-binary container commands this week
- [ ] Complete the Week 5 milestone in the 30-min flexible window

---

## CKAD Plan Validation

| CKAD Plan Requirement | Day |
|---|---|
| Scaffold + refine: pod + volume/PVC fields manually | Day 1, 2 |
| PVC + StatefulSet YAML from memory | Day 2 (PVC), Day 3 (StatefulSet) |
| Resource requests/limits (CPU + memory) | Day 2; milestone |
| ResourceQuota + LimitRange | Day 3 |
| Ephemeral volumes: emptyDir / downwardAPI / projected | Day 1 (emptyDir), Day 3 (downwardAPI), Day 4 (projected) |
| `valueFrom`: fieldRef + resourceFieldRef | Day 2 |
| Container image build/modify (~30 min, kind) | Day 4 (build), Day 5 (modify) |
| Cross-domain tasks — 40% minimum | Days 1–5 |
| Weekly review: Ingress + NP cold; Kustomize drill | Block 0 each day; Kustomize Day 3/5 |
| Carry: cold NP egress remediation | Day 1 Block 0 (3 reps); review sprints |
| Task interpretation drills (recall test, AFTER learning) | Each day, post-reps; Day 5 full |
