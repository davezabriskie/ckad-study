# Week 4 — Day 1 (Sunday May 24)

**Total time**: 75 min | Services deep — all four types + apply>create intervention

> Week 4 opener and head-start session. Block 0 lands the Priority 1 carry-forward from Week 3 (zsh aliases for `apply`) and the Kustomize cold-rep that's still owed. Then Services: today is the only day this week that touches all four Service types deliberately — NodePort and ExternalName especially, since neither will come up by accident.

---

## Block 0 — Intervention + Scaffold Sprint (15 min)

### Step 1 — `kca` / `kck` aliases (one-time, ~2 min)

Add two aliases to your zsh config so the apply form is the shorter keystroke. After today, `create -f` and `create -k` should not appear in CLI history outside of dry-run scaffolds.

Check `day-1-answers.md` → Block 0 Step 1 only after you've written it from memory.

### Step 2 — Kustomize cold rep (~3 min)

Owed from Week 3 (peeked at prior files at milestone). Write a full `kustomization.yaml` cold — base form with `resources`, `namePrefix`, `labels` (modern form, not `commonLabels`), and `images`. No reference files open.

Save to `yaml-practice/kustomize-cold.yaml`. Don't apply — this is a writing rep only.

### Step 3 — Scaffold sprint (~10 min, 3 reps)

Imperative scaffolds, then one custom field added each. Save to `yaml-practice/sprint-{1,2,3}.yaml`. Apply all three using the new `kca` alias — first reps with the new muscle memory.

1. Pod `web`, image `nginx:1.21`. Add a **`tcpSocket` readinessProbe** on port 80 (covers probe-variety carry-forward).
2. Deployment `api`, image `nginx:1.21`, 3 replicas. Add resource requests (`cpu: 100m, memory: 128Mi`).
3. ClusterIP Service `api-svc` targeting `app=api` on port 80.

---

## Block 1 — Task Interpretation Drills (5 min)

15 seconds each. Name the Service type and the key field that distinguishes it. No YAML.

**Prompt A**: "Expose Deployment `cache` inside the cluster only, on port 6379."

**Prompt B**: "Expose Deployment `web` on every node at port 30080."

**Prompt C**: "Expose Deployment `api` to the public internet with a cloud load balancer."

**Prompt D**: "Create a Service `db` that resolves to `db.internal.example.com` from inside the cluster."

Check against `day-1-answers.md` → Block 1.

---

## Block 2 — Udemy: Services + service discovery (15 min)

