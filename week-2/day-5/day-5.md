# Week 2 — Day 5 (Friday May 8)

**Total time**: 75 min | Milestone Eve — Cross-domain consolidation

> Milestone is tomorrow. Today is about reps, not new content. Every block here directly maps to a milestone task.

---

## Block 0 — Scaffold + Refine Sprint (15 min)

All three resource types back to back from memory. No notes.

**Rep 1**: Deployment `web`, image `nginx:1.21`, 3 replicas, label `app=web`.
Add: `resources.requests` + `resources.limits`.
Save to `yaml-practice/sprint-deploy.yaml`.

**Rep 2**: ClusterIP Service `web-svc`, selector `app=web`, port 80 → 80.
Save to `yaml-practice/sprint-svc.yaml`.

**Rep 3**: Job `batch`, image `busybox`, command `echo done`, `completions: 1`, `restartPolicy: Never`.
Save to `yaml-practice/sprint-job.yaml`.

Target: all three applied cleanly in under 12 minutes.

---

## Block 1 — ConfigMap + Deployment wiring (20 min)

This is Milestone Task 5. Do it timed.

**Task**: Create ConfigMap `app-cfg` with `ENV=prod` and `LOG_LEVEL=warn`.
Create Deployment `app`, 2 replicas, `nginx:1.21`, label `app=app`.
Inject both keys via `envFrom`.
Expose with ClusterIP service `app-svc` on port 80.

Save to `yaml-practice/full-stack.yaml` (all three resources in one file, separated by `---`).

Verify:
```bash
kubectl apply -f yaml-practice/full-stack.yaml
kubectl get pods -l app=app
kubectl exec deploy/app -- env | grep -E 'ENV|LOG_LEVEL'
kubectl get endpoints app-svc
```

Check against `day-5-answers.md` → Block 1.

---

## Block 2 — Rollout + Rollback drill (15 min)

This is Milestone Task 4. Imperative only — no YAML editing.

1. Create a Deployment named `backend`, image `redis:7`, 3 replicas
2. Update its image to `redis:7.2` and confirm the rollout completes
3. Verify the new image is running
4. Roll back to the previous version and confirm it's back on `redis:7`

Check against `day-5-answers.md` → Block 2.

---

## Block 3 — Task Interpretation Drills (10 min)

15 seconds each — write field names only, no full YAML.

**Prompt A**: "Create a Deployment named `api` with 2 replicas running `nginx:1.21`, label `app=api`, expose on port 80"
**Prompt B**: "Create a Job named `db-init` that runs `busybox` and echoes `database initialized`"
**Prompt C**: "Create ConfigMap `cfg` with `DB=postgres`, inject into Deployment `worker` via envFrom"

Check against `day-5-answers.md` → Block 3.

---

## Block 4 — Weak spot drill (15 min)

Pick the one thing from your notes most likely to trip you tomorrow and do 3 reps of it. Options:
- `configMapRef` vs `configMapKeyRef` syntax
- CronJob schedule syntax
- Service selector wiring

---

## End-of-Session Checklist

- [x] All three sprint reps applied cleanly?
- [x] Full-stack (ConfigMap + Deployment + Service) wired and verified?
- [ ] Rollout + rollback flow clean and fast?
- [x] Extra ConfigMap reps: envFrom, valueFrom (rename + dependent var substitution)
- [x] CronJob rep — schedule syntax correct
- [ ] Areas to improve: `restartPolicy: Never` on init containers — pod-level only, stop adding it
