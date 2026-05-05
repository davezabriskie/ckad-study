# Week 2 — Amended Plan (May 2–9)

**Note**: Week 1 Days 3–5 were not completed. This week front-loads that catchup before moving into Week 2 content (Deployments, Jobs, CronJobs). The Week 1 milestone must pass before treating Week 2 material as the primary focus.

---

## What Was Missed from Week 1

- **Day 3**: Pod Design (labels, selectors, annotations) + Service YAML + cross-domain tasks
- **Day 4**: YAML marathon + milestone dry run + troubleshooting scenarios
- **Day 5**: Week 1 milestone assessment + YAML fluency test

Key gaps going in: Service YAML not practiced from memory, sidecar placement still shaky (see notes), Pod Design Udemy section not watched.

---

## This Week's Schedule

### Day 1 — Saturday May 2 (2 hours): Week 1 Catchup

**Udemy** (20 min):
- Pod Design section: labels, selectors, annotations
- Skip anything you feel solid on — move fast

**YAML Speed Writing** (20 min):
- Service YAML from memory — 3 reps
  - ClusterIP service named `web-svc`, selector `app=web`, port 80 → 80
- Multi-container sidecar pod — 2 reps (fix the `spec.containers` vs `spec.initContainers` confusion from Day 2)

**Troubleshooting practice** (20 min):
- Use the broken scenarios in `week-1/day-4/day-4-answers.md` → Block 4
- `ImagePullBackOff`, no endpoints on service, pod stuck in `Init:0/1`

**Week 1 Milestone Attempt** (20 min):
- Use the tasks from `week-1/day-5/day-5.md` → Block 1
- Timed, no notes, 3-minute skip rule
- Record result in `week-1/milestone-results.md`

**Review** (20 min):
- If milestone failed: identify exactly which task broke down and why
- If milestone passed: note time and move on

---

### Day 2 — Sunday May 3 (2.5 hours): Close Week 1 + Launch Week 2

**Week 1 close** (30 min):
- If milestone failed Saturday: one retry attempt (same rules, timed)
- If milestone passed: YAML fluency test from `week-1/day-5/day-5.md` → Block 3 (5 pod variations from memory)

**Udemy** (30 min):
- Deployments and ReplicaSets section
- Focus: how a Deployment wraps a pod template, `spec.selector` + `spec.template` relationship, rolling update behavior

**YAML Speed Writing** (20 min):
- Deployment YAML from memory — 3 reps
  - `web-deploy`: 3 replicas, `nginx:1.21`, label `app=web`
- This is new — study the reference in `week-2/day-2-answers.md` → Block 2 first

**Mixed Tasks** (30 min):
- Quick: Create a Deployment named `api` with 2 replicas running `nginx:1.21`, label `app=api`
- Medium: Create the same Deployment + a ClusterIP service that targets it on port 80

---

### Day 3 — Monday May 4 (75 min): Rolling Updates + Jobs + CronJobs ✅ DONE

> Originally "Deployments — Updates + Rollbacks" only. Day 3 file was pre-built to include Jobs + CronJobs, compressing two days into one.

- Rolling updates: `set image`, `rollout status/history/undo`, `scale`
- Jobs: `completions`, `parallelism`, `restartPolicy: Never/OnFailure`
- CronJobs: `spec.schedule`, ownership chain (CronJob → Job → Pod)
- Gap: CronJob schedule syntax (`0 * * * *` vs `0 0 * * *`) — noted in notes.md
- Block 3b (stalled rollout recovery) deferred — circle back

---

### Day 4 — Tuesday May 5 (75 min): Blue/Green + Canary + ConfigMaps intro

**Blue/Green** (20 min):
- Two Deployments (`web-v1`, `web-v2`) with `version` label differentiating them
- Single Service; traffic controlled by patching selector to `version: v1` or `version: v2`
- Rollback = patch selector back

**Canary** (15 min):
- Stable + canary Deployments share `app=web` label
- Service selects `app=web`; traffic split proportional to replica count
- Promote by draining stable, scaling canary up

