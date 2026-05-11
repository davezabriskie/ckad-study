# Week 2 — Day 6 (Sunday May 10)

**Total time**: 2+ hours | Week 2 Milestone

---

## Milestone Assessment (35 min)

**Rules**: Timed. No notes. 3-minute skip rule per task. 15-second interpretation phase before writing anything.

Start the timer now.

---

### Task 1 — Quick (3 min)

Create a Deployment named `backend` with 3 replicas running `redis:7`, label `app=backend`.
Add resource requests (`cpu: 100m`, `memory: 128Mi`) and limits (`cpu: 500m`, `memory: 256Mi`).

---

### Task 2 — Quick (3 min)

Expose `backend` with a ClusterIP service named `backend-svc` on port 6379.

---

### Task 3 — Quick (3 min)

Create a CronJob named `log-sweep` that runs every 5 minutes, image `busybox`, command `echo sweep`. Set `restartPolicy: Never`.

---

### Task 4 — Medium (5 min)

Create a Job named `db-init` that runs `busybox` and echoes `"database initialized"`. Run it 3 times sequentially (`completions: 3`, `parallelism: 1`).

---

### Task 5 — Medium (7 min)

Update the `backend` Deployment to use `redis:7.2`. Verify the rollout completes. Then roll back to `redis:7` and verify.

---

### Task 6 — Complex (12 min)

Create ConfigMap `app-cfg` with keys `ENV=prod` and `LOG_LEVEL=warn`.
Create Deployment `app` with 2 replicas, image `nginx:1.21`, label `app=app`.
- Inject `ENV` using `envFrom`
- Inject only `LOG_LEVEL` using `valueFrom.configMapKeyRef`
Add a readinessProbe (httpGet, path `/`, port 80, `initialDelaySeconds: 5`).
Expose with ClusterIP service `app-svc` on port 80.

---

**Stop timer. Record result below.**

---

## Milestone Results

See `week-2/milestone-results.md`.

---

## Deep Practice (60 min)

Focus entirely on whatever tripped you in the milestone. If all tasks were clean, drill the full sequence again with different names and images.

**If Task 6 was slow**: 3 more full-stack reps (ConfigMap + Deployment + Service + probe) back to back, timed.

**If Task 5 was slow**: drill the rollout + rollback flow 5 times until it's automatic.

**If Task 3 was slow**: 3 CronJob reps from memory, varying the schedule each time.

**If Tasks 1–2 were slow**: scaffold sprint reps — Deployment with resources, Service — until they flow without hesitation.