Watch the **Services** section (ClusterIP, NodePort, LoadBalancer) and the **ExternalName** subsection if listed separately. Focus on:
- The four Service types: what each exposes and to whom
- How `selector` ties a Service to pods (and what happens when it doesn't match)
- DNS form: `<svc>.<ns>.svc.cluster.local` — and the short forms
- Endpoint mechanics: why a Service can have zero endpoints even when pods are running

---

## Block 3 — Service Type Variety (20 min)

Write all four Service types cold. The Week 4 spec calls out NodePort and ExternalName as the surprise picks — write them today so they're not first-touch at milestone.

**Rep 1 — ClusterIP**: Service `web-svc` targeting `app=web`, port 80 → targetPort 80. Imperative scaffold acceptable.

**Rep 2 — NodePort**: Service `web-np` targeting `app=web`, port 80 → targetPort 80, **nodePort 30080**. Write the YAML directly — the imperative scaffold doesn't take `--node-port`. Note where `nodePort` lives in the YAML (under each port entry, not at service level).

**Rep 3 — LoadBalancer**: Service `web-lb` targeting `app=web`, port 80 → targetPort 80. Imperative form acceptable. On a local cluster this stays Pending — that's expected. Verify the YAML shape, not the EXTERNAL-IP.

**Rep 4 — ExternalName**: Service `db-ext` that resolves to `db.internal.example.com`. No selector, no ports. Note that this is a pure DNS CNAME — no proxy, no endpoints will exist.

Save each to `yaml-practice/svc-{clusterip,nodeport,loadbalancer,externalname}.yaml`. Apply each with `kca`. After all four are applied:

```bash
kubectl get svc
kubectl get endpoints
```

Note which Services have endpoints and which don't. ExternalName won't (no selector). NodePort will (if `app=web` pods exist from Block 0 Step 3). The others depend on the selector match.

Check against `day-1-answers.md` → Block 3.

---

## Block 4 — Mixed Tasks (15 min)

3-minute skip rule. 15-second literal interpretation per task.

### Quick
Deployment `cache` already exists with label `app=cache` on port 6379. Expose it as a ClusterIP Service named `cache` (yes, same name as the Deployment — re-read literally) on port 6379.

### Medium — cross-domain (Service + ConfigMap + probe)
Scaffold a Deployment `frontend`, image `nginx:1.21`, 2 replicas, label `app=frontend`. Wire:
- A ConfigMap `frontend-cfg` with key `index.html` containing any minimal HTML, mounted at `/usr/share/nginx/html`
- A **`httpGet` readinessProbe** on `/` port 80
- Expose with a ClusterIP Service `frontend-svc` on port 80

Verify the ConfigMap content reaches the pod:
- `kubectl get endpoints frontend-svc` should list pod IPs after readiness passes
- `kubectl exec deploy/frontend -- curl -s localhost` should return the ConfigMap content

Save to `yaml-practice/frontend-{cm,deploy,svc}.yaml`. Check against `day-1-answers.md` → Block 4.

---

## Block 5 — kubectl explain drill (5 min)

No syntax lookup before trying.

```bash
kubectl explain service.spec
kubectl explain service.spec.ports
kubectl explain service.spec.type
kubectl explain endpoints
```

Note what `service.spec.type` lists as valid values. Note that `endpoints` is its own top-level resource — useful for the Week 4 debug workflow.

---

## End-of-Session Checklist

Fill in `week-4/notes.md` Day 1 tracking:
- [x] `kca` / `kck` aliases set — **but zero uses across the session**. Habit not yet reinforced; Day 2 opens with alias-use gate
- [x] Kustomize cold rep written without peeking at prior files — `images:` patch path needed a lookup; `labels:` flags missing `includeSelectors: false`
- [x] All four Service types written and applied (ClusterIP, NodePort, LoadBalancer, ExternalName)
- [x] `tcpSocket` probe used — sprint-1.yaml. Discovered `host: localhost` trap (kubelet probes from node netns); fix required `replace --force` since probes are immutable on running Pods
- [x] Block 4 medium cross-domain wired correctly — multi-doc `frontend.yaml` (CM + Deploy + Svc), curl returned ConfigMap content. Mid-stream `delete deploy` cycle worth interrogating on Day 2
- [x] `kubectl create -f` slips: 0 ✓ (apply discipline held even without the alias). `kubectl apply -f` slips vs `kca`: ~8 across blocks 0/3/4
- [x] Areas to improve logged in `notes.md`

---

## Session Learnings (May 24)

**Kustomize lookup discipline**
- No `kubectl explain kustomization`. Two substitutes:
  - kubernetes.io docs are open-tab on the exam — bookmark the Kustomize page now: `https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/`
  - `kubectl kustomize <dir>` renders merged output without touching the cluster; fast feedback during practice
- The CKAD-relevant key surface is small: `resources`, `namePrefix`/`nameSuffix`, `labels`, `images`, `patches`. Five keys. Drill the shape.

**`images:` patch shape (came up tonight)**
- `name:` matches the **base image name**, no tag. If base has `image: nginx:1.21`, match with `name: nginx`.
- `newTag: "1.22"` patches just the tag; `newName: nginx-fork` swaps the image; use both for a full swap.

**`labels:` flags — the includeSelectors trap (slipped again tonight)**
- Default `includeSelectors: true` writes labels into **Deployment `spec.selector.matchLabels`** AND **Service `spec.selector`**.
- Deployment selectors are **immutable** after creation; Service selectors are mutable. So `includeSelectors: true` works on first apply but errors on any subsequent apply where labels change.
- Default for CKAD: `includeSelectors: false, includeTemplates: true`. Survives re-apply.
- See `notes.md` → Key Concepts → "Three practical patterns" for the full mechanics.

**Question worth carrying forward**: yes, Kustomize labels CAN propagate into both pod labels AND Service selectors — that's what the two flags are for. The trap is the immutable Deployment selector, not Kustomize itself.

**Probe `host:` field trap (new tonight)**
- `host: localhost` on a `tcpSocket` probe broke readiness. Kubelet runs probes from the **node's** network namespace, not the pod's. `localhost` from the node is the node itself, which isn't serving on :80.
- Default behavior (omit `host:`) targets the **pod IP** — what you want 99% of the time.
- Rule: never set `host:` on a probe (tcpSocket or httpGet) unless you have a specific reason. Failure mode is silent — pod stays NotReady forever, no error in events.

**Probe / container spec is immutable on a running Pod**
- `kubectl apply -f` errors with `spec: Forbidden: pod updates may not change fields other than spec.containers[*].image, ...`
- Allowed mutations on a Pod: container image, initContainer image, activeDeadlineSeconds, tolerations (additions only), terminationGracePeriodSeconds.
- Everything else (probes, env, volumes, ports, resources) requires `kubectl replace --force -f <file>` or `delete pod + apply`.
- Labels on `metadata.labels` ARE mutable — separate path from spec.

**The Pod-with-no-labels visual**
- Created `web` Pod with selectors on three Services pointing at `app=web`, but Pod had no labels → all three Services had `<none>` endpoints. Live demonstration of the W3 "endpoints empty even when pods Running" debug signal. Fixed with `kubectl label pod web app=web` (or by adding labels to the YAML + `replace --force`).
- This visual is the foundation of Day 4's debug workflow. Worth keeping in mind: empty endpoints = selector mismatch OR pods NotReady. Two suspects, one symptom.

**Workflow stumbles to interrogate**
- `kca` / `kck` aliases set in Block 0 Step 1, then used **zero times** across Blocks 0, 3, 4. Aliased and not reinforced is the worst-case habit outcome. Day 2 opener: alias-use check before any apply.
- Dry-run artifacts (`strategy: {}`, `status: {}`, unused port `name:`) landed in saved YAML across Blocks 0, 3 (mostly), and 4. Now a pattern across the session, not a one-off. Day 2 opener: strip on save, make `:wq` the gate.
- Flag-guess loop on `kubectl create service clusterip` (`--tcpPorts` → `--tcpPort` → `--help` → `--tcp`). Reflex: one failed flag → `--help` immediately.

**Service type recall — all four written tonight**
- ClusterIP: default; `selector` + `ports`. Imperative scaffold works.
- NodePort: add `type: NodePort` and `nodePort: 30080` under each port entry. Imperative `kubectl create service nodeport` doesn't take `--node-port` — hand-write.
- LoadBalancer: add `type: LoadBalancer`. EXTERNAL-IP stays `<pending>` on local — that's expected; you're verifying YAML shape.
- ExternalName: `type: ExternalName`, `externalName: <fqdn>`. No selector, no ports, no endpoints. Pure DNS CNAME from CoreDNS. Real use: in-cluster name aliases an external host (RDS, SaaS API).
