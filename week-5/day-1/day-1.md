# Week 5 — Day 1 (Tuesday June 2)

**Total time**: ~75 min | Volumes intro (emptyDir + PVC basics) + NetworkPolicy egress remediation

> Week 5 opener, run on what's normally a rest day to recover the W4 slip. Block 0 front-loads the **#1 carry**: cold egress NetworkPolicy authoring, which collapsed at the W4 milestone. Then the storage on-ramp — `emptyDir` (pod-lifetime scratch) and the first PVC scaffold-from-memory. Net-new domain, so keep the reference open while building the shapes (cold reps come later in the week).

> **kind reminders**: NP on kindnet (Calico was installed this session but removed Day 2 after BIRD crash — back on kindnet). PVCs use the `standard` SC with **`WaitForFirstConsumer`** — a bare PVC stays `Pending` until a pod mounts it. Adding a volume to a *running Pod* is immutable — `replace --force` or use a Deployment.

---

## Block 0 — Weekly Review Sprint + NP Egress Remediation (20 min)

### Step 1 — Mixed scaffold sprint (~5 min, 3 reps)

Imperative scaffolds + one custom field each. Save to `yaml-practice/sprint-{1,2,3}.yaml`, apply with the full `kubectl apply -f` form.
1. Pod `web`, image `nginx:1.21`. Add a `httpGet` readinessProbe on `/` port 80.
2. Deployment `api`, image `nginx:1.21`, 2 replicas. Add `resources.requests` (`cpu: 100m`, `memory: 128Mi`).
3. ClusterIP Service `api-svc` selecting `app=api`, port 80.

> Spot-check: every `create` flag is `=` not `:`. Strip `status: {}` / `strategy: {}` on save.

### Step 2 — Cold egress NetworkPolicy reps (~12 min, 3 reps) — THE #1 CARRY

Hand-written, **reference-open is fine for shape today** (cold test comes later in the week), but write `spec` as a **map** and say each rule back in plain English before applying. Calico enforces NP here — verify with `kubectl describe netpol <name>` (and optionally traffic-test).

**Rep 1 — egress to a labeled pod set, same namespace.** NetworkPolicy `egress-to-db` selecting pods `app: api`; allow **egress** to pods `app: db` on TCP 5432. `policyTypes: [Egress]`.

**Rep 2 — egress to a pod set in a specific namespace (the AND peer).** NetworkPolicy `egress-to-metrics` selecting `app: api`; allow egress to pods `role: metrics` **in** namespaces labeled `team: platform`, on TCP 9090. The namespaceSelector + podSelector go under **one** `-` peer (AND). `policyTypes: [Egress]`.

**Rep 3 — combined peer AND a DNS exception (the AND + OR rep, mirrors the milestone collapse).** NetworkPolicy `egress-locked` selecting `app: api`; allow egress to `role: metrics` pods in `team: platform` namespaces on TCP 9090 (one peer, AND), **and** to DNS in `kube-system` on UDP 53 (a SECOND peer, OR). `policyTypes: [Egress]`.

> The exact W4 failure: `spec` written as a list; combined selectors written as two `-` peers (OR) when one was needed (AND). Get the map shape and the one-peer-AND automatic.

Check against `day-1-answers.md` → Block 0.

---

## Block 1 — Udemy: Volumes (15 min)

Watch the **Volumes** section. Focus on:
- `emptyDir` — pod-lifetime scratch, shared between containers in the same pod; `medium: Memory` for a tmpfs.
- The volume/volumeMount pairing: a `volumes:` entry (pod-level) + a `volumeMounts:` entry (container-level) referencing it by name.
- PV vs PVC: the PV is the storage, the PVC is the claim; the pod references the **PVC**, never the PV directly.
- `accessModes`, `storageClassName`, and how dynamic provisioning binds a PVC without a pre-made PV.

---

## Block 2 — emptyDir reps (15 min)

**Rep 1 — shared scratch.** Pod `scratch` with two containers (`writer` + `reader`, both `busybox`, `command` keeping them alive) sharing an `emptyDir` mounted at `/data` in both. `writer` writes a file; `exec` into `reader` and read it back.