**ConfigMaps intro** (25 min):
- Udemy: ConfigMaps section
- `kubectl create configmap --from-literal` imperative form
- `envFrom` + `configMapRef` — inject all keys as env vars
- `env` + `valueFrom.configMapKeyRef` — inject single key

**kubectl explain** (5 min):
```bash
kubectl explain deployment.spec.template.spec.containers.envFrom
kubectl explain deployment.spec.template.spec.containers.env
```

---

### Day 5 — Wednesday May 6 (75 min): Cross-domain + Week 2 Milestone Prep

**YAML Speed Writing** (15 min):
- One rep each from memory: Deployment, Service, Job — all three back to back

**Task Interpretation Drills** (5 min):
- 15 seconds per prompt, write fields only

**Mixed Tasks** (40 min):
- Quick: Deployment from memory with correct labels and selector wiring
- Medium: Deployment + ConfigMap (inject env vars into the pod template)
- Complex: Full stack — Deployment + ConfigMap + ClusterIP Service, all wired together

---

### Day 6 — Saturday May 9 (2+ hours): Week 2 Milestone

**Milestone Assessment** (25 min):

Timed, no notes, 3-minute skip rule per task, 15-second interpretation phase per task.

- **Task 1 — Quick**: Create a Deployment named `backend` with 3 replicas running `redis:7`, label `app=backend`
- **Task 2 — Quick**: Expose `backend` with a ClusterIP service on port 6379
- **Task 3 — Medium**: Create a Job named `db-init` that runs `busybox` and echoes "database initialized"
- **Task 4 — Medium**: Update the `backend` Deployment to use `redis:7.2`, verify rollout, then roll back
- **Task 5 — Complex**: Create ConfigMap `app-cfg` with `ENV=prod` and `LOG_LEVEL=warn`, create Deployment `app` (2 replicas, `nginx:1.21`, label `app=app`) injecting both values as env vars, expose with service `app-svc` on port 80

Record result in `week-2/milestone-results.md`.

**Deep practice** (60 min):
- Variable difficulty — focus on whatever tripped you in the milestone

---

## Week 2 Success Metrics

By end of week:
- [x] Week 1 milestone passed
- [ ] Write Deployment YAML from memory with correct `selector` + `template` label wiring
- [ ] Write Job and CronJob YAML from memory
- [ ] Execute a rolling update and rollback via `kubectl`
- [ ] Implement blue/green traffic switch via Service selector patch
- [ ] Implement canary split via shared label + replica ratio
- [ ] Inject ConfigMap keys into a Deployment via `envFrom` and `valueFrom`
- [ ] Complete Week 2 milestone in under 25 minutes

## Key Things to Lock In This Week

1. **Service selector must match pod labels** — most common exam mistake
2. **Deployment `selector.matchLabels` and `template.metadata.labels` must be identical**
3. **Job vs CronJob**: Job runs once (or N times), CronJob schedules a Job on a cron schedule
4. **`kubectl rollout`** commands: `status`, `history`, `undo`
5. **Blue/green**: Service selector is the only lever — both Deployments always run
6. **Canary**: shared label + replica ratio — no special K8s feature required
7. **CronJob schedule syntax**: `0 * * * *` = hourly, `*/5 * * * *` = every 5 min

## CKAD Plan Validation

Week 2 maps to **Application Deployment (20%)** in the exam domain.

| CKAD Plan Requirement | Status |
|---|---|
| Deployments + ReplicaSets | ✅ Day 2 |
| Rolling updates + rollbacks | ✅ Day 3 |
| Jobs + CronJobs | ✅ Day 3 |
| Blue/green pattern | Day 4 |
| Canary pattern | Day 4 |
| Imperative kubectl mutations | ✅ Days 2–3, reinforced Day 4–5 |
| ConfigMaps (intro) | Day 4 — pulled forward from Week 3; required for milestone Task 5 |

> ConfigMaps are Week 3's primary focus. The intro here covers only env var injection. Volume mount pattern deferred to Week 3.
