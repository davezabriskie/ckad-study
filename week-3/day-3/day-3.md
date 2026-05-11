# Week 3 — Day 3 (Wednesday May 13)

**Total time**: 75 min | Helm

> Helm is a package manager for Kubernetes. The exam scope is consuming existing charts — not authoring. Focus on install, upgrade, value overrides, and cleanup.

---

## Block 0 — Scaffold + Refine Sprint (15 min)

1. Deployment `worker`, image `busybox`, 1 replica, label `app=worker`. Command: `sleep 3600`. Add resource requests (`cpu: 50m, memory: 32Mi`).
2. ClusterIP Service `worker-svc` on port 8080 — imperative scaffold.
3. CronJob `report` that runs **every Monday at 8am**, image `busybox`, command `echo report`.

Save to `yaml-practice/sprint-{1,2,3}.yaml`.

---

## Block 1 — Task Interpretation Drills (5 min)

15 seconds each.

**Prompt A**: "Install the bitnami/nginx chart as release `my-nginx` with 3 replicas"

**Prompt B**: "Upgrade release `my-nginx` to set replicaCount to 5 without providing a values file"

**Prompt C**: "List all installed Helm releases and show the values used for `my-nginx`"

Check against `day-3-answers.md` → Block 1.

---

## Block 2 — Udemy: Helm (20 min)

Watch the **Helm** section. Focus on:
- What a chart is — templated Kubernetes manifests
- Release — a named instance of a chart install
- `helm repo add` + `helm repo update`
- `helm install` vs `helm upgrade --install` (prefer the latter)
- Value override precedence: chart defaults → `-f values.yaml` → `--set` (last wins)
- `helm list`, `helm get values`, `helm status`
- `helm uninstall`

---

## Block 3 — Helm hands-on (30 min)

Work through the following tasks. Check against `day-3-answers.md` → Block 3 if stuck.

1. Add the bitnami repo and update it
2. Install `bitnami/nginx` as release `web` with default values. Verify pods are running.
3. Check what values `web` is using
4. Upgrade `web` to set `replicaCount=2` using `--set`. Verify replica count changed.
5. Upgrade again using `--set` to set `replicaCount=3` and add a custom label `env=prod` — try finding the right value key first with `helm show values bitnami/nginx | grep -i replica`
6. Uninstall `web`. Verify pods are gone.

---

## Block 4 — Mixed Tasks (10 min)

### Quick
Install `bitnami/nginx` as release `staging` with `replicaCount=1`. Then upgrade it to `replicaCount=2` using `helm upgrade --install` (not `helm upgrade`). What's the difference?

### Medium
Install `bitnami/nginx` as release `prod`. Override `replicaCount=3` using `--set`.
Then write a `values.yaml` file with `replicaCount=3` and update the release using `helm upgrade --install -f values.yaml` instead of `--set`. Verify the result is the same.

---

## Block 5 — kubectl explain drill (5 min)

Helm doesn't use kubectl explain, but keep the habit warm:

```bash
kubectl explain deployment.spec.replicas
kubectl explain pod.spec.containers.resources
```

Also run: `helm show values bitnami/nginx | head -40` — get comfortable reading chart defaults.

---

## End-of-Session Checklist

Fill in `week-3/notes.md` Day 3 tracking:
- [ ] Scaffold sprint clean? CronJob schedule correct for Monday 8am?
- [ ] `helm upgrade --install` vs `helm install` — difference understood?
- [ ] Value override precedence understood?
- [ ] `helm get values` vs `helm show values` — difference understood?
- [ ] Areas to improve?
