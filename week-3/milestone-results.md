# Week 3 Milestone Results

**Date**: Friday May 22, 2026 (originally Sat May 17; slipped 5 days due to jury duty Mon + weekend disruption + Tuesday rest day)
**Result**: CONDITIONAL PASS — 4/6 fully passed, 1 failed (typo), 1 partially completed at buzzer
**Total Time**: 38 min (target: 38 min) — exactly at budget
**Tasks Completed**: 4 clean + 1 partial

---

## Task Timings

| Task | Target | Actual | Notes |
|---|---|---|---|
| Task 1 — ConfigMap + envFrom + readinessProbe | 4 min | ~4 min | On time, clean |
| Task 2 — Secret + secretKeyRef + Service | 4 min | ~7 min | Over by ~3 min — fumbled `kubectl create secret` (forgot `generic`) |
| Task 3 — ConfigMap volume mount + probe | 6 min | abandoned at 7 min, returned with 1 min left | Single-character typo (missing colon on `mountPath`) — see assessment |
| Task 4 — Helm install + upgrade | 7 min | **2 min** | Fastest task — Day 3 lessons recalled, slowly |
| Task 5 — Kustomize base + overlay | 7 min | ~6 min | Under target, but syntax not from memory — peeked at prior session files |
| Task 6 — Full stack (CM + Secret + Deploy + mount + probe + resources + Service) | 10 min | ~9 min | Under target on the hardest task |

---

## Task-by-Task Assessment

### Task 1 ✅
Clean. ConfigMap, envFrom injection, readinessProbe — all correct on first parse. Extra `worker: yeppers` label in pod template (not asked, harmless). No structural problems.

### Task 2 ⚠️
YAML correct but slow getting there. `kubectl create secret db-secret --from-literal...` failed — must be `kubectl create secret generic`. Needed `--help` to confirm. `--from-literal username=admin` worked but the separator (`=` vs space) is still wobbly.

Base64 encoding correct (verified: `czNjcjN0` = s3cr3t, `YWRtaW4=` = admin). `secretKeyRef.key: password` correctly selected the single key.

Minor: Service named `db-svc`, prompt said "Expose `db-client`" — literal grader would expect `db-client` as the service name. Pattern: re-read prompt for resource names literally.

### Task 3 ❌ FAIL
**Single-character typo**: line 40 had `- mountPath /etc/nginx/conf.d` (missing colon). YAML failed to parse. Everything else in the file is structurally correct: volumes/volumeMounts in the right places, ConfigMap key `server.conf` correct, probe correct.

**The real failure was triage, not knowledge.** Spent 7 minutes on 9 `kubectl explain` calls trying to figure out the structure when the structure was right. Error message said "line 26 mapping values not allowed" — that's the colon-space family, but two things hid the signal:

1. **YAML error line numbers reset at `---` separators**. Error said line 26, but file line was 40 (line 26 of the Deployment document, the second doc in the file). Couldn't reconcile what the parser was seeing.
2. **`create -f` noise**: after the ConfigMap was created, retries showed `AlreadyExists` on top of the real parse error. `apply -f` would have produced cleaner output.

Came back to Task 3 with ~1 min left after Task 6. Fixed in vim but ran out of time before re-applying.

