# Week 4 — Day 4 (Friday May 29)

**Total time**: ~80 min | Connectivity debugging workflow + cross-domain stack

> Schedule slipped one day — the plan slotted this for Thursday May 28; running it Friday. Day 4 is the **debugging** day. Days 1–3 built the resources (Services, Ingress, NetworkPolicy, observability commands). Today you wire them into a stack, deliberately break it, and walk the fault-isolation workflow with no hints. The new skill is the **workflow**, not new YAML: `get endpoints` → `describe svc` → selector check → READY check → `exec curl`. One cross-domain stack (NP + Deployment + Service + ConfigMap) anchors it, with one more `matchExpressions` rep folded in.

---

## Day 4 Opener (2 min, before any block)

- [ ] **Literal prompt names — now the 5th W4 slip and load-bearing.** Day 3 rep 2 was `all-server-egress-dns-only` vs the prompt's `allow-…`. The grader is mechanical: `metadata.name` must match the prompt character-for-character, hyphens and all. 15-sec interpretation pass on every named resource today.
- [ ] **`-f` takes a file, `-k` takes a directory.** Resurfaced Day 3 Block 0, same as W3 milestone Task 5. Say it before you type it.
- [ ] **Full `apply` form, zero `create -f`/`create -k`.** This is the Days 3–6 success metric. `kubectl apply -f <file>`.
- [ ] **Strip dry-run artifacts on `:wq`** — `status: {}`, `creationTimestamp: null`, `strategy: {}`, the empty `resources: {}`.
- [ ] **NetworkPolicy peer selectors match POD labels, never Service labels.** Day 3 cross-NS PoC slip. A Service's `metadata.labels` are irrelevant to NP matching.

---

## Block 1 — Udemy NetworkPolicy section (owed from Day 3, ~15 min)

Day 3 Block 2 was a text TL;DW because Udemy access was down Wednesday night. If access is back, watch the NetworkPolicy section + lab solutions now, before today's NP rep in Block 4. Compare the lab's solution shape against the three reps you wrote Day 3 (`day-3/yaml-practice/np-{1,2,3}*.yaml`).

If access is still down: skip to Block 2. The Day 3 text overview (`day-3.md` → Block 2) covered the load-bearing points — default-allow, isolation trigger, `policyTypes` required, AND-vs-OR peer semantics, DNS exception, kindnet non-enforcement. Note the skip in the end-of-session checklist.

---

## Block 2 — Connectivity Debugging Workflow (20 min)

The core new skill. First walk it on a **healthy** stack so the "good" output is in your head — then Block 3 breaks it and you spot the deviation.

### Build a healthy stack (~3 min)

Hand-build or scaffold a Deployment `web` (image `nginx:1.21`, 2 replicas, pod label `app: web`) and a ClusterIP Service `web-svc` selecting `app: web` on port 80. Plus a `client` pod (`busybox`, `sleep 3600`) for `curl`/`wget` testing. Scaffold commands in `day-4-answers.md` → Block 2.

### The five-step workflow

Run each against the healthy stack and read the expected "good" output:

```bash
# 1. Endpoints — the single fastest signal. Populated = service found ready pods.
kubectl get endpoints web-svc
#    GOOD: web-svc   10.244.x.x:80,10.244.y.y:80   (one IP:port per ready pod)
#    BAD:  web-svc   <none>                         (no ready pods match the selector)

# 2. Describe the service — read Selector and Endpoints together.
kubectl describe svc web-svc
#    Selector:  app=web         <- must match the pods' labels
#    Endpoints: 10.244.x.x:80   <- mirrors step 1

# 3. Pod selector check — do the pods actually carry the label the svc selects?
kubectl get pods --show-labels -l app=web
#    Compare the label set against the Selector from step 2.

# 4. READY check — a pod can match the selector but still be excluded if not Ready.
kubectl get pods -l app=web
#    READY 1/1 = in endpoints.  READY 0/1 = failing probe, dropped from endpoints.

# 5. Exec curl — prove reachability from inside the cluster.
kubectl exec client -- wget -qO- --timeout=2 web-svc
#    (busybox has wget, not curl. nginx default page = success.)
#    DNS form: web-svc.<namespace>.svc.cluster.local
```

> **The decision tree this encodes:** empty endpoints → the problem is *selection* (step 3 selector mismatch) or *readiness* (step 4 probe). Endpoints present but `exec` fails → the problem is *port/targetPort* or a NetworkPolicy gating the path. `exec` fails with "bad address" → DNS, not connectivity (no such Service) — Day 3 lesson: NP blocks time out, they don't return address errors.

---

## Block 3 — Break/Fix, No Hints (15 min)

