# Week 2 — Day 3 Answers

Only open this to check your work after attempting each block.

---

## Block 1 — Sprint Reference

### Rep 1: web Deployment + probe + resources

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "64Mi"
          limits:
            cpu: "500m"
            memory: "128Mi"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
```

**Key**: `requests` and `limits` are siblings under `resources`. Both required — limits without requests is valid but wrong practice.

### Rep 2: cache Deployment + Recreate strategy

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cache
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: cache
    spec:
      containers:
      - name: cache
        image: redis:7
        resources:
          requests:
            cpu: "100m"
            memory: "64Mi"
          limits:
            cpu: "500m"
            memory: "128Mi"
```

**`strategy.type: Recreate`** — all old pods are terminated before new ones start. Downtime guaranteed. Use when your app can't run two versions simultaneously (e.g., exclusive DB migration).

---

## Block 4 — Job Reference

### Reference Job structure

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
spec:
  completions: 3
  parallelism: 1
  template:
    spec:
      containers:
      - name: batch
        image: busybox
        command: ['sh', '-c', 'echo "done"']
      restartPolicy: Never
```

**The structure to memorize**:
- `apiVersion: batch/v1` — not `apps/v1`, not `v1`
- `spec.completions` — total successful runs needed
- `spec.parallelism` — concurrent pods at a time
- `spec.template.spec.restartPolicy` — **must** be `Never` or `OnFailure`; `Always` is rejected
- No `selector` needed — Job generates its own label

**`restartPolicy: Never` vs `OnFailure`**:
- `Never`: failed pod is left in place (useful for debugging logs); new pod created on failure
- `OnFailure`: failed container is restarted in the same pod

### Rep 2: completions: 4, parallelism: 2

Same YAML, change `completions: 4` and `parallelism: 2`. Two pods run simultaneously; Job finishes after 4 total successes.

---

## Block 5 — Task Interpretation Answers

**Prompt A**: "Create a Job that runs `busybox` to print the date, completing 5 times, 2 in parallel"
- `apiVersion` → batch/v1
- `spec.completions` → 5
- `spec.parallelism` → 2
- container command → `date` (or `sh -c "date"`)
- `restartPolicy` → Never

**Prompt B**: "Create a CronJob named `cleanup` that runs every hour, image `busybox`, command `rm -rf /tmp/*`"
- `apiVersion` → batch/v1
- `kind` → CronJob
- `spec.schedule` → `"0 * * * *"` (top of every hour)
- `spec.jobTemplate.spec.template.spec.containers[0].image` → busybox
- `spec.jobTemplate.spec.template.spec.restartPolicy` → Never

**CronJob nesting**: `spec.jobTemplate` wraps the Job spec. Everything inside is a standard Job minus the `apiVersion`/`kind` headers.

---

## Block 6 — Task Answers

### Quick: rollout workflow

```bash
kubectl scale deployment web --replicas=4
kubectl set image deployment/web web=nginx:1.23
kubectl rollout undo deployment/web
kubectl describe deployment web | grep Image   # should show nginx:1.21
```

Note: `kubectl rollout undo` goes to the **previous** revision, not necessarily `1.21` if you've done multiple updates. Check `kubectl rollout history deployment/web` to see revision numbers.

### Medium: data-load Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-load
spec:
  completions: 3
  parallelism: 1
  template:
    spec:
      containers:
      - name: loader
        image: busybox
        command: ['sh', '-c', 'for i in 1 2 3; do echo $i; done']
      restartPolicy: Never
```

After completion:
```bash
kubectl get pods   # shows 3 completed pods
kubectl logs <pod-1>   # shows 1 2 3
kubectl logs <pod-2>   # shows 1 2 3
kubectl logs <pod-3>   # shows 1 2 3
```

Completed pods aren't deleted automatically — they stick around for log access until the Job TTL expires or you delete them.