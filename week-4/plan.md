# Week 4 — Plan (May 24–30)

> Week 3 milestone hit Fri May 22 (conditional pass, 38 min exact). Week 4 starts Sun May 24 with a head-start session, Mon May 25 picks up, Tue is rest, Wed–Sat finish out. Focus: networking from cold memory + observability + debugging.

## Gaps Carried from Week 3

From `week-3/milestone-results.md` and `week-3/notes.md`:

1. **`apply -f` / `apply -k` over `create -f` / `create -k`** — single highest-leverage habit. 20+ slips at milestone. **Priority 1**: drill the full command form. Aliases come after mastery, not as the intervention.
2. **YAML error triage** — read parse errors before reaching for `kubectl explain`. Multi-doc files reset line numbers at `---` separators. Drilled into Day 2 Block 0 (Ingress is multi-doc-prone with TLS Secret + Ingress in one file).
3. **No-imperative resources from cold memory** — Kustomize (Week 3 carry), Ingress (Day 2), NetworkPolicy (Day 3). No `explain`, no generator, no peeking at prior files. Cold rep in every Day 1+ Block 0 until milestone.
4. **`-k` takes a directory, not a file**; **`-f` takes a file** — Day 1 Block 0 rep.
5. **`kubectl explain kustomization` does not work** — Kustomize is client-side, no API resource. Same shape will apply to ad-hoc tooling on the exam: ask "is this an API resource?" before reaching for `explain`. **Substitute**: kubernetes.io Kustomize docs are open-tab on the exam; bookmark `https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/`. For practice, `kubectl kustomize <dir>` renders without applying — use it as the feedback loop.
6. **Re-read prompt names literally** — `db-svc` vs `db-client`, env-var aliasing, container naming. 15-second interpretation phase per task, every day.
7. **`kubectl create secret generic` requires `generic`** — drilled into Day 4 cross-domain task that needs a TLS Secret for Ingress.

---

## This Week's Focus

Services (all four types), Ingress (high repetition, cold), NetworkPolicy (high repetition, cold), service discovery, connectivity debugging, observability commands.

~~Ingress and NetworkPolicy are the only Week 4 resources with no `kubectl --dry-run` shortcut~~ — **Day 2 finding**: `kubectl create ingress NAME --rule="host/path*=svc:port"` exists. See `notes.md` → Key Concepts → "Ingress has an imperative scaffold". NetworkPolicy still has no imperative scaffold and stays cold-write. Ingress reps shift to "imperative scaffold + manual `defaultBackend` / `tls` block" rather than full cold writes.

---

## Schedule

### Day 1 — Sunday May 24 (75 min): Services deep — all four types

**New this day**: ClusterIP (review) + NodePort + LoadBalancer + **ExternalName**. Service discovery via DNS (`<svc>.<ns>.svc.cluster.local`). Endpoint mechanics — why empty endpoints despite running pods. **Intervention**: `kca` / `kck` zsh aliases.

---

### Day 2 — Monday May 25 (75 min): Ingress deep — cold-write reps begin

**New this day**: `networking.k8s.io/v1` Ingress structure cold (path rules, host rules, TLS via `secretName`). Minimum 3 Ingress YAML reps. Multi-doc YAML (Ingress + TLS Secret in one file) drives the YAML triage drill.

---

### *Tuesday May 26 — rest* (standing gaming night)

---

### Day 3 — Wednesday May 27 (75 min): NetworkPolicy deep + observability block

**New this day**: NetworkPolicy structure cold (ingress + egress + combined selectors). Minimum 3 NetworkPolicy reps. **At least one rep uses `matchExpressions`** (set-based: `In` / `NotIn` / `Exists` / `DoesNotExist`) instead of `matchLabels`. 30-min observability block: `kubectl logs -c / --previous / -f / --tail / --since`, `kubectl top pods/nodes`, `kubectl get events --sort-by --field-selector`.

---

### Day 4 — Thursday May 28 (75 min): Connectivity debugging + cross-domain

