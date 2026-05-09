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

### Blue/Green + Canary
- **Blue/green**: two Deployments share `app` label, differentiated by `version` label; Service selector switches between them via `kubectl patch`
- Service selector must include BOTH `app` and `version` — selecting only `version` is too loose
- `strategy: Recreate` is wrong for blue/green — use default `RollingUpdate` so each Deployment stays healthy
- **Canary**: stable + canary share same `app` label; Service selects shared label; traffic split by replica ratio
- Promote canary: scale stable to 0, scale canary up

### ConfigMaps
- Key/value store decoupled from the pod — change config without rebuilding images
- `envFrom` + `configMapRef` — inject all keys; env var names come from ConfigMap keys
- `env` + `valueFrom.configMapKeyRef` — inject one key; you control the env var name
- `restartPolicy: Never` is NOT valid on init containers — `restartPolicy` is a pod-level field, not per-container
- Exception: K8s 1.28+ allows `restartPolicy: Always` on init containers to make them sidecars — `Never` is still invalid
- `$(VAR_NAME)` in an env `value` field references another env var in the same container spec (dependent variable substitution)
- Verify injection: `kubectl exec deploy/<name> -- env | grep KEY`
- `kubectl explain` path: `pod.spec.containers.envFrom.configMapRef` (note: no "Key" in name)
- Easy mixup: `configMapRef` (envFrom) vs `configMapKeyRef` (valueFrom) — different field names

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

# ConfigMap
kubectl create configmap app-cfg --from-literal=ENV=prod --from-literal=LOG_LEVEL=warn
kubectl describe configmap app-cfg

# Blue/green traffic switch
kubectl patch service web-svc -p '{"spec":{"selector":{"version":"v2"}}}'
kubectl get endpoints web-svc

# Debug no-endpoints
kubectl get pods --show-labels
kubectl describe service <name>
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
- Blocks completed: 0 (scaffold sprint), 1 (blue/green), 3/4 (ConfigMaps — no Udemy access, used kubectl explain instead)
- Scaffold sprint: Deployment + readinessProbe clean, Job clean
- Blue/green: built and wired; debugged empty endpoints (version selector mismatch) — resolved
- ConfigMaps: configmap-1.yaml clean, envFrom (app.yaml) and valueFrom (app-log-only.yaml) both working
- Areas to improve:
  - `configMapRef` vs `configMapKeyRef` naming — easy to mix under pressure
  - `restartPolicy: Never` not valid on init containers
  - Service selector needs both `app` + `version` keys, not just `version`
  - Scaffold noise (`strategy: {}`, `resources: {}`, `status: {}`) — strip before applying

### Day 5 (Friday May 8)
- Blocks completed: 0 (scaffold sprint), 1 (full-stack ConfigMap+Deployment+Service), 2 (rollout/rollback), extra ConfigMap + CronJob reps
- Scaffold sprint: all three resource types clean
- Full-stack: ConfigMap + Deployment (envFrom) + Service wired and env vars verified
- Extra reps: envFrom, valueFrom (with rename + dependent variable substitution), CronJob — all clean
- CronJob notably cleaner than Day 3 — schedule syntax correct
- Areas to improve:
  - `restartPolicy: Never` on init containers keeps appearing — pod-level only, remove it

### Day 6 (Saturday May 9) — Milestone
- Milestone Result: PASS / FAIL
- Tasks Completed: ____/5
- Total Time: _____ min
- Areas to improve:
