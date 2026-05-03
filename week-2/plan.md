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

### Day 3 — Monday May 4 (75 min): Deployments — Updates + Rollbacks

**Udemy** (25 min):
- Rolling updates and rollbacks section

**YAML Speed Writing** (15 min):
- Deployment + Service from memory — 2 full reps back to back

**Mixed Tasks** (25 min):
- Quick: Scale a Deployment to 5 replicas imperatively (`kubectl scale`)
- Medium: Update a running Deployment's image and watch the rollout
- Quick: Roll back a Deployment to the previous version

**kubectl explain** (5 min):
```bash
kubectl explain deployment.spec.strategy
kubectl explain deployment.spec.template
```

---

### Day 4 — Tuesday May 5 (75 min): Jobs + CronJobs

**Udemy** (25 min):
- Jobs and CronJobs section
- Focus: `spec.completions`, `spec.parallelism`, `spec.schedule`, restart behavior

**YAML Speed Writing** (15 min):
- Job YAML from memory — 3 reps
  - Job named `batch-job` running `busybox` that echoes "done" and exits
- CronJob YAML from memory — 2 reps
  - CronJob named `hourly-job`, schedule `0 * * * *`, same container

**Mixed Tasks** (25 min):
- Quick: Create a Job that runs `busybox` to echo a message and exits cleanly
- Medium: Create a CronJob that runs every 5 minutes and prints the current date

**kubectl explain** (5 min):
```bash
kubectl explain job.spec
kubectl explain cronjob.spec.jobTemplate
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
- [ ] Week 1 milestone passed (if not yet)
- [ ] Write Deployment YAML from memory with correct `selector` + `template` label wiring
- [ ] Write Job and CronJob YAML from memory
- [ ] Execute a rolling update and rollback via `kubectl`
- [ ] Complete Week 2 milestone in under 25 minutes

## Key Things to Lock In This Week

1. **Service selector must match pod labels** — most common exam mistake
2. **Deployment `selector.matchLabels` and `template.metadata.labels` must be identical**
3. **Job vs CronJob**: Job runs once (or N times), CronJob schedules a Job on a cron schedule
4. **`kubectl rollout`** commands: `status`, `history`, `undo`
