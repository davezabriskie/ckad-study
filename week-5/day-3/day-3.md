# Week 5 — Day 3 (Thursday June 4)

**Total time**: ~75 min | StatefulSets + headless service + ResourceQuota/LimitRange + downwardAPI

> The densest weekday. Block 0 carries the **full Kustomize drill** (the 3-week stumble) reference-open. Then the three from-memory shapes: StatefulSet (`serviceName` + `volumeClaimTemplates`), headless Service (`clusterIP: None`), and the ResourceQuota/LimitRange pair — including the "applies clean ≠ correct" check by actually triggering a quota rejection and a LimitRanger default. Plus the `downwardAPI` volume (the file counterpart to Day 2's `fieldRef`).

---

## Block 0 — Weekly Review + Kustomize Drill (20 min)

### Step 1 — Cold NP + Ingress quick rep (~5 min)
One NP cold (mix it up — a combined ingress+egress, or matchExpressions) + one Ingress cold. Keep the egress map-shape warm.

### Step 2 — Kustomize selector + field drill (~15 min, reference-open) — THE 3-WEEK CARRY

Small base: Deployment `web` + Service `web-svc`, shared `app: web` selector. **Render with `kubectl kustomize <dir>` before every apply.** Five reps:
1. `labels:` with `includeSelectors: false` (default) — label lands on metadata only, selectors untouched. Re-apply-safe.
2. `labels:` with `includeSelectors: true` — apply **twice**; observe `spec.selector: field is immutable` on the Deployment (the trap). Explain in one line.
3. `images:` — bump the tag via **`newTag: "1.25"`** (the field is `newTag`, not `version`/`tag`); `name:` matches the base image name (`nginx`).
4. `namePrefix:`/`nameSuffix:` + `namespace:` + `replicas:` (`- name: web` / `count: 4`) — all from the overlay, base untouched.
5. `configMapGenerator:` from literals (`LOG_LEVEL=debug`, `MAX_CONN=100`) — note the **hash suffix** kustomize appends to the rendered name.

Check against `day-3-answers.md` → Block 0.

---

## Block 1 — Udemy: StatefulSets (15 min)

Watch the **StatefulSets** section. Focus on:
- Why StatefulSet over Deployment: **stable network identity** (`<sts>-0`, `<sts>-1`, ...) + **stable per-pod storage** (`volumeClaimTemplates` creates one PVC per replica).
- `serviceName:` — the **headless** Service that gives each pod its DNS name (`<sts>-0.<svc>.<ns>.svc.cluster.local`).
- Headless Service = `clusterIP: None` (no virtual IP, no load-balancing; DNS returns the pod IPs directly).
- Ordered, graceful creation/deletion (0 before 1 before 2).

---

## Block 2 — StatefulSet + headless service from memory (20 min)

No generator — write both from memory.

**Rep 1 — headless Service.** Service `web-headless`, `clusterIP: None`, selecting `app: nginx-sts`, port 80. (Hand-write — `expose`/`create service` invent the wrong selector and won't set `clusterIP: None` cleanly.)

**Rep 2 — StatefulSet.** StatefulSet `web-sts`, 2 replicas, image `nginx:1.21`, `serviceName: web-headless`, label `app: nginx-sts`. Add a `volumeClaimTemplates` entry `www` (`ReadWriteOnce`, `1Gi`) mounted at `/usr/share/nginx/html`.

Verify:
```bash
kubectl get sts web-sts
kubectl get pods -l app=nginx-sts        # web-sts-0, web-sts-1 (ordered)
kubectl get pvc                          # www-web-sts-0, www-web-sts-1 (one per replica)
```

Save to `yaml-practice/sts-{svc,set}.yaml`. Check against `day-3-answers.md` → Block 2.

---

## Block 3 — ResourceQuota + LimitRange (15 min)

In a fresh namespace `quota-demo` (`kubectl create namespace quota-demo`, then **set the context namespace or `-n` everything** — namespace-first habit).

**Rep 1 — ResourceQuota.** Quota `compute-quota` in `quota-demo`: `requests.cpu: 1`, `requests.memory: 1Gi`, `limits.cpu: 2`, `limits.memory: 2Gi`, `pods: 4`.

**Rep 2 — observe the rejection ("applies clean ≠ correct").** Try to create a pod in `quota-demo` with **no resources block**. With a quota that constrains `requests.cpu`, the API **rejects** a pod that doesn't declare requests: `must specify requests.cpu`. Read the error.

**Rep 3 — LimitRange supplies the default.** Create LimitRange `defaults` in `quota-demo` setting `default` (limits) and `defaultRequest` per container (e.g. cpu `200m`/mem `256Mi` request, cpu `500m`/mem `512Mi` limit). Now re-create the no-resources pod — it's **admitted**, LimitRanger stamped the defaults. Confirm with `kubectl get pod <name> -o yaml | grep -A6 resources`.

> The mechanic the exam tests: a quota that requires requests + a pod with none = rejected, **unless** a LimitRange fills them in. Read it back: "the pod had no requests, but LimitRanger defaulted them, so the quota was satisfied."

Save to `yaml-practice/quota.yaml`, `yaml-practice/limitrange.yaml`. Check against `day-3-answers.md` → Block 3.

---

## Block 4 — downwardAPI volume + cross-domain (10 min)

**Rep 1 — downwardAPI volume.** Pod `meta` (`busybox`, kept alive) exposing, as **files** under `/etc/podinfo`:
- a file `name` containing the pod's own name
- a file `labels` containing the pod's labels

(downwardAPI volume — work out the `fieldPath` for each; don't peek.) Verify `kubectl exec meta -- cat /etc/podinfo/name` and `.../labels`.

> This is Day 2's `fieldRef` as files instead of env vars. Same source data, different delivery.

**Rep 2 — cross-domain (if time).** StatefulSet `cache-sts` (2 replicas, `redis:7`) + headless service `cache-headless` + a ConfigMap `cache-cfg` (`maxmemory=100mb`) injected as env. One stack, three domains.

Save to `yaml-practice/downwardapi.yaml`. Check against `day-3-answers.md` → Block 4.

---

## Block 5 — Interpretation drill (recall test, AFTER the reps) (5 min)

**Prompt A**: "A workload where each pod needs its own persistent disk and a stable DNS name."
**Prompt B**: "The Service type that gives StatefulSet pods individual DNS records."
**Prompt C**: "A pod with no resources block is rejected on create — what namespace object caused that, and what fixes it without editing the pod?"
**Prompt D**: "Expose the pod's labels to the app as files."

Check against `day-3-answers.md` → Block 5.

---

## Block 6 — kubectl explain drill (5 min)

```bash
kubectl explain statefulset.spec
kubectl explain statefulset.spec.volumeClaimTemplates
kubectl explain resourcequota.spec.hard
kubectl explain limitrange.spec.limits
kubectl explain pod.spec.volumes.downwardAPI
```

Note: `statefulset.spec.serviceName` is required; `volumeClaimTemplates` is a list of PVC specs.

---

## End-of-Session Checklist

- [ ] Kustomize drill: all 5 reps rendered before apply; trap (#2) reproduced and explained — **NOT RUN (time); carry to Day 5**
- [x] StatefulSet from memory: `serviceName` + `volumeClaimTemplates`; per-replica PVCs created ✓
- [x] Headless Service hand-written with `clusterIP: None` ✓
- [x] ResourceQuota rejection observed; LimitRange default injection confirmed ✓
- [x] downwardAPI volume exposed name + labels as files ✓ (verified via `exec`, not logs)
- [x] Namespace-first held: `quota-demo` resources in correct namespace ✓
- [x] Areas to improve logged in `notes.md`
- [ ] **Owed: Block 1 Udemy StatefulSets; Kustomize drill (Day 5); Block 5/6 drills**