### Task 4 ✅ (slow recall, fast execution)
Done in 2 minutes despite stumbles. Tried `--replicaCount=3` (wrong — that's a chart value, not a CLI flag), `--replicas=3` (same issue), then recalled Day 3 lesson: `--set replicaCount=3`. Upgrade-with-install upsert pattern landed correctly, though typo'd `--set replicaCount = 2` with spaces around `=` once.

Day 3 lessons retained but slow to recall. With muscle memory this is a 30-second task.

### Task 5 ⚠️ (passed but cheated on memory)
Structurally correct: base + overlay, namePrefix, image patch, label transformation. Used the modern `labels:` form instead of the literal `commonLabels:` the prompt named.

**Two memory failures**:
- `kubectl explain kustomization` × 2 — Day 4 lesson (Kustomize is client-side, no explain) still slipping
- `cat ../../day-4/yaml-practice/base/kustomization.yaml` AND `.../overlays/stg/kustomization.yaml` — peeked at prior session files for the syntax. On the exam this would be a fail (no internet, no prior files).

**Lesson:** for resources with no imperative and no explain (Kustomize, Ingress, NetworkPolicy), syntax must be in memory cold. Peeking at prior files is the same as failing.

Also: `kubectl create -k overlay/stg/kustomization.yaml` — both `create -k` (instead of `apply -k`) AND treating the path as a file (`-k` takes a directory). Two slipping lessons in one command.

### Task 6 ✅
Hardest task, under budget. Cross-domain wiring all correct: ConfigMap mount at `/etc/app`, Secret env via `secretKeyRef.key: API_TOKEN`, readinessProbe, resources requests, Service ClusterIP. Used `stringData` on the Secret (legal, kubectl encodes on apply).

Minor: container is named `stack-mnt` — copy-paste of the volume name into the container `name:` field. Legal (container and volume names can match) but reads as residue.

Took 9 `create -f` cycles to land — every iteration ate ~5-10 seconds of `delete + recreate` overhead that `apply -f` would have collapsed.

---

## The Pattern That Defined This Milestone — `create -f` / `create -k`

**Counted 20+ `kubectl create -f` and `kubectl create -k` calls across the milestone.** This is the single most expensive habit in the session. Conservative estimate: ~5 minutes of cumulative cycle time lost to delete-and-recreate vs `apply`'s idempotent reapply.

This habit has now slipped in every day of Week 3:
- Day 1: noted, lesson saved
- Day 2: noted again, lesson saved again
- Day 3: slipped on helm-managed resources (`kubectl patch` instead of `helm upgrade`)
- Day 4: 4 `create -k` slips in one session
- Day 6 milestone: 20+ slips

**Concrete intervention**: alias `kca='kubectl apply -f'` and `kck='kubectl apply -k'` in zsh config before Week 4. Make the keystroke shorter than the wrong one.

---

## Key Gaps to Carry into Week 4

1. **`apply -f` / `apply -k` over `create -f` / `create -k`** — single highest-leverage habit. Alias it; make it muscle memory. **Priority 1.**

2. **YAML error triage** — when `kubectl apply` errors with "line N mapping values not allowed", that's the colon-space family. Read the error message before reaching for `kubectl explain`. Also: multi-doc files reset line numbers at `---`, so "line 26" might mean file line 40.

3. **Kustomize syntax from memory** — peeked at prior files in Task 5. Same pressure will hit Ingress and NetworkPolicy in Week 4, where there's also no imperative and no explain. Drill the YAML shape cold before Week 4 Day 2.

4. **`create -k` takes a directory, not a file** — slipped again on Task 5. `-f` files, `-k` directories.

5. **`kubectl explain kustomization` doesn't work** — Day 4 lesson, still slipping. Kustomize is client-side; no API resource, no schema.

6. **Re-read prompt names literally** — Task 2 used `db-svc` when prompt said "Expose `db-client`". Same shape as Week 2 carry-over (env var aliasing, container naming).

7. **`kubectl create secret` requires the type** — `kubectl create secret generic <name> --from-literal=...`. Forgot `generic` on Task 2.

---

## What's Solid

- **Cross-domain wiring** (Task 6) — ConfigMap mount + Secret env + probe + resources + Service in a single YAML file, under budget. The hardest task was the most polished.
- **Helm command sequence** (Task 4) — install + upgrade --install + replicaCount override. Slow recall but landed.
- **Field placement under containers vs pod spec** — volumes pod-level, volumeMounts container-level, probes container-level. Task 3's failure was a colon typo, not field placement.
- **Base64 encoding for Secrets** — correct with `echo -n` (no trailing newline)
- **Kustomize concepts** — base/overlay mental model, namePrefix, image patch, transformations. Syntax memorization is the gap, not understanding.
- **Skip rule used** — abandoned Task 3 at the 7-min mark (slightly late but right call) and came back with leftover budget.
- **Total time control** — hit 38-min budget exactly. Pacing instinct works.

---

## Context — Why the result is stronger than 4/6 suggests

This was a cold first attempt after losing a weekend (gaming/jury duty), Tuesday (standing rest day), and Wednesday's chaos with disconnected docker. The single fail was a one-character typo on a structurally correct file. The two friction tasks (2 and 5) reflected memorized syntax slippage, not concept gaps. Helm and the complex cross-domain task — the deepest content of the week — both came in under budget.

Week 3 concepts are essentially complete. Week 4 should focus on **habit hardening** (apply > create) and **memorization drills** for no-imperative resources (Ingress, NetworkPolicy, Kustomize syntax).

---

## Deep Practice Focus Points

When deep practice happens (tonight or carried into Week 4 warm-ups), prioritize:

- **YAML error triage drill** — read parse errors first, reach for `explain` second. Multi-doc files reset line numbers at `---`.
- **`apply -f` / `apply -k` reflex** — alias and rep until `create` doesn't appear in CLI history.
- **Kustomization from memory** — write the full `kustomization.yaml` shape cold, no peeking at prior files. Base + overlay with all four transformations.
- **ConfigMap volume mount + `kubectl exec ... -- ls /etc/...` verification** — Task 3's failure mode. Re-rep until typing is automatic.