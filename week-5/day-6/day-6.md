# Week 5 — Day 6 Milestone (Sunday June 7)

**Format**: 30-minute flexible window (per `ckad-plan.md`). Six tasks across Application Design and Build (20%) + Application Environment, Configuration and Security (25%). This is a **test** — no answers file. Self-grade against `notes.md` + the Day 1–5 answers + the docs after, log results to `week-5/milestone-results.md`.

> **Rules**: full `apply -f` / `apply -k` form (zero `create -f` / `create -k`). Read every prompt name literally — write `metadata.name` character-for-character. Strip dry-run artifacts. PVC / StatefulSet / headless Service / ResourceQuota / LimitRange are hand-written (no scaffold). **Namespace-first**: stamp `-n <ns>` before the first apply. Start a timer; 30 min is the target window, not a hard cutoff — record actual time.

> **The two carried metrics ride on this milestone**: write the egress NetworkPolicy and the Ingress *cold, no `explain`* if either appears, and self-check by reading the rule back in plain English ("applies clean ≠ correct").

---

## Task 1 — Quick: PVC scaffold + mount

Create a PVC `web-data` (`ReadWriteOnce`, `1Gi`, default storageClass) and a Pod `web-store` (`nginx:1.21`) mounting it at `/usr/share/nginx/html`. Confirm the PVC is `Bound` and the mount works (`exec` write + `curl localhost`).

---

## Task 2 — Quick: resource limits on a Deployment

Deployment `limited` (`nginx:1.21`, 2 replicas) with `requests` cpu `100m` / memory `128Mi` and `limits` cpu `250m` / memory `256Mi`. Confirm via `kubectl describe`.

---

## Task 3 — Ephemeral volume

Pod `field-info` (`busybox`, kept alive — bare `command` argv) exposing **its own labels** as files via a `downwardAPI` volume at `/etc/podinfo`, and **its pod IP** as env `MY_POD_IP` via `fieldRef`. Verify both (`cat /etc/podinfo/labels`, `printenv MY_POD_IP`).

> Covers both downward delivery paths — volume (files) and env (`fieldRef`) — in one pod.

---

## Task 4 — Medium cross-domain: ConfigMap + emptyDir + resources

In namespace `app5` (namespace-first): a Pod `cache-node` (`redis:7`) with:
- A ConfigMap `cache-conf` (`MAXMEM=128mb`) injected as env var `MAXMEM`.
- A memory-backed `emptyDir` (`medium: Memory`) mounted at `/cache`.
- `requests` cpu `100m` / memory `128Mi`, `limits` cpu `200m` / memory `256Mi`.

Verify: `printenv MAXMEM`, the tmpfs mount, and the limits in `describe`.

---

## Task 5 — Complex: stateful app with resource constraints

In namespace `app5`: a ResourceQuota `app5-quota` (`requests.cpu: 1`, `requests.memory: 1Gi`, `pods: 5`) + a LimitRange `app5-limits` (sensible container defaults), then a StatefulSet `store` (2 replicas, `nginx:1.21`, `serviceName: store-headless`) with a hand-written headless Service `store-headless` (`clusterIP: None`) and a `volumeClaimTemplates` `data` (`ReadWriteOnce`, `1Gi`) at `/usr/share/nginx/html`.

Verify: `store-0`/`store-1` running, per-replica PVCs (`data-store-0`, `data-store-1`), quota usage (`describe quota`). The StatefulSet pods declare no resources — they must be admitted via the LimitRange defaults (read it back: did the quota count the defaulted requests?).

---

## Task 6 — Image: modify Dockerfile + rebuild + run

Apply the provided Dockerfile blind:

```bash
mkdir -p yaml-practice/milestone-img
cat > yaml-practice/milestone-img/Dockerfile <<'EOF'
FROM busybox:1.34
ENTRYPOINT ["echo", "v1"]
EOF
```

Modify it to: base `busybox:1.36`, and an `ENTRYPOINT` that prints `hostname` then sleeps forever (`["sh","-c","hostname; sleep infinity"]`). Build as `mile-app:v2`, `kind load`, and run in a Pod `mile-pod` with the correct tag + `imagePullPolicy`. Confirm `kubectl logs mile-pod` shows the hostname (no `ErrImagePull`).

---

## After the milestone

Log to `week-5/milestone-results.md`: time taken, per-task pass/fail + faults, any `create -f`/name/argv/`sh -c` slips, and whether the cold NP/Ingress metrics were truly cold. Then `notes.md` Day 6 + Week 5 wrap, and the **Carry into Week 6** list (Week 6 = Security & Environment: SecurityContext, RBAC, ServiceAccounts).

> Self-grade honestly on the carried metrics: was the NetworkPolicy egress (if it appeared) authored cold with the map shape + one-peer-AND? Was the Ingress cold without `explain`? Those two close the W4 debt — don't mark them met unless they were genuinely cold.
