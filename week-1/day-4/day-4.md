# Week 1 — Day 4 (Saturday: Milestone Prep)

**Total time**: 2 hours | No new Udemy content — pure practice

---

## Block 1 — Quick Udemy Review (20 min)

Rewatch only what you felt shaky on from Days 1 and 3. Suggested targets:
- If init containers felt unclear → rewatch that section
- If ConfigMap injection felt unclear → rewatch Pod Design
- If you felt solid on everything → skip this block and add time to Block 4

---

## Block 2 — YAML Marathon (25 min)

Write all 5 from memory, no notes. Save each to `yaml-practice/`. Aim to finish all 5 in under 20 minutes.

1. Basic pod with labels (any name/image)
2. Pod with resource limits (requests + limits for CPU and memory)
3. Multi-container sidecar pod (two containers, no shared volume)
4. Multi-container pod with shared `emptyDir` volume
5. Pod with init container + main container

Check against `day-4-answers.md` → Block 2 when done.

---

## Block 3 — Milestone Dry Run (20 min)

This is a timed practice run of the Week 1 milestone. Set a timer for 20 minutes.

Rules:
- 30-second interpretation phase before writing each task
- 3-minute skip rule per task
- No notes, no answers file

**Task 1 — Quick**: Create a pod named `api` running `nginx:1.21` with labels `app=api` and `tier=backend`, port 80

**Task 2 — Quick**: Create a ClusterIP service named `api-svc` that routes to pods with `app=api` on port 80

**Task 3 — Medium**: Create a pod named `processor` with two containers sharing a volume: `producer` writes a timestamp to `/data/out.txt` every 3 seconds, `consumer` tails that file

**Task 4 — Medium**: Create a pod named `init-web` with an init container that sleeps 2 seconds before the main `nginx:1.21` container starts

**Task 5 — Complex**: Create ConfigMap `app-cfg` with `ENV=staging`, create pod `app` with label `app=app` that injects it as env vars, expose with service `app-svc` on port 80

When the timer ends, stop. Check how far you got. Check answers in `day-4-answers.md` → Block 3.

---

## Block 4 — Troubleshooting (25 min)

Apply each broken manifest, diagnose and fix it. Don't look at answers until you've made a genuine attempt.

See `day-4-answers.md` → Block 4 for the broken YAML and the fixes.

**Scenario 1**: A pod is stuck in `ImagePullBackOff`. Diagnose and fix.

**Scenario 2**: A service exists but has no endpoints. Diagnose and fix.

**Scenario 3**: A pod is stuck in `Init:0/1`. Diagnose and fix.

Useful commands:
```bash
kubectl describe pod <name>
kubectl get endpoints <svc-name>
kubectl logs <pod> -c <init-container-name>
kubectl get events --sort-by='.lastTimestamp'
```

---

## Block 5 — Review (10 min)

```bash
kubectl explain pod.spec.containers.envFrom
kubectl explain pod.spec.containers.volumeMounts
```

Look at what you got wrong in Block 3. Write down 1-2 specific things to fix tomorrow.

---

## End-of-Session Checklist

- [ ] All 5 YAML marathon reps attempted
- [ ] Milestone dry run attempted (note how many tasks completed in time)
- [ ] All 3 troubleshooting scenarios resolved
- [ ] Written note of weakest area going into milestone day
