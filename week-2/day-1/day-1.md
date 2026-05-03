# Week 2 — Day 1 (Saturday May 2)

**Total time**: 2 hours | Week 1 catchup: Pod Design + Services + Milestone

---

## Block 1 — Udemy: Pod Design (20 min)

Watch the **Pod Design** section. Focus on:
- Labels: key/value pairs on any resource — used for selection, filtering, grouping
- Selectors: how services and other resources filter pods by label (`kubectl get pods -l app=web`)
- Annotations: metadata not used for selection — store non-identifying info (build versions, contact info)
- How `kubectl label` and `kubectl annotate` work imperatively

Move fast — this is catch-up.

---

## Block 2 — YAML Speed Writing from Memory (20 min)

Study the references in `day-1-answers.md` → Block 2, then close it.

**Set A — Service (3 reps)**

ClusterIP service named `web-svc`:
- Selector: `app=web`
- Port 80 → targetPort 80

Target: each rep under 60 seconds. Save to `yaml-practice/svc-1.yaml`, `svc-2.yaml`, `svc-3.yaml`.

**Set B — Sidecar pod (2 reps)**

Pod named `sidecar-demo`, label `app=demo`:
- `main-app`: `nginx:1.21`, port 80
- `logger`: `busybox`, prints a log line every 10 seconds

Both containers go in `spec.containers` — not `initContainers`. Save to `yaml-practice/sidecar-1.yaml`, `sidecar-2.yaml`.

**Success metric**: All 5 reps from memory. Service under 60s each, sidecar pod under 2 min each.

---

## Block 3 — Troubleshooting (20 min)

Apply each broken manifest, diagnose the problem, fix it. Don't look at `day-1-answers.md` until you've made a genuine attempt on each.

3-minute skip rule applies — if you can't identify the issue, check the answers.

**Scenario 1 — ImagePullBackOff**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: broken-image
spec:
  containers:
  - name: app
    image: nginx:999-doesnotexist
```

Apply it. Watch it fail. Diagnose with `kubectl describe pod broken-image`. Fix it.

---

**Scenario 2 — Service with no endpoints**

Apply both:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: label-mismatch
  labels:
    app: backend
spec:
  containers:
  - name: app
    image: nginx:1.21
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mismatch-svc
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
```

Diagnose:
```bash
kubectl get endpoints mismatch-svc
kubectl describe svc mismatch-svc
kubectl get pod label-mismatch --show-labels
```

Fix the mismatch.

---

**Scenario 3 — Pod stuck in Init:0/1**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: stuck-init
spec:
  initContainers:
  - name: setup
    image: busybox
    command: ['sh', '-c', 'exit 1']
  containers:
  - name: app
    image: nginx:1.21
```

Apply it. Diagnose:
```bash
kubectl get pod stuck-init
kubectl logs stuck-init -c setup
kubectl describe pod stuck-init
```

Fix it and get the pod to Running.

---

## Block 4 — Week 1 Milestone (20 min)

**This is the real assessment. Set a timer for 20 minutes.**

Rules:
- 30-second interpretation phase before writing each task
- 3-minute skip rule — stuck with no progress → move on
- No notes. No answers file. `kubectl explain` only if you're blanking on a specific field name.

---

**Task 1 — Quick**: Create a pod named `gateway` running `nginx:1.21` with labels `app=gateway` and `env=prod`, port 80.

**Task 2 — Quick**: Create a ClusterIP service named `gateway-svc` targeting pods with `app=gateway` on port 80.

**Task 3 — Medium**: Create a pod named `twin` with two containers: `primary` running `nginx:1.21`, and `monitor` running `busybox` that prints "monitoring" every 10 seconds.

**Task 4 — Medium**: Create a pod named `staged` with an init container (`busybox`, echo "ready") before the main `nginx:1.21` container starts.

**Task 5 — Complex**: Create ConfigMap `env-cfg` with key `ENVIRONMENT=production`. Create pod `prod-app` with label `app=prod-app` that injects it as env vars. Expose with service `prod-svc` on port 80.

---

When the timer ends — stop, even mid-task.

Verify what's running:
```bash
kubectl get pods,svc
kubectl exec prod-app -- env | grep ENVIRONMENT
```

Record result in `week-1/milestone-results.md`:
- How many tasks complete?
- Total time used
- PASS (all 5 in 20 min) or FAIL

Check answers in `day-1-answers.md` → Block 4.

---

## Block 5 — Review (20 min)

Look at what didn't get done in Block 4. For each incomplete or wrong task, write one specific reason in `week-2/notes.md` → Day 1 tracking:

- Was it a YAML structure gap?
- A field name you blanked on?
- A selector/label wiring mistake?
- Ran out of time?

This directly informs what to reinforce tomorrow.

---

## End-of-Session Checklist

- [ ] Service YAML: 3 clean reps from memory
- [ ] Sidecar pod: sidecar in `spec.containers` (not `initContainers`) — 2 reps
- [ ] All 3 troubleshooting scenarios resolved
- [ ] Milestone result recorded in `week-1/milestone-results.md`
- [ ] Day 1 tracking filled in `week-2/notes.md`
