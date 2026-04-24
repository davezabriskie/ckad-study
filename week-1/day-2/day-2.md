# Week 1 — Day 2

**Total time**: 75 minutes

---

## Block 1 — Udemy Learning (30 min)

Watch the **Multi-Container Pods** section from Mumshad's CKAD course. Focus on:
- Why multiple containers in a single pod (shared lifecycle, network, storage)
- Sidecar, Init Container, Adapter, Ambassador patterns — know when to use each
- How `spec.initContainers` differs from `spec.containers`
- How containers in the same pod communicate via `localhost`

---

## Block 2 — YAML Speed Writing from Memory (15 min)

Study the two reference pods in `day-2-answers.md` → Block 2, then close it.

Write **both** from memory, back to back:
- Sidecar pod named `sidecar-demo`: main container `nginx:1.21` on port 80, sidecar `busybox` printing a log line every 10 seconds
- Init container pod named `init-demo`: init container `busybox` writes to a shared emptyDir, main container `nginx:1.21` mounts the same volume

**Target**: Complete both in under 4 minutes per rep. Do 2 full reps. Save attempts to `yaml-practice/`.

The hardest part of the init container pod: remembering `spec.initContainers` (not `spec.containers`), and wiring up the shared `volumes` entry with matching `volumeMounts` in both containers.

If you blank on a field, use `kubectl explain pod.spec.initContainers` — not your notes.

**Success metric**: 2 reps, second one from full memory with no lookups.

---

## Block 3 — Task Interpretation Drill (5 min)

Set a 15-second timer per prompt. Write down only the YAML fields you'll need — don't write full YAML.

**Prompt A**: "Create a pod named `web-logger` with a main container `web` running `nginx:1.21` on port 80 and a sidecar `logger` running `busybox` that continuously prints a log line every 5 seconds"

**Prompt B**: "Create a pod named `data-processor` where two containers share a volume: `writer` running `busybox` writes output to `/data/out`, and `reader` running `busybox` reads from `/data/out`. Use an emptyDir mounted at `/data` for both."

**Prompt C**: "Create a pod named `init-demo` that first runs an init container using `busybox` to write the string `ready` to `/work/status`, then starts a main container using `nginx:1.21` that mounts the same volume at `/usr/share/nginx/html`"

Check your field lists against `day-2-answers.md` → Block 3 when done.

---

## Block 4 — Mixed Tasks (20 min flexible window)

Apply the **3-minute skip rule**: stuck with no progress after 3 min → skip and come back.

Write the YAML yourself. Apply it. Verify it. Then check against `day-2-answers.md` → Block 4.

### Quick Task (2-3 min)

Create a pod named `limited` running `nginx:1.21` with the following resource constraints:
- Requests: 64Mi memory, 250m CPU
- Limits: 128Mi memory, 500m CPU

Verify:
```bash
kubectl get pod limited
kubectl describe pod limited | grep -A 6 Requests
```

### Complex Task — Cross-domain (8-10 min)

Create a ConfigMap named `app-config` in the default namespace with two keys:
- `APP_ENV=production`
- `LOG_LEVEL=info`

Then create a pod named `configured-app` running `nginx:1.21` that injects both values as environment variables.

Verify:
```bash
kubectl get configmap app-config
kubectl exec configured-app -- env | grep -E 'APP_ENV|LOG_LEVEL'
```

---

## Block 5 — kubectl explain Practice (5 min)

Run these and read the output carefully — this is the vocabulary you'll draw on during the exam:

```bash
kubectl explain pod.spec.containers.resources
kubectl explain pod.spec.containers.env
kubectl explain pod.spec.containers.envFrom
```

Pay attention to which fields are required vs optional, and what types they expect.

---

## End-of-Session Checklist

Fill in `week-1/notes.md` Day 2 tracking:
- [X] YAML Speed: how many clean reps in 15 min?
- [X] Interpretation Speed: avg seconds per prompt?
- [X] `limited` pod running with correct resource constraints
- [X] `app-config` ConfigMap created
- [X] `configured-app` pod showing correct env vars
- [X] Areas to improve?