> `command` is argv — no `sh -c` unless you need shell features. To keep busybox alive: `["sleep","3600"]`.

**Rep 2 — memory-backed.** Pod `mem-scratch`, one `busybox` container, `emptyDir` with `medium: Memory` mounted at `/cache`. Confirm the mount is a tmpfs (`exec ... -- df -h /cache` or `mount | grep cache`).

Save to `yaml-practice/emptydir-{shared,mem}.yaml`. Check against `day-1-answers.md` → Block 2.

---

## Block 3 — PVC scaffold-from-memory + mount (15 min)

No generator for PVC — write it from memory.

**Rep 1 — PVC.** PersistentVolumeClaim `data-pvc`, `accessModes: [ReadWriteOnce]`, request `1Gi`. Omit `storageClassName` (let it default to `standard`). Apply and confirm it reaches **Bound** (kind auto-provisions).

**Rep 2 — mount it into a pod.** Pod `data-pod` (`nginx:1.21`) mounting `data-pvc` at `/usr/share/nginx/html`. `exec` in and write an `index.html`; confirm `curl localhost` serves it.

> Reminder: the pod references the **PVC** by name under `volumes.persistentVolumeClaim.claimName`, not the PV.

Save to `yaml-practice/pvc-{claim,pod}.yaml`. Check against `day-1-answers.md` → Block 3.

---

## Block 4 — Cross-domain: pod + emptyDir + resource limits (10 min)

3-minute skip rule. 15-second literal name read.

Pod `buffer` (`busybox`, kept alive), with:
- An `emptyDir` mounted at `/buffer`.
- `resources.requests` cpu `50m` / memory `32Mi`, `limits` cpu `100m` / memory `64Mi`.

Verify the volume mount (`exec ... -- touch /buffer/x`) and the limits (`kubectl describe pod buffer` → Limits/Requests).

Save to `yaml-practice/buffer.yaml`. Check against `day-1-answers.md` → Block 4.

---

## Block 5 — Interpretation drill (recall test, AFTER the reps) (5 min)

15 seconds each. Name the volume type and the one field that defines it. No YAML.

**Prompt A**: "Scratch space shared between two containers in a pod, gone when the pod dies."
**Prompt B**: "Scratch space backed by RAM, not disk."
**Prompt C**: "Storage that survives the pod being deleted and recreated."
**Prompt D**: "The object a pod references to consume persistent storage (not the storage itself)."

Check against `day-1-answers.md` → Block 5.

---

## Block 6 — kubectl explain drill (5 min)

No syntax lookup before trying.

```bash
kubectl explain pod.spec.volumes
kubectl explain pod.spec.volumes.emptyDir
kubectl explain persistentvolumeclaim.spec
kubectl explain pod.spec.containers.volumeMounts
```

Note: `persistentvolumeclaim.spec.accessModes` valid values; `emptyDir.medium` (only `""` or `Memory`).

---

## End-of-Session Checklist

Fill in `week-5/notes.md` Day 1 tracking:
- [x] 3 cold egress NP reps written — `spec` as a map ✓, one-peer-AND in reps 2/3 ✓, OR DNS exception in rep 3 ✓ (**#1 W4 carry resolved**)
- [x] Said each NP rule back in plain English — caught the `name` vs `kubernetes.io/metadata.name` bug this way ("applies clean ≠ correct")
- [x] `emptyDir` (shared + memory-backed) both mounted and verified
- [x] PVC written from memory, mounted into a pod — `Bound` after fixing the deleted local-path provisioner (two free debug reps)
- [x] Cross-domain `buffer` pod: emptyDir + resource limits both verified
- [~] `sh -c` wraps — one slip on mem-scratch (4th occurrence), **corrected** to bare argv on `buffer` same session
- [x] Areas to improve logged in `notes.md`
- [ ] **Owed: Block 1 Udemy Volumes video; Block 5 interpretation drill (fold into Day 2)**
