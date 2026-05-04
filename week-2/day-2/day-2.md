# Week 2 — Day 2 (Sunday May 3)

**Total time**: 2.5 hours | Week 1 close + Deployments intro

---

## Block 1 — Week 1 Close: YAML Fluency Test (30 min)

Milestone passed yesterday — finish Week 1 with a fluency check.

Write all 5 from memory, no reference, no notes. One per variation. Save to `yaml-practice/fluency-1.yaml` through `fluency-5.yaml`.

1. Basic pod — any name, `nginx:1.21`, label of your choice
2. Pod with resource requests and limits (CPU + memory)
3. Multi-container sidecar pod — two containers in `spec.containers`
4. Pod with init container
5. Pod + ConfigMap — create both; inject the ConfigMap as env vars

Grade yourself: how many required zero lookups?

Check against `day-2-answers.md` → Block 1 when done.

---

## Block 2 — Udemy: Deployments + ReplicaSets (30 min)

Watch the **Deployments** and **ReplicaSets** sections. Focus on:
- What a ReplicaSet does (maintains desired replica count) and why you almost never create one directly
- How a Deployment wraps a ReplicaSet and adds rollout management on top
- The `spec.selector.matchLabels` ↔ `spec.template.metadata.labels` relationship — these must be identical or the Deployment won't manage its pods
- Default rolling update strategy: how old pods are replaced incrementally
- `kubectl rollout` commands: `status`, `history`, `undo`

---

## Block 3 — YAML Speed Writing: Deployment (20 min)

**New resource type** — study the reference Deployment in `day-2-answers.md` → Block 3 first, then close it.

Write this from memory — 3 reps. Save to `yaml-practice/deploy-1.yaml` through `deploy-3.yaml`.

- Deployment named `web-deploy`
- 3 replicas
- Image `nginx:1.21`
- Label `app=web`
- Port 80

**The trap**: `spec.selector.matchLabels` and `spec.template.metadata.labels` must use the exact same key-value pair. If they diverge the Deployment applies but manages zero pods.

**Target**: Each rep under 3 minutes. Second rep onward from full memory.

If you blank on a field: `kubectl explain deployment.spec` — not your notes.

---

## Block 4 — Task Interpretation Drills (5 min)

15 seconds per prompt. Write the fields you'll need — not the full YAML.

**Prompt A**: "Create a Deployment named `backend` with 3 replicas running `redis:7`, labeled `app=backend`"

**Prompt B**: "Expose the `backend` Deployment so pods are reachable within the cluster on port 6379"

Note on port mapping — from yesterday's notes this was a weak spot. The format to lock in:
```yaml
ports:
- port: 80        # what the Service listens on (clients connect here)
  targetPort: 80  # what the container listens on (must match containerPort)
```
`port` and `targetPort` can differ — e.g., `port: 80, targetPort: 3000` is valid.

Check field lists against `day-2-answers.md` → Block 4.

---

## Block 5 — Mixed Tasks (30 min)

3-minute skip rule applies. Write YAML, apply, verify, then check answers.

### Quick (3-4 min)

Create a Deployment named `api` with 2 replicas running `nginx:1.21`, label `app=api`.

Verify:
```bash
kubectl get deployment api
kubectl get pods -l app=api   # should show 2 pods
```

### Medium (8-10 min)

Expose the `api` Deployment with a ClusterIP service named `api-svc` on port 80.

Then verify the service actually has endpoints (this is where label mismatches show up):
```bash
kubectl get endpoints api-svc   # should show 2 pod IPs, not <none>
kubectl describe svc api-svc    # confirm selector matches Deployment labels
```

---

## Block 6 — kubectl explain (5 min)

```bash
kubectl explain deployment.spec.selector
kubectl explain deployment.spec.strategy
kubectl explain deployment.spec.template
```

Pay attention to `strategy.type` — `RollingUpdate` is the default. The exam may ask you to set `Recreate` instead.

---

## End-of-Session Checklist

Fill in `week-2/notes.md` Day 2 tracking:
- [ ] YAML fluency test: how many of 5 required zero lookups?
- [ ] Deployment YAML: 3 reps — last one from full memory?
- [ ] `api` Deployment running with 2 pods
- [ ] `api-svc` service has endpoints (not `<none>`)
- [ ] Areas to improve?
