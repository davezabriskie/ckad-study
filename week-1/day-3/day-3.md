# Week 1 — Day 3 (Expedited: Thursday + Friday)

**Total time**: 90 minutes | Covers missed Thursday content + Friday content

---

## Block 1 — Udemy (25 min)

Two sections, move fast — you're catching up:
- **Multi-Container Pods**: sidecar, init container patterns
- **Pod Design**: labels, selectors, annotations

Don't rewatch anything from Day 1.

---

## Block 2 — YAML Speed Writing from Memory (15 min)

Three reps each. No notes. Save attempts to `yaml-practice/`.

**Rep set A** — Multi-container pod with init container:
- Pod named `init-app`
- Init container: `busybox` that echoes "init complete"
- Main container: `nginx:1.21`

**Rep set B** — Service:
- Service named `web-svc`
- Selects pods with label `app=web`
- Port 80 → targetPort 80
- Type: ClusterIP

Check against `day-3-answers.md` → Block 2 when done.

---

## Block 3 — Task Interpretation Drill (5 min)

15 seconds per prompt. Write the fields only, not the YAML.

**Prompt A**: "Create a pod named `worker` running `busybox` with resource requests of 100m CPU and 64Mi memory, and limits of 200m CPU and 128Mi memory"

**Prompt B**: "Create a pod named `log-app` with a sidecar that shares a volume — the main container writes to `/data/out.txt` every 5 seconds, the sidecar tails that file"

Check field lists against `day-3-answers.md` → Block 3.

---

## Block 4 — Mixed Tasks (40 min flexible window)

3-minute skip rule applies to every task.

### Quick (2-3 min): Pod with resource limits

Create a pod named `limited` running `nginx:1.21` with:
- CPU request: `100m`, limit: `200m`
- Memory request: `64Mi`, limit: `128Mi`

Verify: `kubectl describe pod limited | grep -A 5 Limits`

### Quick (2-3 min): Pod with init container

Create a pod named `init-app` where:
- Init container named `setup` runs `busybox` and executes: `echo "ready" > /tmp/status`
- Main container named `app` runs `nginx:1.21`

Verify: `kubectl get pod init-app` (watch it go Init → Running)

### Medium (6-8 min): Multi-container with shared volume

Create a pod named `log-pipe` with two containers sharing a volume:
- `writer`: busybox, writes the current date to `/data/log.txt` every 5 seconds
- `reader`: busybox, tails `/data/log.txt`
- Volume: `emptyDir` mounted at `/data` in both containers

Verify:
```bash
kubectl logs log-pipe -c reader
```

### Cross-domain (8-10 min): Pod + ConfigMap + Service

1. Create a ConfigMap named `site-config` with keys: `APP_ENV=production`, `LOG_LEVEL=info`
2. Create a pod named `web` running `nginx:1.21` with label `app=web`, injecting the ConfigMap as env vars
3. Expose it with a ClusterIP service named `web-svc` on port 80

Verify:
```bash
kubectl exec web -- env | grep APP_ENV
kubectl get svc web-svc
```

---

## Block 5 — kubectl explain (5 min)

```bash
kubectl explain pod.spec.initContainers
kubectl explain pod.spec.containers.resources
kubectl explain pod.spec.volumes
```

---

## End-of-Session Checklist

- [ ] `limited` pod running with correct resource limits
- [ ] `init-app` pod reached Running (not stuck in Init)
- [ ] `log-pipe` reader logs showing date output
- [ ] `web-svc` service exists and selects `web` pod correctly
- [ ] Update `week-1/notes.md` Day 3 tracking
