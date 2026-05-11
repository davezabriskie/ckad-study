# Week 3 — Day 4 (Thursday May 14)

**Total time**: 75 min | Kustomize

> Kustomize is built into kubectl — no install needed. The exam scope is applying overlays that patch base resources, not designing complex hierarchies.

---

## Block 0 — Scaffold + Refine Sprint (15 min)

1. Deployment `cache`, image `redis:7`, 2 replicas, label `app=cache`. Add resource requests + limits.
2. ClusterIP Service `cache-svc` on port 6379 — imperative scaffold.
3. CronJob `health-check` that runs **every 30 minutes**, image `busybox`, command `echo ok`.

Save to `yaml-practice/sprint-{1,2,3}.yaml`.

---

## Block 1 — Task Interpretation Drills (5 min)

15 seconds each.

**Prompt A**: "Apply a Kustomize overlay from `./overlays/prod` that sets `namePrefix: prod-` on all resources"

**Prompt B**: "Create a kustomization.yaml that includes two resource files and patches the image tag to `nginx:1.22`"

**Prompt C**: "Preview what Kustomize would apply without actually applying it"

Check against `day-4-answers.md` → Block 1.

---

## Block 2 — Udemy: Kustomize (15 min)

Watch the **Kustomize** section. Focus on:
- `kustomization.yaml` is the entry point — must exist in the directory
- `resources` — list of base resource files to include
- `commonLabels` — adds labels to all resources
- `namePrefix` / `nameSuffix` — prepends/appends to all resource names
- `images` — patches image name/tag without modifying base files
- `kubectl apply -k ./dir` applies the kustomization
- `kubectl diff -k ./dir` previews changes

---

## Block 3 — Kustomize practice (25 min)

Work through the following. Check against `day-4-answers.md` → Block 3 if stuck.

**Setup**: Create a base directory with a simple Deployment (`base/deployment.yaml`) for `nginx:1.21` with 2 replicas and a Service.

**Step 1**: Write `base/kustomization.yaml` that includes both files. Apply with `kubectl apply -k base/`.

**Step 2**: Create `overlays/prod/kustomization.yaml` that:
- References the base via `resources: [../../base]` (from `overlays/prod/` you go up two directories)
- Adds `commonLabels: env: prod`
- Sets `namePrefix: prod-`
- Patches the image to `nginx:1.22`

Apply the overlay: `kubectl apply -k overlays/prod/`. Verify resources are named `prod-<name>` and have the `env: prod` label.

**Step 3**: Preview without applying:
```bash
kubectl diff -k overlays/prod/
```

---

## Block 4 — Mixed Tasks (15 min)

### Quick
Create a kustomization.yaml that applies an existing Deployment YAML and adds `commonLabels: tier=frontend` to it. Apply and verify the label is on the pods.

### Medium
Take the `prod` overlay from Block 3 and add a second overlay `overlays/staging` that uses the same base but:
- `namePrefix: staging-`
- `commonLabels: env: staging`
- Image stays at `nginx:1.21` (no image patch)

Apply both overlays and verify two separate sets of resources exist.

Check against `day-4-answers.md` → Block 4.

---

## Block 5 — kubectl explain drill (5 min)

```bash
kubectl kustomize base/          # renders the kustomization without applying
kubectl kustomize overlays/prod/ # render overlay
```

Kustomize doesn't use kubectl explain — use `kubectl kustomize` to inspect rendered output instead.

---

## End-of-Session Checklist

Fill in `week-3/notes.md` Day 4 tracking:
- [ ] Scaffold sprint clean? CronJob schedule correct for every 30 minutes?
- [ ] `kustomization.yaml` structure from memory (resources, commonLabels, namePrefix, images)?
- [ ] Base + overlay pattern understood?
- [ ] `kubectl apply -k` vs `kubectl kustomize` difference understood?
- [ ] Areas to improve?
