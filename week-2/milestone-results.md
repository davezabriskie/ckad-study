# Week 2 Milestone Results

**Date**: Sunday May 10, 2026
**Result**: PASS
**Total Time**: ~30 min (target: 35 min)
**Tasks Completed**: 6/6

---

## Task Timings

| Task | Target | Actual | Notes |
|---|---|---|---|
| Task 1 — Deployment + resources | 3 min | ~3 min | One failed apply, quick fix |
| Task 2 — ClusterIP Service | 3 min | ~4 min | Significant friction |
| Task 3 — CronJob | 3 min | ~5 min | Multiple kubectl explain lookups |
| Task 4 — Job | 5 min | ~2 min | Clean |
| Task 5 — Rollout + rollback | 7 min | ~2 min | Cleanest task of the session |
| Task 6 — Full stack | 12 min | ~14 min | Over target |

---

## Task-by-Task Assessment

### Task 1 ✅
Solid. Resources (requests + limits) written correctly with proper units. One failed apply due to a YAML issue, fixed quickly. No structural problems.

### Task 2 ⚠️
The YAML was correct but getting there was costly. Fumbled the imperative scaffold command repeatedly — wrong syntax, wrong capitalization (`ClusterIp` vs `clusterip`), dropped `--dry-run` flag, tried `--port` without `--tcp`. Ended up writing the YAML from scratch rather than scaffolding. On the real exam with 15-20 tasks, this kind of detour compounds.

Correct imperative form to memorize:
```bash
kubectl create service clusterip <name> --tcp=<port>:<port> --dry-run=client -o yaml > svc.yaml
```

### Task 3 ⚠️
Wrote the YAML but needed 6+ `kubectl explain` lookups to navigate the CronJob nesting — `spec.jobTemplate.spec.template.spec` is deep and took multiple attempts. Schedule syntax was also wrong: wrote `"5 * * * *"` (at minute 5 of every hour) instead of `"*/5 * * * *"` (every 5 minutes). This is the third session in a row this gap has appeared.

### Task 4 ✅
Clean. Two explain lookups for Job.spec, then applied correctly. Fast.

### Task 5 ✅
Fastest task of the session. `set image` → `rollout status` → `rollout undo` → verify — all executed without hesitation. This is locked in.

### Task 6 ⚠️
Over target at ~14 minutes. Two distinct friction points:

**envFrom + valueFrom confusion**: The task wording was ambiguous (a curriculum error — noted for future milestones). The intent was to test both injection patterns. Using `envFrom` injects all keys including `LOG_LEVEL`, then adding `valueFrom` for `LOG_LEVEL` creates a duplicate entry — explicit `env` wins silently, so it works, but it's semantically redundant. The correct approach when aliasing one key alongside a bulk inject is `envFrom` for all + explicit `env.valueFrom` with a *different name* (e.g. `APP_LOG_LEVEL`) so the alias is meaningful.

**readinessProbe path**: Tried `Pod.spec.container.readinessProbe` (missing `s`) before finding `Pod.spec.containers.readinessProbe`. A typo in the explain path burned ~3 minutes across multiple lookups. Also wrote `livenessProbe` in the final file instead of `readinessProbe` — this has now happened three times under pressure. It's a reliable failure mode.

---

## Key Gaps to Carry into Week 3

1. **CronJob schedule syntax** — `*/5 * * * *` not `5 * * * *`. Three occurrences across the week. Needs dedicated reps.
2. **Service imperative scaffold** — `kubectl create service clusterip <name> --tcp=<port>:<port>` needs to be automatic.
3. **liveness vs readiness probe** — reaching for `livenessProbe` under pressure every time. Slow down on the 15-second interpretation phase and read the task again.
4. **`Pod.spec.containers` (plural)** — typo in explain path costs time. Always `containers`, never `container`.

---

## What's Solid

- Deployment scaffold + resources: clean
- Job structure: clean
- Rollout + rollback: fastest task, no hesitation
- ConfigMap YAML: correct both times
- Service YAML (when written from scratch): correct