`day-4-answers.md` → Block 3 has a **setup script**. Apply it **without reading past the apply command** — the faults are deliberate and reading them defeats the drill. Then debug live using only the Block 2 workflow.

```bash
# from day-4/ — apply the broken stack WITHOUT inspecting the manifest
kubectl apply -f yaml-practice/broken-stack.yaml   # (you'll create this from answers Block 3)
```

Then: the Service `shop-api` should serve traffic from `client`, but `wget` hangs/fails. Walk the five steps. Find each fault, fix it in place (`kubectl edit` or patch), confirm endpoints populate and `exec wget` succeeds.

There are **two** independent faults stacked. Log what each step told you and which fault it isolated. Self-check (the fault list + fixes) is in `day-4-answers.md` → Block 3 — only open it AFTER you've found and fixed both, to grade yourself.

---

## Block 4 — Cross-Domain Stack (20 min)

One isolated app stack, four resources, reference-open (`day-4-answers.md` → Block 4) — build the shape, don't peek-and-copy blindly. Read each prompt name literally.

Namespace `shop` (create it first). In it:

1. **ConfigMap `shop-config`** — keys: `APP_COLOR=blue`, `APP_MODE=prod`.
2. **Deployment `shop-backend`** — image `nginx:1.21`, 2 replicas, pod labels `app: shop-backend`, `tier: backend`. Inject both ConfigMap keys as env vars via `envFrom`.
3. **Service `shop-backend-svc`** — ClusterIP, selects `app: shop-backend`, port 80.
4. **NetworkPolicy `allow-frontend-or-worker-to-backend`** — selects pods `tier: backend`; allows ingress from pods whose `role` label is **`In` (`frontend`, `worker`)** via `matchExpressions`; `policyTypes: [Ingress]`.

> The NP rep is the W4 set-based-selector carry for this session — `matchExpressions`, not `matchLabels`. Note the name has `allow-` (not `all-`) — the exact slip from Day 3.

Verify:

```bash
kubectl -n shop get cm,deploy,svc,netpol
kubectl -n shop get endpoints shop-backend-svc          # should list 2 pod IPs
kubectl -n shop exec deploy/shop-backend -- printenv APP_COLOR APP_MODE   # blue / prod
kubectl -n shop describe netpol allow-frontend-or-worker-to-backend
```

---

## Block 5 — Interpretation Drills as Recall Test (5 min)

> Per the ordering rule: drills run **after** the day's reps, as a calibration check on what stuck — not as priming before. 15 sec each. Name the YAML shape / the debug step, don't write full manifests.

**Prompt A** (debug): "A Service has running pods but `kubectl get endpoints` shows `<none>`. Name the two most likely causes and the command that distinguishes them."

**Prompt B** (debug): "`exec wget <svc>` returns 'bad address' immediately. Is this a NetworkPolicy block? What is it?"

**Prompt C** (NP): "Allow ingress to `tier: backend` from pods labeled `role=frontend` OR `role=worker`. matchLabels or matchExpressions?"

**Prompt D** (debug): "Endpoints are populated and DNS resolves, but `exec wget` hangs until timeout. Two candidate causes."

**Prompt E** (cross-domain): "A Deployment needs `APP_MODE` from a ConfigMap as an env var. Name the two field shapes that do this and when you'd pick each."

Check against `day-4-answers.md` → Block 5.

---

## End-of-Session Checklist

Fill in `week-4/notes.md` Day 4 tracking:
- [ ] Udemy NetworkPolicy section watched — **NOT done** (jumped to metrics-server + Block 2); owed to Day 5
- [x] Five-step debug workflow run on a healthy stack — "good" output internalized
- [x] Break/fix: both faults found and fixed using only the workflow, no peeking — selector (A) + targetPort (B), walked the full workflow, didn't stop early
- [x] Cross-domain stack built — CM `envFrom`, Deployment, Service endpoints populated (2 IPs), NP with `matchExpressions`
- [x] `matchExpressions` used — `describe` confirmed `role in (frontend,worker)`; closes the W4 set-based carry
- [ ] Literal prompt names — **slipped**: `shop-svc` typed ×2 in exec tests (svc is `shop-api`). Logged; Day 5 forced rep earned
- [x] Zero `create -f` / `create -k` — full `apply` form throughout (`create service`/`create deployment` generators used, then `apply -f`)
- [ ] Probe-variety check — only `tcpSocket` this week (Day 3). **No `exec` probe yet** → flagged for Day 5
- [ ] Block 5 interpretation drills — **NOT done** (called session after Block 4); deferred to Day 5 as cold recall
- [x] Areas to improve logged in `notes.md` Day 4

**Bonus closed Day 3 gap**: metrics-server installed on kind (`--kubelet-insecure-tls` patch) — `kubectl top` now returns numbers.
