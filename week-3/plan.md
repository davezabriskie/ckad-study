# Week 3 — Plan (May 11–17)

## Gaps Carried from Week 2

From `week-2/milestone-results.md`:

1. **CronJob schedule syntax** — `*/5 * * * *` not `5 * * * *`. Three occurrences. Every scaffold sprint this week includes a CronJob with the schedule given in English.
2. **Service imperative scaffold** — `kubectl create service clusterip <name> --tcp=<port>:<port>` fumbled under pressure. In every scaffold sprint this week.
3. **liveness vs readiness probe** — wrong probe type reached for every time. Every task that requires a probe names the type explicitly. Slow down on the 15-second interpretation phase.
4. **`Pod.spec.containers` plural** — typo in explain path costs time. Noted in Day 1 kubectl explain block.

---

## This Week's Focus

ConfigMaps (deep), Secrets, Helm, Kustomize.

Week 2 introduced ConfigMap env injection (`envFrom`, `valueFrom`). This week adds the third injection pattern (volume mount) and introduces Secrets with the same three patterns. Helm and Kustomize follow.

---

## Schedule

### Day 1 — Monday May 11 (75 min): ConfigMaps deep — volume mount pattern

**New this day**: `volumes` + `volumeMounts` + `configMap` — the third injection pattern deferred from Week 2. Also: `--from-file` imperative form.

---

### Day 2 — Tuesday May 12 (75 min): Secrets

**New this day**: Secret structure, base64 encoding, all three injection patterns (`secretKeyRef`, `secretRef`, volume). Cross-domain: Deployment + ConfigMap + Secret wired together.

---

### Day 3 — Wednesday May 13 (75 min): Helm

**New this day**: `helm repo add`, `helm install`, `helm upgrade --install`, value overrides (`--set`, `-f`), `helm list`, `helm get values`, `helm uninstall`. Scope: consuming existing charts only.

---

### Day 4 — Thursday May 14 (75 min): Kustomize

**New this day**: `kustomization.yaml` structure (`resources`, `commonLabels`, `namePrefix`, `images`), `kubectl apply -k`, overlay that patches a base Deployment.

---

### Day 5 — Friday May 15 (75 min): Cross-domain + Milestone Prep

Full-stack consolidation across all Week 3 content. Task interpretation drills. Weak spot drill.

---

### Day 6 — Saturday May 17 (2+ hours): Week 3 Milestone

See `day-6/day-6.md`. Results → `week-3/milestone-results.md`.

---

## Week 3 Success Metrics

- [ ] Write ConfigMap volume mount pattern from memory (volumes + volumeMounts)
- [ ] Write Secret YAML from memory (imperative + YAML form)
- [ ] Inject Secret via `secretKeyRef` and `secretRef`
- [ ] Mount Secret as a volume
- [ ] `helm install` + value override + verify + `helm uninstall`
- [ ] `kubectl apply -k` from an overlay directory
- [ ] Complete Week 3 milestone in under 38 minutes

## CKAD Plan Validation

Week 3 maps to **Application Deployment (20%)** + **Application Environment, Configuration and Security (25%)**.

| CKAD Plan Requirement | Day |
|---|---|
| ConfigMap volume mount pattern | Day 1 |
| ConfigMap `--from-file` | Day 1 |
| Secrets — all 3 injection patterns | Day 2 |
| Cross-domain: config + deployment | Day 2, 5 |
| Helm — install, upgrade, values, uninstall | Day 3 |
| Kustomize — apply -k, overlay | Day 4 |
| Task interpretation drills (Week 3+ rule) | Every day |
| 40% cross-domain tasks | Days 2, 5 enforced |

> Blue/green and canary were covered in Week 2. Not revisited here unless milestone results show a gap.
