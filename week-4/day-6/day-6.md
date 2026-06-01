# Week 4 — Day 6 Milestone

> **COMPLETE — Sun May 31, 2026 (same sitting as Day 5). Result: PASS 7/7, ~37 min, conditional on NetworkPolicy authoring.** Full per-task grade, faults, and carries in [`../milestone-results.md`](../milestone-results.md). Headline: connectivity debugging (T5) was the cold strength; egress NetworkPolicy authoring (T6) was the gap (collapsed cold, fixed with guidance).

**Format**: 25-minute flexible window (per `ckad-plan.md`). Seven tasks across Services & Networking (20%) + Observability (15%). This is a **test** — no answers file. Self-grade against `notes.md` and the docs after, log results to `week-4/milestone-results.md`.

> Rules: full `apply -f` / `apply -k` form (zero `create -f`/`create -k`). Read every prompt name literally — write `metadata.name` character-for-character. Strip dry-run artifacts. NetworkPolicy is hand-written (no scaffold). Start a timer; the 25 min is a target window, not a hard cutoff — record actual time.

---

## Task 1 — Quick: Service, cold (NodePort)

Create a Deployment `cache` (image `redis:7`, 2 replicas) and expose it with a **NodePort** Service named `cache-np` on port 6379, nodePort `30079`.

> Surprise-type coverage: NodePort is one of the two picks the week front-loaded. ExternalName is the alternate — if you want the harder rep, instead make an ExternalName Service `db-ext` pointing at `db.example.com`.

---

## Task 2 — Quick: Ingress, cold

Create an Ingress `shop-ingress` routing host `shop.local` path `/` (prefix) to a Service `shop-front` on port 80. Use the imperative scaffold, then confirm the path type and host by hand.

> Scaffold: `kubectl create ingress NAME --rule="host/path*=svc:port"`. The `*` makes it `Prefix`. Service `shop-front` need not exist for the Ingress to apply.

---

## Task 3 — Medium cross-domain: Deployment + ConfigMap + Service

In namespace `app`:
- ConfigMap `app-config` with `LOG_LEVEL=debug`, `MAX_CONN=100`.
- Deployment `api` (image `nginx:1.21`, 2 replicas) injecting **both** ConfigMap keys as env vars.
- ClusterIP Service `api-svc` selecting the deployment's pods on port 80.

Verify endpoints populate (2 IPs) and `printenv LOG_LEVEL MAX_CONN` inside a pod returns `debug` / `100`.

---

## Task 4 — Medium cross-domain: Deployment + `exec` probe + resources

Deployment `worker` (image `busybox`, command `sleep 3600`, 1 replica):
- An `exec` **livenessProbe** running `ls /tmp` (`periodSeconds: 10`).
- Resource `requests` cpu `100m` / memory `64Mi`, `limits` cpu `250m` / memory `128Mi`.

> Reinforces the `exec` probe closed in Day 5 and folds in the resources block.

---

## Task 5 — Complex: connectivity debug, NO hints

Apply the broken stack **without reading the manifest**:

```bash
kubectl apply -f yaml-practice/milestone-debug.yaml
```

The Service `orders` should serve traffic from a `client` pod (reuse your Day 4 `client`, or create a busybox `sleep 3600` pod). It doesn't. Walk the five-step workflow (`get endpoints` → `describe svc` → selector → READY → `exec wget`), find every fault, fix in place, confirm `exec wget orders` succeeds.

> **Two faults, different workflow branches than Day 4.** Day 4 was selector-mismatch + targetPort. These are different — the workflow will tell you where. Don't stop at the first fix.

---

## Task 6 — NetworkPolicy, cold (specific rule)

In namespace `app`, NetworkPolicy `allow-monitoring-egress`:
- Selects pods labeled `app: api`.
- Allows **egress** to pods labeled `role: metrics` in any namespace labeled `team: platform`, on TCP port 9090.
- Also allows egress to DNS (UDP 53) in `kube-system`.
- `policyTypes: [Egress]`.

> Cold, hand-written. Tests: egress `to` with combined `namespaceSelector` + `podSelector` in ONE peer (AND), the DNS exception as a SECOND peer (OR), and `policyTypes` correctness.

---

## Task 7 — Observability only: find the failing pod

Apply this, then identify *why* the pod is failing using only `kubectl get events`, `kubectl logs`, and `kubectl describe` — no editing, just diagnose and state the root cause in your results:

```bash
kubectl run probe-fail --image=nginx:1.21 --restart=Never -o yaml --dry-run=client > yaml-practice/obs-task.yaml
# then edit obs-task.yaml: add a readinessProbe httpGet on path /healthz port 8080 (nginx serves / on 80),
# apply it, and diagnose why it never becomes READY.
```

> Expected finding: readiness probe hits a path/port nginx doesn't serve → probe fails → pod stays `0/1` `Running` but NotReady. `describe pod` Events shows `Readiness probe failed`. The lesson: `Running` ≠ `Ready`.

---

## SEALED — Task 5 fault list (read ONLY after you've fixed both)

<details>

- **Fault 1 — readiness probe on the wrong port.** The Deployment's pods carry a `readinessProbe` (`httpGet` port `8080`); nginx serves on `80`. Pods run but never go `READY 1/1` → dropped from endpoints → `get endpoints orders` shows `<none>`. **This is the READY-check branch (workflow step 4)** — distinct from Day 4's label mismatch. Symptom that distinguishes it: `get pods -l app=orders --show-labels` shows the pods *and* the right labels, but `READY 0/1`. Fix: probe port → `80` (or delete the probe).
- **Fault 2 — Service port mismatch.** After the probe is fixed and endpoints populate, `wget orders` still fails: the Service `port: 80` forwards to `targetPort: 8080`, but the container listens on `80`. Fix: `targetPort` → `80`.

Both fixed → `kubectl exec client -- wget -qO- --timeout=2 orders` returns the nginx page.

</details>

---

## After the milestone

Log to `week-4/milestone-results.md`: time taken, per-task pass/fail, faults you missed, any `create -f`/name slips. Then `notes.md` Day 6 + Week 4 wrap.
