# Week 1 — Day 1

**Total time**: 75 minutes

---

## Block 1 — Udemy Learning (30 min)

Watch the **Pods** section from Mumshad's CKAD course. Focus on:
- What a Pod is and why it's the smallest deployable unit
- Pod anatomy: containers sharing network + storage
- How `apiVersion`, `kind`, `metadata`, `spec` fit together
- Don't take notes — you'll build your own reference by writing YAML from memory

Watched:
- 10. Recap - Pods
- 12. Recap - Pods with YAML
- 13. Recap - Demo - Creating Pods with YAML

---

## Block 2 — YAML Speed Writing from Memory (15 min)

Study the reference pod in `day-1-answers.md` → Block 2, then close it.

Write a basic pod YAML from memory 3 times, getting faster each rep:
- Pod named `web-server`, image `nginx:1.21`, label `app=web`, port 80

**Target**: Each rep under 90 seconds. Save each attempt to `yaml-practice/basic-pods/`.

If you blank on a field name, use `kubectl explain pod.spec` — don't look at your notes.

**Success metric**: 3 reps, last one from full memory with no lookups.

---

## Block 3 — Task Interpretation Drill (5 min)

Set a 15-second timer per prompt. Write down only the YAML fields you'll need — don't write the full YAML yet.

**Prompt A**: "Create a pod named `cache` running `redis:7` with label `tier=backend`"

**Prompt B**: "Create a pod named `logger` with two containers: `app` running `busybox` that sleeps forever, and `log-sidecar` running `fluentd:v1.14`"

Check your field lists against `day-1-answers.md` → Block 3 when done.

---

## Block 4 — Mixed Tasks (20 min flexible window)

Apply the **3-minute skip rule**: stuck with no progress after 3 min → skip and come back.

Write the YAML yourself from the description. Apply it. Verify it. Then check against `day-1-answers.md` → Block 4.

### Quick Task (2-3 min)

Create a pod named `frontend` running `nginx:1.21` with labels `app=frontend` and `tier=web`, exposed on port 80.

Verify: `kubectl get pod frontend --show-labels`

### Medium Task (5-7 min)

Create a pod named `app-with-sidecar` with label `app=demo` containing two containers:
- `main-app` running `nginx:1.21`
- `log-sidecar` running `busybox` that runs: `while true; do echo "sidecar running"; sleep 30; done`

Verify:
```bash
kubectl get pod app-with-sidecar
kubectl logs app-with-sidecar -c main-app
kubectl logs app-with-sidecar -c log-sidecar
```

---

## Block 5 — kubectl explain Practice (5 min)

Run these and read the output:

```bash
kubectl explain pod.spec
kubectl explain pod.spec.containers
kubectl explain pod.spec.containers.ports
```

---

## End-of-Session Checklist

Fill in `week-1/notes.md` Day 1 tracking:
- [X] YAML Speed: how many clean reps in 15 min?
- [X] Interpretation Speed: avg seconds per prompt?
- [X] `frontend` pod running
- [X] `app-with-sidecar` both containers running
- [X] Areas to improve?
  - Patience with reading explain
