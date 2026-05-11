# Week 3 — Day 5 (Friday May 15)

**Total time**: 75 min | Cross-domain consolidation + Milestone Prep

> Milestone is tomorrow. Today is reps and speed across all Week 3 content. No new material.

---

## Block 0 — Scaffold + Refine Sprint (15 min)

All five resource types back to back. No notes. Timer running.

1. Deployment `frontend`, image `nginx:1.21`, 3 replicas, label `app=frontend`. Add **readinessProbe** httpGet `/` port 80 and resource requests + limits.
2. ClusterIP Service `frontend-svc` on port 80 — imperative scaffold.
3. CronJob `cleanup` that runs **at midnight every Sunday**, image `busybox`, command `echo cleanup`.
4. ConfigMap `frontend-cfg`: `THEME=dark`, `LANG=en`
5. Secret `frontend-secret`: `SESSION_KEY=abc123`

---

## Block 1 — Task Interpretation Drills (5 min)

15 seconds each.

**Prompt A**: "Create a Secret from a literal and mount it as a volume at `/etc/secrets`"

**Prompt B**: "Install a Helm chart with a custom values file and 2 replicas"

**Prompt C**: "Apply a Kustomize overlay that prefixes all resources with `test-` and patches the image to `redis:7.2`"

**Prompt D**: "Create a Deployment that mounts a ConfigMap as files AND injects a Secret key as an env var"

Check against `day-5-answers.md` → Block 1.

---

## Block 2 — Full-stack timed task (25 min)

This is Milestone Task 6 shape. Do it timed.

Create everything in `yaml-practice/full-stack.yaml`:

- ConfigMap `app-cfg`: `ENV=prod`, `LOG_LEVEL=warn`, `MAX_CONN=50`
- Secret `app-secret`: `DB_PASSWORD=hunter2`
- Deployment `app`, 2 replicas, `nginx:1.21`, label `app=app`:
  - Mount `app-cfg` as files at `/etc/config`
  - Inject `DB_PASSWORD` from `app-secret` as env var `DATABASE_PASSWORD`
  - Add **readinessProbe** httpGet `/` port 80
- ClusterIP Service `app-svc` on port 80

Verify:
```bash
kubectl exec deploy/app -- ls /etc/config
kubectl exec deploy/app -- env | grep DATABASE_PASSWORD
kubectl get endpoints app-svc
```

Check against `day-5-answers.md` → Block 2.

---

## Block 3 — Helm + Kustomize speed check (15 min)

From memory, no notes:

1. Install `bitnami/nginx` as release `test` with `replicaCount=2`
2. Upgrade it to `replicaCount=3` using `helm upgrade --install`
3. Uninstall it

Then write a minimal `kustomization.yaml` from memory that:
- Includes one resource file
- Adds `commonLabels: env=test`
- Patches image to `nginx:1.22`

---

## Block 4 — Weak spot drill (10 min)

Pick the one thing most likely to trip you tomorrow. Options based on this week:
- Volume mount wiring (`volumes` + `volumeMounts` nesting)
- Secret volume mount (`secretName` not `name`)
- Helm value override precedence
- Kustomize `images` patch syntax

Three reps of whichever trips you most.

---

## End-of-Session Checklist

- [ ] Scaffold sprint: all five clean? Probe type correct? CronJob schedule correct for midnight Sunday?
- [ ] Full-stack: volume mount + secret + probe all wired and verified?
- [ ] Helm: install/upgrade/uninstall from memory?
- [ ] Kustomize: kustomization.yaml from memory?
- [ ] Weak spot identified and drilled?
