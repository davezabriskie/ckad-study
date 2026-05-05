# Week 2 Study Notes

## Key Concepts

### Labels, Selectors, Annotations
- **Labels**: key/value pairs on any resource — used for selection and filtering
- **Selectors**: filter resources by label (`kubectl get pods -l app=web`)
- **Annotations**: metadata not used for selection — store non-identifying info
- Service `selector` must exactly match pod `labels` — most common wiring bug

### Deployments
- Wraps a pod template in a controller that manages replicas and rollouts
- `spec.selector.matchLabels` and `spec.template.metadata.labels` must be identical
- Rolling update is the default strategy — zero downtime by default

### Jobs + CronJobs
- **Job**: runs a pod to completion (once, or N times via `spec.completions`)
- **CronJob**: schedules a Job on a cron schedule via `spec.schedule`
- Job pods don't restart on success — `restartPolicy: Never` or `OnFailure`
- `restartPolicy: Never` = new pod on failure; `OnFailure` = restart container in-place on same pod
- `parallelism` is silently capped at `completions` — setting it higher is harmless but misleading
- `jobTemplate.metadata.name` in a CronJob is ignored — controller auto-generates job names per trigger
- CronJob schedule: `0 * * * *` = every hour, `0 0 * * *` = midnight daily
- Update CronJob schedule: `kubectl patch cronjob <name> -p '{"spec":{"schedule":"..."}}'` or `kubectl edit`
- Set rollout change-cause: `kubectl annotate deployment/<name> kubernetes.io/change-cause="message"`

## kubectl Commands for Week 2

```bash
# Deployment management
kubectl create deployment web --image=nginx:1.21 --replicas=3
kubectl scale deployment web --replicas=5
kubectl set image deployment/web nginx=nginx:1.22
kubectl rollout status deployment/web
kubectl rollout history deployment/web
kubectl rollout undo deployment/web

# Job / CronJob
kubectl create job batch --image=busybox -- echo done
kubectl get jobs
kubectl get cronjobs
```

## Daily Progress Tracking

### Day 1 (Saturday May 2) — Week 1 Catchup
- YAML Speed (Service): 6/6 reps clean
- YAML Speed (Sidecar): 5/5 reps clean
- Troubleshooting: 3/3 scenarios resolved
- Milestone: PASS 
- Areas to improve:
  - ConfigMap
  - Port mapping
  - Service specifics (kept forgetting ports format)

### Day 2 (Sunday May 3)
- YAML Speed: 3/3 Deployment reps clean, 5/5 fluency reps
- Tasks Completed: 2/2 (quick Deployment + medium Service)
- Areas to improve:
  - Resource requests missing from limits-only pod (fluency-2)
  - Memory units: use Mi not M
  - ReplicaSet adoption of orphaned pods — Deployments don't co-opt pre-existing pods, only RS can adopt orphans and it's unreliable

### Day 3 (Monday May 4)
- YAML Speed: sprint-1 (Deployment + probe) clean, sprint-2 (Deployment + Recreate) clean
- Tasks Completed: block4 (3 Job reps), block5 (CronJob), block6 (data-load Job)
- Areas to improve:
  - CronJob schedule syntax — wrote `0 0 * * *` (daily) instead of `0 * * * *` (hourly)
  - `jobTemplate.metadata.name` is ignored by CronJob controller — don't set it
  - `parallelism > completions` is silently capped — semantically wrong even if it works
  - Block 3b (bad rollout recovery) deferred — circle back

### Day 4 (Tuesday May 5)
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:

### Day 5 (Wednesday May 6)
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:

### Day 6 (Saturday May 9) — Milestone
- Milestone Result: PASS / FAIL
- Tasks Completed: ____/5
- Total Time: _____ min
- Areas to improve:
