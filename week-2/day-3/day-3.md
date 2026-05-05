# Week 2 — Day 3 (Monday May 4)

**Total time**: 60–90 min | Rolling Updates + Jobs

---

## Block 1 — Scaffold + Refine Sprint (15 min)

Mandatory from Week 2+. Generate, then add non-scaffold fields.

**Rep 1**: Generate a Deployment scaffold for `web`, image `nginx:1.21`, 3 replicas.
Then manually add to the YAML before applying:
- `resources.requests` and `resources.limits` (cpu + memory) — **both** sections, fixing the Day 2 gap
- A liveness probe (httpGet, path `/`, port 80, initialDelaySeconds 5)

Save to `yaml-practice/sprint-1.yaml`.

```bash
kubectl create deployment web --image=nginx:1.21 --replicas=3 --dry-run=client -o yaml > yaml-practice/sprint-1.yaml
# edit in vim, then:
kubectl apply -f yaml-practice/sprint-1.yaml
```

**Rep 2**: Generate a Deployment scaffold for `cache`, image `redis:7`, 1 replica.
Add:
- `resources.requests` + `resources.limits`
- `strategy.type: Recreate` (no rolling update)

Save to `yaml-practice/sprint-2.yaml`.

**Memory unit reminder**: Always write `128Mi` not `128M`. `Mi` = mebibytes. `M` = megabytes (different value). The exam expects `Mi`.

---

## Block 2 — Udemy: Jobs (15 min)

Watch the **Jobs** and **CronJobs** sections. Focus on:
- Job vs. Deployment — Job runs to completion, not continuously
- `spec.completions` — total successful pod completions required (default 1)
- `spec.parallelism` — how many pods run at once (default 1)
- `restartPolicy` — must be `Never` or `OnFailure` on Job pods (not `Always`)
- CronJob's `spec.schedule` field — standard cron syntax
- How CronJob creates a Job on each trigger, Job creates a pod

---

## Block 3 — Rolling Updates Practice (20 min)

Use the `web` Deployment from Block 1, or recreate it.

Run through the full rollout workflow:

**Step 1**: Update the image to trigger a rollout
```bash
kubectl set image deployment/web nginx=nginx:1.22
```

**Step 2**: Watch it roll out
```bash
kubectl rollout status deployment/web
```

**Step 3**: Check what happened
```bash
kubectl rollout history deployment/web
```

**Step 4**: Roll back to the previous version
```bash
kubectl rollout undo deployment/web
kubectl rollout status deployment/web
kubectl get pods   # confirm pods are back on 1.21
```

**Step 5**: Scale via imperative command (not YAML edit)
```bash
kubectl scale deployment web --replicas=5
kubectl get pods   # should show 5
kubectl scale deployment web --replicas=3
```

These are the exact imperative mutations you'll use on the exam. No YAML editing needed for any of the above.

---

## Block 3b — Bad Rollout Recovery (circle back)

**Step 1**: Push a broken image to trigger a stalled rollout
```bash
kubectl set image deployment/web nginx=nginx:doesnotexist
kubectl rollout status deployment/web   # hangs — ctrl-c out
kubectl get pods                         # one pod stuck in ImagePullBackOff
```

**Step 2**: Diagnose
```bash
kubectl describe pod <stuck-pod-name>   # Events section shows the pull failure
```

**Step 3**: Recover
```bash
kubectl rollout undo deployment/web
kubectl rollout status deployment/web   # should complete cleanly
kubectl describe deployment web | grep Image   # confirm back on 1.21
```

**Also try**: `kubectl rollout undo deployment/web --to-revision=1` — rolls back to a specific revision, not just "previous". Check `kubectl rollout history deployment/web` first to see revision numbers.

**One explain to run**:
```bash
kubectl explain deployment.spec.strategy.rollingUpdate
```
Note `maxSurge` and `maxUnavailable` — both default to `25%`. You don't need to tune them for the exam, just know they exist and what they control.

---

## Block 4 — Job YAML: Scaffold + Refine (15 min)

**Study the reference Job** in `day-3-answers.md` → Block 4 first. Close it. Then write from memory.

**Rep 1**: Job named `batch-job`, image `busybox`, command `echo "done"`.
- `spec.completions: 3` (run to success 3 times)
- `spec.parallelism: 1` (one at a time)
- `restartPolicy: Never`

Save to `yaml-practice/job-1.yaml`. Apply and verify:
```bash
kubectl apply -f yaml-practice/job-1.yaml
kubectl get jobs
kubectl get pods   # watch pods complete
kubectl logs <pod-name>   # should show "done"
```

**Rep 2**: Same structure, but `completions: 4`, `parallelism: 2` (two run at once).
Save to `yaml-practice/job-2.yaml`.

Target: second rep from full memory, under 3 minutes.

---

## Block 5 — Task Interpretation + kubectl explain (10 min)

**Task interpretation** (15 seconds each — fields only, not full YAML):

**Prompt A**: "Create a Job that runs `busybox` to print the date, completing 5 times, 2 in parallel"

**Prompt B**: "Create a CronJob named `cleanup` that runs every hour, using image `busybox`, command `rm -rf /tmp/*`"

Check against `day-3-answers.md` → Block 5.

---

**kubectl explain drill** (5 min):
```bash
kubectl explain job.spec
kubectl explain job.spec.template.spec.restartPolicy
kubectl explain cronjob.spec.jobTemplate
```

No looking up syntax before trying — use explain as the lookup, not notes.

---

## Block 6 — Mixed Tasks (15 min)

3-minute skip rule applies.

### Quick (3 min)

Scale the `web` Deployment to 4 replicas. Update its image to `nginx:1.23`. Then undo the image update. All imperatively — no YAML editing.

Verify the rollback worked:
```bash
kubectl describe deployment web | grep Image
```

### Medium (8-10 min)

Create a Job named `data-load` that runs `busybox` with command `sh -c "for i in 1 2 3; do echo $i; done"`.
- `completions: 3`, `parallelism: 1`
- After it completes, check all pod logs to confirm output

Check against `day-3-answers.md` → Block 6.

---

## End-of-Session Checklist

Fill in `week-2/notes.md` Day 3 tracking:
- [x] Scaffold sprint: 2 reps with resource requests + limits, both clean?
- [x] Rolling update full workflow: set image → status → history → undo → scale
- [x] Job YAML: 2 reps — last one from full memory?
- [x] `data-load` Job completed with correct output
- [ ] Block 3b — Bad rollout recovery (circle back)
- [ ] Areas to improve: CronJob schedule syntax, `jobTemplate.metadata.name` is ignored by controller