# Week 4 — Day 5 (condensed milestone prep)

**Total time**: ~30 min | Clears owed items + the two unmet success metrics, then hands off to the Day 6 milestone in the same sitting.

> Schedule compressed: Day 5 and Day 6 run back-to-back today. This is the explicit milestone-prep pass, so **cold framing applies** — write from memory, reference closed, then self-grade against `day-5-answers.md`. The point is to surface what didn't stick before the milestone, not to learn new structure.

## Carried into today (from Day 4 notes + week audit)
- **Cold networking reps are the real gap.** Ingress (Day 2) and NetworkPolicy (Days 3–4) have only ever been written *reference-open*. The Day 6 milestone tests them **cold, under time**. Block B is the bridge — one cold Ingress + one cold NP — the "revisited Day 5" the plan calls for, and the only pass that serves the two <2-min cold success metrics before they're graded.
- **Literal prompt names** — `shop-svc` slip Day 4, now 7+ W3/W4 occurrences. Block C drills it.
- **Kustomize labels + Service + Deployment** — third week running as a stumble. Block C, cold.
- **Probe variety is ALREADY met** — `tcpSocket` (Day 1, also Day 3) + `exec` (Day 2, `redis-cli ping`). Success metric closed; **no new probe rep required.** Optional 2-min reinforcement only if the Day 2 `exec` shape felt shaky (it cost 3 `explain` calls + an unnecessary `sh -c` wrap) — see Block B note.
- **Udemy NP video** — owed from Day 4 Block 1. Optional now (milestone is today); watch only if it won't eat the window.

---

## Block A — Owed Cold Recall Drills (8 min)

The Day 4 Block 5 interpretation prompts, run **cold** this time (they were deferred, never done). Say the YAML shape / debug step out loud or jot it — don't write full manifests. Then self-grade against `day-4/day-4-answers.md` → Block 5.

- **A1** (debug): Service has running pods but `get endpoints` shows `<none>`. Two likely causes + the command that distinguishes them.
- **A2** (debug): `exec wget <svc>` returns "bad address" immediately. NetworkPolicy block, or something else?
- **A3** (NP): allow ingress to `tier: backend` from `role=frontend` OR `role=worker` — matchLabels or matchExpressions?
- **A4** (debug): endpoints populated, DNS resolves, but `wget` hangs to timeout. Two candidate causes.
- **A5** (config): inject `APP_MODE` from a ConfigMap as an env var — name the two field shapes and when to pick each.

> Calibration check: how many came back instantly vs. needed a beat? The slow ones are your milestone risk.

---

## Block B — Cold Networking Reps: Ingress + NetworkPolicy (12 min, cold)

The milestone bridge. Both written **reference-open only** so far — this is the first cold pass, and it directly feeds the "<2 min cold" metrics graded tomorrow. Reference **closed**; write from memory, then self-grade against `day-5-answers.md` → Block B. Time each rep.

**Rep 1 — Ingress, cold (`<2 min`).** Ingress `web-ing` on host `shop.local`, path `/` (Prefix) → Service `web-svc` port 80. No TLS. Hand-write the full shape — `rules` → `host` → `http.paths` → `backend.service.name/port.number` + `pathType`. Save to `yaml-practice/ing-cold.yaml`, apply. (You may scaffold with `kubectl create ingress` *after* the cold attempt to check your shape — but write it cold first.)

> The cold-recall targets: `pathType` is **required** and a sibling of `path`; backend is `service: {name, port: {number}}` (nested `port.number`, not a bare `port`). These are the bits Day 2 leaned on the reference for.

**Rep 2 — NetworkPolicy, cold (`<2 min`).** NetworkPolicy `allow-web-from-client` in the current namespace: selects pods `app: web`, allows **ingress** from pods `app: client`, `policyTypes: [Ingress]`. Hand-write. Save to `yaml-practice/np-cold.yaml`, apply, confirm with `kubectl describe netpol`.

> This is the plan's metric-#2 shape (cold **ingress** rule). The milestone's Task 6 is a harder **egress** rule — so ingress gets its cold pass here, egress gets it at the milestone. Cold-recall targets: `from:` is a list of peers; `podSelector.matchLabels` nests one level under each peer's `-`.

> **Optional 2-min reinforcement** (only if the Day 2 `exec` probe felt shaky): Pod `health-check`, `busybox`, `command: ["sleep","3600"]`, `livenessProbe.exec.command: ["cat","/tmp/healthy"]`. The probe-variety metric is *already met* — this is pure shape-reinforcement, not a requirement. Shape in `day-5-answers.md` → Block B note.

---

## Block C — Forced Reps: Kustomize + literal names (12 min, cold)

**Rep 1 — Kustomize (cold, the third-week stumble).** In `yaml-practice/kustomize/`:
- `base/` — a Deployment `web` AND a Service `web-svc` sharing selector `app: web`; a `kustomization.yaml` listing both.
- `overlay-dev/` — a `kustomization.yaml` referencing `../base` that adds a common label `env: dev`.

Must survive **two `kubectl apply -k overlay-dev/` cycles** without an immutable-selector error. Render-check first with `kubectl kustomize overlay-dev/` (client-side, no apply). Self-grade against `day-5-answers.md` → Block C.

> The immutable-selector trap: `commonLabels` injects into the Service selector AND the Deployment `spec.selector.matchLabels`, which is immutable after first apply. The fix-pattern is in the answers — get it right cold, then verify the second apply is clean.

**Rep 2 — Literal-name discipline.** Five prompts with verbose / similar names. Write only the `metadata.name` (no full YAML), then diff against the prompt text character-for-character.

1. "A Service named `inventory-db-service` fronting the inventory database"
2. "A ConfigMap called `inventory-db-config`"
3. "A Deployment `inventory-api-backend` (note: not `inventory-backend-api`)"
4. "A NetworkPolicy `allow-api-to-db` (not `allow-db-to-api`)"
5. "A Secret named `inventory-db-creds`"

Self-grade: every `metadata.name` must match the quoted name exactly, hyphens and word order included. This is the slip that's cost you 7+ times — the grader is mechanical.

---

## Hand-off to Milestone

Once the probe metric is closed and the two forced reps are clean, go straight to `day-6/day-6.md`. Don't break the session — the milestone is the main event today.

**Pre-milestone checklist:**
- [ ] Ingress written **cold** in <2 min (first cold pass — the metric tested tomorrow)
- [ ] NetworkPolicy (ingress rule) written **cold** in <2 min
- [ ] Kustomize survived two `apply -k` cycles
- [ ] Literal-name drill: 5/5 exact
- [ ] Interpretation drills: note which were slow (milestone risk areas)
- [x] Probe variety — already met (tcpSocket Day 1, exec Day 2); no action needed
