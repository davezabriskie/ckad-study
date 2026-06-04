# Week 5 — Day 2 (Wednesday June 3)

**Total time**: ~75 min | PV/PVC binding mechanics + resource requests/limits + `valueFrom` sources

> Block 0's review sprint carries the **honest cold Ingress rep** — the May 31 milestone Ingress was warm (drilled <1 hr prior). It's now been ~3 days; write it cold with **no `explain` open** as a genuine measurement (per `feedback_cold_test_validity`). Then PV↔PVC binding (static vs dynamic), the resources block proper, and the `valueFrom` sources beyond ConfigMap/Secret.

---

## Block 0 — Weekly Review Sprint (15 min)

### Step 1 — Scaffold sprint (~5 min)
Pod + Deployment + Service, one custom field each, full `apply -f`. Vary from Day 1 (e.g. a `tcpSocket` probe, a `limits` block, a NodePort).

### Step 2 — Cold Ingress (~5 min) — NO `explain`, NO peeking
Write Ingress `web-ingress` cold: host `app.local`, path `/` (Prefix) → Service `web-svc` port 80. Time it. If you stall, **note where** rather than opening `explain` — *where* you stall is the cold signal. Commit your answer, *then* check.

### Step 3 — Cold NetworkPolicy (~5 min)
One NP cold — an **ingress** rule this time (egress was Day 1): NP `allow-web-from-monitoring` selecting `app: web`, allowing ingress **only** from pods `app: monitoring` on TCP 80. The policy should govern ingress only. Read your rule back in plain English before applying.

Check against `day-2-answers.md` → Block 0.

---

## Block 1 — Udemy: Persistent Volumes (15 min)

Watch the **Persistent Volumes / Persistent Volume Claims** section. Focus on:
- The PV → PVC → Pod chain. PV is cluster storage; PVC is a namespaced request; Pod mounts the PVC.
- Binding: a PVC binds to a PV that satisfies `accessModes` + `storage` size + `storageClassName`. Dynamic provisioning creates the PV on demand.
- `persistentVolumeReclaimPolicy`: `Retain` / `Delete` (what happens to the PV when the PVC is deleted).
- Why kind binds a bare PVC instantly (the `standard` local-path provisioner) vs a static PV you write by hand.

---

## Block 2 — PV/PVC binding: static + dynamic (15 min)

**Rep 1 — dynamic + `WaitForFirstConsumer` (reinforces Day 1).** PVC `dyn-pvc`, `ReadWriteOnce`, `2Gi`, no `storageClassName`. Apply it and observe it sits **`Pending`** (no PV yet) — kind's `standard` SC defers binding until a pod consumes the claim. Then create a throwaway pod that mounts it and watch it flip to `Bound`; now inspect the provisioned PV (`kubectl get pv`).

**Rep 2 — static.** Hand-write a `hostPath` PV `manual-pv` (`2Gi`, `ReadWriteOnce`, `storageClassName: manual`, path `/tmp/manual-pv`), then a PVC `manual-pvc` requesting the same class/size. Confirm they bind to each other (not to a dynamic PV — matching `storageClassName: manual` is what pairs them).

> The pairing lever: a PVC with `storageClassName: manual` will only bind a PV with the same class — not the default provisioner. This is the classic "PVC stuck Pending" debug knob.

Save to `yaml-practice/pv-{dyn,static}.yaml`. Check against `day-2-answers.md` → Block 2.

---

## Block 3 — Resource requests/limits (15 min)

**Rep 1 — add to a Deployment.** Deployment `sizer` (`nginx:1.21`, 2 replicas) with `requests` cpu `100m`/mem `128Mi`, `limits` cpu `250m`/mem `256Mi`. Apply, then `kubectl describe` a pod to confirm.

**Rep 2 — observe a limit in action (optional, ~3 min).** Pod `stress` (`polinux/stress` or `busybox` with a memory hog) with `limits.memory: 64Mi`, requesting more than the limit at runtime → watch it get `OOMKilled` (`kubectl get pod stress -w`, then `describe` → `Last State: Terminated, Reason: OOMKilled`). If the image isn't handy, skip — the YAML shape is the point.

Save to `yaml-practice/resources-deploy.yaml`. Check against `day-2-answers.md` → Block 3.

---

## Block 4 — `valueFrom` sources beyond ConfigMap/Secret (15 min)

**Rep 1 — pod metadata as env vars (the `MY_POD_IP` drill).** Pod `whoami` (`busybox`, kept alive) exposing, as environment variables:
- `MY_POD_IP` — the pod's own IP address
- `MY_POD_NAME` — the pod's name
- `MY_NODE_NAME` — the node it's scheduled on

You'll need the **downward API** (`fieldRef`) — figure out the `fieldPath` for each (this is the skill, don't look at the answer first). Verify with `kubectl exec whoami -- printenv MY_POD_IP MY_POD_NAME MY_NODE_NAME`.

**Rep 2 — container resources as env vars.** Add to the same pod (give it a `limits`/`requests` block): env `MEM_LIMIT` exposing the container's memory limit, `CPU_REQUEST` exposing its CPU request. Confirm with `printenv`.

> Hint only: the resource-exposing source needs the container to actually declare the resource it references.

Save to `yaml-practice/valuefrom-{fieldref,resource}.yaml`. Check against `day-2-answers.md` → Block 4.

---

## Block 5 — Interpretation drill (recall test, AFTER the reps) (5 min)

15 seconds each. Name the field/mechanism. No YAML.

**Prompt A**: "A PVC is stuck `Pending` — name two things that could prevent it binding."
**Prompt B**: "Expose the pod's own IP to the app as an environment variable."
**Prompt C**: "Expose the container's memory limit to the app as an environment variable."
**Prompt D**: "Guarantee a pod gets 128Mi but never let it exceed 256Mi."

Check against `day-2-answers.md` → Block 5.

---

## Block 6 — kubectl explain drill (5 min)

```bash
kubectl explain persistentvolume.spec
kubectl explain pod.spec.containers.resources
kubectl explain pod.spec.containers.env.valueFrom
kubectl explain pod.spec.containers.env.valueFrom.fieldRef
```

Note the four `valueFrom` sources: `configMapKeyRef`, `secretKeyRef`, `fieldRef`, `resourceFieldRef`.

---

## End-of-Session Checklist

- [~] Cold Ingress — **scaffolded** (`create ingress --rule`, one-shot ✓); cold hand-write metric reframed to scaffold + hand-add `tls:`/`defaultBackend:` (Day 5)
- [x] Cold NP (ingress rule) — genuinely cold hand-written, map shape held ✓
- [x] Static PV + PVC bound by `storageClassName: manual`; dynamic PVC `WaitForFirstConsumer` → Bound with consumer pod ✓
- [x] `requests`/`limits` on Deployment confirmed via `describe`; OOMKilled demo confirmed (Exit Code 137) ✓
- [x] `fieldRef` exposed `MY_POD_IP`/`MY_POD_NAME`/`MY_NODE_NAME`/`MY_LABEL`; `resourceFieldRef` exposed `MEM_LIMIT` (bytes) + `CPU_REQUEST` (millicore truncation gotcha noted) ✓
- [x] Areas to improve logged in `notes.md`
- [ ] **Owed: Block 1 Udemy PV video (watch at work)**
