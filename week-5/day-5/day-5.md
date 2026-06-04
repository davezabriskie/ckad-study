# Week 5 — Day 5 (Saturday June 6)

**Total time**: 2–3 hr | Image modify deep + complex cross-domain + milestone prep

> The weekend deep block before tomorrow's milestone. Modify a provided Dockerfile (rebuild + reload), build the heaviest cross-domain stacks (multi-volume + resources + NetworkPolicy; StatefulSet + svc + CM + ResourceQuota), re-rep the Kustomize trap, then run interpretation drills as the cold recall test and an optional self-mock subset.

---

## Block 0 — Review + Ledger Warm-up (15 min)

- Cold egress NP (`describe netpol` + optionally traffic-verify with a test pod on Calico).
- **Ingress scaffold + hand-adds** (~5 min): `create ingress --rule` for the base, then hand-add two things the scaffold can't produce:
  1. A `tls:` block — `spec.tls[].hosts` + `secretName`. Shape: sibling to `rules`, not nested inside it.
  2. A `defaultBackend:` — `spec.defaultBackend.service.name/port.number`. Catches traffic that matches no rule.
- **Kustomize re-rep** (lighter): reps 1 + 2 only — confirm the `includeSelectors: false` default and reproduce the immutable trap once more. Render before apply.
- 60-second ledger drill: argv tokenization, `-f` vs `-k`, namespace-first, `=` not `:`, literal names.

Check against `day-5-answers.md` → Block 0.

---

## Block 1 — Image modify (provided Dockerfile) (25 min)

Apply the provided broken/old Dockerfile blind, then modify per the task — this ships pre-built so you're modifying real code, not authoring from scratch.

Start from `yaml-practice/provided/Dockerfile` (create it from `day-5-answers.md` → Block 1 **Setup** if it doesn't exist — that's the "provided" artifact):

**Task**: the provided image runs an old base and the wrong entrypoint. Modify it to:
1. Change the base image from `busybox:1.34` to `busybox:1.36`.
2. Change the `ENTRYPOINT` so the container prints the current date every 5 seconds in a loop, instead of echoing once. (You write the form — and decide whether *this* one genuinely needs `sh -c`. The argv-vs-`sh -c` call is the point.)
3. Rebuild as `clock-app:v2`, `kind load`, run in a pod `clock-pod` (correct tag + pull policy).
4. Confirm `kubectl logs -f clock-pod` streams timestamps.

Check against `day-5-answers.md` → Block 1.

---

## Block 2 — Complex: multi-container + multi-volume + resources + NetworkPolicy (30 min)

One pod, four concerns. Pod `vault` in namespace `secure` (create the ns, namespace-first):
- Two containers (`app` + `sidecar`, both `busybox` kept alive) sharing an `emptyDir` at `/shared`.
- The `app` container also mounts a PVC `vault-data` at `/data` (RWO, 1Gi) and exposes its pod IP as `MY_POD_IP` via `fieldRef`.
- Both containers: `requests` cpu `50m`/mem `64Mi`, `limits` cpu `100m`/mem `128Mi`.
- A NetworkPolicy `vault-lockdown` selecting the pod's label, default-deny ingress except from `app: gateway` on TCP 8080.

Verify: shared file visible in both containers, PVC mounted, `printenv MY_POD_IP`, `describe netpol`, limits in `describe pod`.

> Calico enforces NP here — you can traffic-verify (a connection from a non-`gateway` pod should time out), not just `describe netpol`.

Check against `day-5-answers.md` → Block 2.

---

## Block 3 — Cross-domain: StatefulSet + service + configmap + ResourceQuota (25 min)

Namespace `data` (namespace-first). Build:
- ResourceQuota `data-quota`: `requests.cpu: 1`, `requests.memory: 1Gi`, `pods: 6`.
- LimitRange `data-defaults` so pods without resources are admitted.
- Headless Service `db-headless` (`clusterIP: None`, selector `app: db`).
- ConfigMap `db-cfg` (`DB_MODE=replica`).
- StatefulSet `db` (2 replicas, `redis:7`, `serviceName: db-headless`, `volumeClaimTemplates` `data` RWO 1Gi mounted at `/data`), injecting `db-cfg` as env.

Verify: `db-0`/`db-1` running, per-replica PVCs, `printenv DB_MODE` in a pod, quota usage (`kubectl describe quota data-quota`).

Check against `day-5-answers.md` → Block 3.

---

## Block 4 — Interpretation drills (cold recall test, AFTER the blocks) (15 min)

Per the ordering rule, drills run now as a recall calibration — name the resource/field cold, no reference. 15s each.

1. "Each pod needs its own 1Gi disk that survives reschedule, plus a stable hostname."
2. "Default every container in a namespace to 256Mi request / 512Mi limit when unspecified."
3. "Expose the container's CPU limit to the app as `$CPU_LIMIT`."
4. "Combine a Secret and the pod's labels into one mounted directory."
5. "Run a locally-built `tool:v3` on kind without a registry."
6. "A bare `while`-loop entrypoint — argv form?"
7. "Memory-backed scratch shared by two containers."
8. "Cap a namespace at 6 pods and 2 CPU of requests."

Check against `day-5-answers.md` → Block 4. **Note any you couldn't produce cold** — those are tomorrow's warm-up.

---

## Block 5 — Optional self-mock subset (25 min, if energy holds)

Pick 4 of the 6 milestone task types, timed, no answers file open. Treat as a dress rehearsal:
- 1 quick PVC scaffold
- 1 ephemeral volume (downwardAPI or emptyDir)
- 1 StatefulSet + headless svc
- 1 image modify + rebuild + run

Time each; log gaps to `notes.md`. Don't grade hard — this is calibration for tomorrow.

---

## End-of-Session Checklist

- [ ] Dockerfile modified (base + entrypoint), rebuilt `:v2`, kind-loaded, ran, logs streamed
- [ ] Complex `vault` pod: emptyDir + PVC + fieldRef + resources + NP all verified
- [ ] Cross-domain `data` stack: STS + headless svc + CM + quota + limitrange, all green
- [ ] Interpretation drills run cold; misses noted for tomorrow's warm-up
- [ ] Namespace-first held across `secure` and `data` — nothing leaked to `default`
- [ ] Milestone readiness logged in `notes.md`