**New this day**: full debug workflow (`get endpoints` → `describe svc` → pod selector check → READY check → `exec curl`). One full break/fix scenario with no hints. Cross-domain task: NetworkPolicy + Deployment + Service + ConfigMap (isolated app stack). If a NetworkPolicy comes up here, one rep uses `matchExpressions`.

**Owed from Day 3**: Udemy NetworkPolicy section + lab solutions — no Udemy access Wed evening, Day 3 Block 2 was text-overview substitute. Catch the video before Day 4 Block 3 if access is back.

---

### Day 5 — Friday May 29 (75 min): Milestone prep + weak-spot drilling

Task interpretation drill block (15 min, literal-prompt-name discipline from W3 carry). Weak-spot drills based on Days 1–4 notes. **Probe variety check**: ensure one `exec` probe and one `tcpSocket` probe were written this week — fill the gap here if not. Optional 25-min self-mock from a subset of milestone tasks.

**Forced rep — Kustomize labels + Service + Deployment** (Day 1 stumble, third week running): write a base with a Deployment AND a Service sharing a selector. Overlay adds `env: dev` label. Must survive two `apply -k` cycles without an immutable-selector error. Reference: `notes.md` → Key Concepts → "Three practical patterns".

**Forced rep — Literal-prompt-name discipline** (now 5 occurrences W3+W4: `db-svc`/`db-client`, Block 3 rep 2 backend, Block 4 medium `medium` vs `shop-ing`, missing Deployment top-label, Day 3 rep 2 `all-` vs `allow-`). Drill: 5 task prompts with deliberately verbose / similar names; write resources with names matching exactly, including hyphens/words. Self-grade by diffing prompt names against `metadata.name` in saved YAML.

---

### Day 6 — Saturday May 30 (2+ hours): Week 4 Milestone

25-minute flexible window per `ckad-plan.md`:
- 2 quick tasks (Service + Ingress cold)
- 2 medium cross-domain combinations
- 1 complex connectivity debug (broken access, no hints)
- 1 NetworkPolicy cold (specific ingress/egress rule)
- 1 observability-only task (find failing pod using logs/events/top)

Results → `week-4/milestone-results.md`.

---

## Week 4 Success Metrics

- [ ] Write Ingress YAML from cold memory in <2 min
- [ ] Write NetworkPolicy (ingress rule) YAML from cold memory in <2 min
- [ ] Write at least one NetworkPolicy using `matchExpressions`
- [ ] Cover all four Service types in YAML across the week (ClusterIP, NodePort, LoadBalancer, ExternalName)
- [ ] One `exec` probe + one `tcpSocket` probe used in tasks this week
- [ ] Zero `kubectl create -f` / `create -k` calls in Days 3–6 transcripts (full-command `apply` form, no `create`)
- [ ] Complete Week 4 milestone in 25-minute flexible window

---

## CKAD Plan Validation

Week 4 maps to **Services and Networking (20%)** + **Application Observability and Maintenance (15%)**.

| CKAD Plan Requirement | Day |
|---|---|
| Service type variety (ClusterIP/NodePort/LoadBalancer/ExternalName) | Day 1; revisited Days 4, 5 |
| Ingress cold writes — 3+ reps per session | Day 2; revisited Days 4, 5 |
| NetworkPolicy cold writes — 3+ reps per session | Day 3; revisited Days 4, 5 |
| `matchExpressions` (set-based selectors) | Day 3 primary; any later NP session |
| Probe variety — `exec` + `tcpSocket` | Spread Days 1–5; checked Day 5 |
| Connectivity debugging workflow | Day 4 |
| Observability commands (~30 min block) | Day 3 |
| Cross-domain tasks — 50% minimum | Days 2, 3, 4, 5 |
| Task interpretation drills | Every day |

> All four Service types must appear in YAML across the week. NodePort and ExternalName are the surprise picks — Day 1 covers them deliberately so the milestone isn't the first time they're written.
