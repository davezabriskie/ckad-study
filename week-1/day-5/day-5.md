# Week 1 — Day 5 (Sunday: Milestone Assessment)

**Total time**: 2 hours | This is the pass/fail day

---

## Block 1 — Milestone Assessment (20 min)

Set a timer for 20 minutes. This is the real attempt — PASS or FAIL.

Rules:
- 30-second interpretation phase before each task (included in the 20 min)
- 3-minute skip rule per task — if stuck, move on
- No notes. No answers file. No kubectl explain until you're truly stuck on a field name

**Task 1 — Quick**: Create a pod named `gateway` running `nginx:1.21` with labels `app=gateway` and `env=prod`, port 80

**Task 2 — Quick**: Create a ClusterIP service named `gateway-svc` targeting pods with `app=gateway` on port 80

**Task 3 — Medium**: Create a pod named `twin` with two containers: `primary` running `nginx:1.21` and `monitor` running `busybox` that prints "monitoring" every 10 seconds

**Task 4 — Medium**: Create a pod named `staged` that uses an init container (busybox, echo "ready") before the main `nginx:1.21` container starts

**Task 5 — Complex**: Create ConfigMap `env-cfg` with key `ENVIRONMENT=production`, create pod `prod-app` with label `app=prod-app` injecting it as env vars, expose with service `prod-svc` on port 80

When the timer ends:
- Count how many tasks are fully running
- Record result in `week-1/milestone-results.md`
- PASS = all 5 tasks complete within 20 minutes

Check answers in `day-5-answers.md` → Block 1.

---

## Block 2 — Deep Practice (50 min)

Mixed difficulty, no time limit per task. Focus on anything that tripped you up in Block 1 or Day 4.

### If you struggled with shared volumes:

Create a pod named `pipeline` with three containers all sharing one `emptyDir` volume:
- `ingest`: writes `data-$(date)` to `/shared/data.txt` every 2 seconds
- `transform`: reads `/shared/data.txt` and writes to `/shared/processed.txt`
- `output`: tails `/shared/processed.txt`

### If you struggled with ConfigMap injection:

1. Create ConfigMap `db-config` with keys: `DB_HOST=localhost`, `DB_PORT=5432`, `DB_NAME=myapp`
2. Create a pod that injects only `DB_HOST` and `DB_PORT` as individual env vars (not envFrom — use `valueFrom.configMapKeyRef`)

Check against `day-5-answers.md` → Block 2.

### If you felt solid on everything:

Create this full multi-component scenario from scratch in under 12 minutes:
- ConfigMap `frontend-cfg` with `THEME=dark`
- Pod `frontend` with label `app=frontend`, injecting the ConfigMap, running `nginx:1.21`
- Init container on `frontend` that echoes "config loaded"
- Service `frontend-svc` exposing it on port 80

---

## Block 3 — YAML Fluency Test (20 min)

Write 5 different pod YAML files from memory with no reference. One per variation:

1. Basic pod (any name, nginx)
2. Pod with resource requests and limits
3. Multi-container pod (sidecar pattern)
4. Pod with init container
5. Pod with ConfigMap env injection (create the ConfigMap too)

Grade yourself: how many required zero lookups?

---

## Block 4 — Week Review + Week 2 Prep (30 min)

Answer these in `week-1/notes.md`:

1. Which YAML structure do you still have to think hard about?
2. Which kubectl commands feel automatic vs. still need a lookup?
3. What's your average task interpretation time now vs. Day 1?

**Week 2 preview** — you'll be covering:
- Deployments, ReplicaSets, rolling updates, rollbacks
- Jobs and CronJobs
- YAML focus shifts: Deployment + Job YAML from memory

---

## End-of-Session Checklist

- [ ] Milestone result recorded in `week-1/milestone-results.md` (PASS/FAIL + task count)
- [ ] Block 2 deep practice completed
- [ ] 5 YAML fluency reps written
- [ ] Week review notes written
