# Week 2 — Deep Practice (Post-Milestone)

Targeting the three gaps identified in milestone-results.md.

---

## Drill 1 — CronJob Schedule Syntax (5 min)

The gap is `*/5` vs `5` — not the full CronJob structure. Isolate it.

Write only the schedule field value for each prompt. No YAML, no cluster:

1. Every 5 minutes
2. Every 15 minutes
3. Every hour on the hour
4. Midnight daily
5. 9am every Monday
6. Every 30 minutes

Then apply one CronJob to confirm the schedule was accepted:
```bash
kubectl get cronjob <name>   # SCHEDULE column should match what you wrote
```

Check against `week-2/notes.md` → Jobs + CronJobs section.

---

## Drill 2 — Service Imperative Scaffold (5 min)

The gap is muscle memory on a single command. No reference in this file — recall it cold.

Run it 5 times with different names and ports:
1. `api-svc`, port 8080
2. `db-svc`, port 5432
3. `cache-svc`, port 6379
4. `web-svc`, port 80
5. `metrics-svc`, port 9090

If you can't recall the command after 30 seconds on rep 1: check `week-2/notes.md`, do the rep, then close notes and repeat cold. No further checks.

---

## Drill 3 — Probe Type Interpretation (5 min)

The gap is task reading, not YAML structure. No Deployment writing needed.

For each prompt below, write only the probe type (`readinessProbe` or `livenessProbe`) and one reason why:

1. "Pod should be removed from Service endpoints until it's ready to serve traffic"
2. "Restart the container if the app stops responding"
3. "Don't send traffic to the pod during startup"
4. "Kill and replace the container if it enters a deadlock"
5. "Gate traffic behind a health check without restarting on failure"

Check against answers:
1. readinessProbe — controls Service endpoint inclusion
2. livenessProbe — triggers restart
3. readinessProbe — gates traffic, no restart
4. livenessProbe — triggers restart
5. readinessProbe — removes from endpoints, no restart
