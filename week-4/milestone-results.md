# Week 4 — Milestone Results

**Date**: 2026-05-31 (Day 5+6 combined sitting) | **Target window**: 25 min flexible

> Self-graded. Compare against Week 3 milestone (38 min, conditional pass) — the bar is faster + no `create -f` slips.

## Result: **PASS** (7/7 tasks working) — conditional on NetworkPolicy authoring

**Total time**: ~37 min (T1–5 + T7 within/near the 25-min window; T6 ran over and needed a guided structural fix)

All seven tasks ended green and verified against the live cluster. The asterisk: T6 (egress NetworkPolicy) collapsed when authored cold and was completed only after a guided fix — NP authoring is the one unmet bar. Cleaner than the W3 milestone (4 PASS / 1 FAIL / 1 partial) at comparable time.

---

## Per-task

| # | Task | Pass? | Time | Notes / faults |
|---|------|-------|------|----------------|
| 1 | Service cold (NodePort `cache-np`) | ✅ | ~1 min | Cold, clean first try. `redis:7`, 2 replicas, nodePort 30079, endpoints populated. |
| 2 | Ingress cold (`shop-ingress`) | ✅ | ~1.5 min | **WARM**, not cold — drilled <1 hr prior in D5 Block B. Scaffold `--rule="shop.local/*=80:80"` made a Service literally named `80`; caught and hand-fixed to `shop-front`. Final shape correct. |
| 3 | Cross-domain: Deploy+CM+Svc (`api`/`api-svc`) | ✅ | ~3 min | `envFrom` injects both CM keys; `app/api` 2/2, endpoints 2 IPs, `printenv` correct. **Left stray `default`-ns `api`/`api-svc` dupes** (applied before adding `namespace: app`) — cleanup owed. |
| 4 | Deploy + `exec` probe + resources (`worker`) | ✅ | ~3 min | **WARM** (probe drilled in D5 Block B). Probe + requests/limits correct. `command: ['sh','-c','sleep 3600']` — unnecessary `sh -c` wrap, **3rd session running**. |
| 5 | Connectivity debug, no hints (`orders`) — both faults? | ✅ | ~5 min | **Strongest task.** Cold, both faults found (readiness probe wrong port + Service targetPort mismatch), did NOT stop at the first fix. `wget orders` → nginx page. |
| 6 | NetworkPolicy cold (`allow-monitoring-egress`) | ✅* | ~10+ min | **Collapsed cold**, fixed with guidance: (a) wrote `spec:` as a **list** instead of a map; (b) DNS port typo `63`→`53`; (c) the AND peer (`role:metrics` *in* `team:platform` ns) written as two `-` peers = **OR**, the exact test point — fixed last. Now correct & live. |
| 7 | Observability: diagnose `probe-fail` | ✅ | ~2 min | Started with the failing probe (`/healthz`:8080), saw `0/1 Running`, diagnosed `Running ≠ Ready` (readiness probe on unserved path/port → dropped from endpoints), then fixed. |

---

## Success-metric check (from plan.md)

- [ ] Ingress YAML from cold memory < 2 min — **NOT truly cold.** Built only by walking ~7 `k explain` calls (D5 Block B); milestone T2 was warm recall <1 hr later. Artifact passes; cold recall does not. Owe a real cold rep with a delay.
- [ ] NetworkPolicy (egress rule) cold < 2 min — **NO.** Egress (T6) collapsed structurally cold (spec-as-list + OR/AND peer). The simpler *ingress* rule was written reference-closed in Block B and was correct; egress is the gap.
- [x] `matchExpressions` used at least once this week — met Days 3 & 4
- [x] All four Service types covered across the week (ClusterIP, NodePort, LoadBalancer, ExternalName) — Day 1 + NodePort again at milestone (T1)
- [x] `exec` probe + `tcpSocket` probe both used this week — tcpSocket Day 1 + exec Day 2; reinforced T4
- [x] Zero `kubectl create -f` / `create -k` in this milestone — full `apply -f` form throughout; `create` used only as a generator (`--dry-run -o yaml`), never `create -f`
- [ ] Completed within the 25-min flexible window — **~37 min.** T6 + the T7 redo pushed past it.

---

## Areas to improve

- **NetworkPolicy authoring cold = the #1 gap.** Two distinct failures under time: the whole `spec` collapsed to a list (not a map), and the combined `namespaceSelector` + `podSelector` peer was written as OR (two `-`) when the task needed AND (one `-`, second selector key no dash). Survived 8+ `explain` calls. Drill: 3 cold egress NPs early in Week 5 until the map shape and the one-peer-AND are automatic.
- **"Applies clean ≠ correct."** The OR-instead-of-AND NP applied with zero error; the API never validates intent. Build the habit of reading any NP rule back in plain English before calling it done.
- **`sh -c` wrap on container commands — now 3× (Day 2, D5 Block B, D6 T4).** Confirmed reflex, not a slip. Bare `command: ['sleep','3600']`.
- **Namespace discipline.** Applied T3's Deployment before stamping `namespace: app` → stray broken dupes in `default`. Set `-n <ns>` on the generator (or the context) *before* first apply. (Repeat of Day 4's predicted miss.)
- **Ingress is still not cold** — reference-propped both exposures. Needs a genuine cold rep with a real time gap, not a fresh re-rep.

## Big finds / what clicked

- **Connectivity debugging is a genuine strength.** T5 cold, two stacked faults on different workflow branches than Day 4, walked the full five-step workflow, didn't stop early. This is the highest-value skill on the exam.
- **Verify against the live object, not the last apply.** On T6 the file was fixed but the cluster still showed the old OR version — caught it by reading `kubectl get netpol -o yaml` instead of trusting that the apply took. Exam-grade instinct.
- **Literal-name discipline held** across all 7 tasks — every `metadata.name` exact. Two sessions clean (D5 5/5 + milestone). The 7×-slip is closing.
- **Task-design note** (acted on): debug/fix tasks must ship a pre-broken manifest to apply blind (like T5's `milestone-debug.yaml`); having the learner inject the fault themselves (T7) defeats the diagnosis.

## Carry into Week 5

- **Cold NetworkPolicy reps** (egress especially): spec-as-map, one-peer-AND vs separate-peer-OR, `policyTypes`. Front-load early-week.
- **Cold Ingress rep with a real delay** — close out the <2-min metric honestly.
- **Namespace-first habit**: `kubectl config set-context --current --namespace=<ns>` or `-n` on generators before the first apply.
- **Bare `command` arrays** — drop the reflexive `sh -c`. `command`/`args` are argv (one token per element): `["sleep","3600"]`, not `["sleep 3600"]`. `sh -c` only for shell features (pipe/redirect/`&&`/`$VAR`). Drilled into the Week 5 plan + W7 ledger.
- **Kustomize selector + field drill** — the 3-week stumble. `labels:` selector toggles (`includeSelectors`/`includeTemplates` both default false; selectors immutable) + `images.newTag` / `replicas` / `namePrefix`. Full drill spec added to `ckad-plan.md` → Week 5 Weekly Review.
- Per `ckad-plan.md`, Week 5 review sprint already includes "one Ingress and one NetworkPolicy cold" — use it to attack both unmet metrics.
