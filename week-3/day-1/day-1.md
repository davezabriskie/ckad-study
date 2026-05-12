# Week 3 — Day 1 (Monday May 11)

**Total time**: 75 min | ConfigMaps deep — volume mount pattern

> Week 2 introduced env injection. Today adds the third pattern: mounting ConfigMap data as files via volumes. Also covers `--from-file`, which the exam uses for config-file scenarios.

---

## Block 0 — Scaffold + Refine Sprint (15 min)

Three reps, back to back. No notes. Target ~5 min per rep.

1. Deployment `web`, image `nginx:1.21`, 2 replicas, label `app=web`. Add a **readinessProbe** (httpGet, path `/`, port 80, `initialDelaySeconds: 5`) and resources (`requests: cpu: 100m, memory: 128Mi` / `limits: cpu: 250m, memory: 256Mi`).
2. ClusterIP Service `web-svc` targeting `app=web` on port 80 — imperative scaffold only, no manual YAML.
3. CronJob `log-rotate` that runs **every 6 hours**, image `busybox`, command `echo rotate`.

Save to `yaml-practice/sprint-{1,2,3}.yaml`. Apply all three.

> Reminder: `kubectl explain` path is always `Pod.spec.containers` — plural. Never `Pod.spec.container`.

---

## Block 1 — Task Interpretation Drills (5 min)

15 seconds each. Write field names only — no full YAML.

**Prompt A**: "Create a ConfigMap from a file called `app.properties` and mount it into a pod at `/etc/app`"

**Prompt B**: "Inject a single ConfigMap key `LOG_LEVEL` into a Deployment as an env var named `APP_LOG_LEVEL`"

**Prompt C**: "Create a ConfigMap with key `ENV=staging` and inject all keys into a Deployment"

Check against `day-1-answers.md` → Block 1.

---

## Block 2 — Udemy: ConfigMap volume mount (15 min)

Watch the **ConfigMaps** volume mount section. Focus on:
- How `volumes` and `volumeMounts` wire together
- Each key in the ConfigMap becomes a file in `mountPath`
- `--from-file` imperative form — when to use it vs `--from-literal`
- What happens to the volume when the ConfigMap is updated

---

## Block 3 — ConfigMap volume mount practice (20 min)

**Study the reference** in `day-1-answers.md` → Block 3. Close it. Then write from memory.

**Rep 1**: Create ConfigMap `nginx-cfg` with a single key `default.conf` containing a minimal nginx server block. Mount it into a Deployment `web-server` at `/etc/nginx/conf.d`.

Save ConfigMap to `yaml-practice/nginx-cfg.yaml`, Deployment to `yaml-practice/web-server.yaml`.

**Rep 2 — `subPath` pattern**: Create ConfigMap `app-settings` with two keys: `app.conf` (any content) and `LOG_LEVEL=warn`. Mount **only `app.conf`** into Deployment `app` at `/etc/app/app.conf` using `subPath` — without overwriting the entire `/etc/app` directory. Also inject `LOG_LEVEL` as an env var via `valueFrom` in the same Deployment.

Save to `yaml-practice/app-settings-cm.yaml` and `yaml-practice/app-deploy.yaml`.

`subPath` is critical: without it, mounting at `/etc/app/app.conf` would mount the whole ConfigMap as a directory. With `subPath: app.conf`, only that one key is mounted as a single file, preserving anything else in `/etc/app`.

Verify:
```bash
kubectl exec deploy/app -- ls /etc/app
kubectl exec deploy/app -- cat /etc/app/app.conf
kubectl exec deploy/app -- env | grep LOG_LEVEL
```

Check against `day-1-answers.md` → Block 3.

---

## Block 4 — Mixed Tasks (15 min)

3-minute skip rule. 15-second interpretation phase per task.

### Quick
Create ConfigMap `db-config` from a literal file approach: write a file `db.properties` with two lines (`host=postgres` and `port=5432`), then create the ConfigMap using `--from-file`. Verify the key name matches the filename.

### Medium
Scaffold a Deployment `backend`, image `nginx:1.21`, 2 replicas. Add:
- ConfigMap `db-config` mounted at `/etc/db`
- A **readinessProbe** httpGet on path `/` port 80
- Resource requests `cpu: 100m, memory: 64Mi`

Save to `yaml-practice/backend.yaml`. Check against `day-1-answers.md` → Block 4.

---

## Block 5 — kubectl explain drill (5 min)

No looking up syntax before trying.

```bash
kubectl explain pod.spec.volumes
kubectl explain pod.spec.volumes.configMap
kubectl explain pod.spec.containers.volumeMounts
```

---

## End-of-Session Checklist

Fill in `week-3/notes.md` Day 1 tracking:
- [x] Scaffold sprint: readinessProbe correct (not liveness)? CronJob schedule correct? — probe ✓, schedule slip (`*/6` vs `0 */6`)
- [x] Service scaffold: imperative command from memory without fumbling? — used `kubectl create service clusterip`, fixed selector on second pass
- [x] Volume mount pattern: both reps clean? — Rep 1 clean; Rep 2 had env-var naming deviation + one redeploy cycle
- [x] `--from-file` understood — key name = filename? — verified via `describe configmap`
- [x] Mixed tasks completed? — Block 4 quick + medium done; field-placement error caught and fixed
- [x] Areas to improve? — logged in `week-3/notes.md` Day 1

---

## Session Learnings (May 11)

**CronJob schedule pitfall**
- `*/6 * * * *` = every 6 **minutes**, not hours. Every 6 hours = `0 */6 * * *`.
- Imperative form beats explain-tree walking: `kubectl create cronjob log-rotate --image=busybox --schedule="0 */6 * * *" -- sh -c "echo rotate" --dry-run=client -o yaml`.

**`volumes` + `volumeMounts` wiring**
- `volumes` (pod-level) declares the source; `volumeMounts` (container-level) places it in the filesystem. The `name:` field is the glue — must match exactly.
- Without `subPath`: `mountPath` is always treated as a **directory**, regardless of extension. Mounting at `/etc/app/app.conf` without `subPath` creates a *directory* named `app.conf` containing one file per ConfigMap key.
- With `subPath: <key>`: mounts a single key as a single file, preserving siblings in the directory.

**ConfigMap update semantics**
- Whole-directory mounts: files auto-update via atomic symlink swap, ~60–90s. App still needs reload (`rollout restart`) unless it watches the file (Prometheus, Fluent Bit do; nginx, postgres don't).
- `subPath` mounts: **never auto-update**. Restart required.
- Env vars from CM (`envFrom` / `valueFrom`): **never auto-update**. Frozen at pod start.
- Immutable ConfigMaps (`immutable: true`): can't be edited — create a new versioned CM and update the Deployment ref.

**Production use cases for CM volume mounts**
- nginx (`/etc/nginx/conf.d/`), Prometheus (`prometheus.yml`), Fluent Bit (`fluent-bit.conf`), Envoy bootstrap, Postgres/Redis/MySQL config files, Spring Boot `application.yaml`. Anywhere the app reads config from disk rather than env.

**Field placement (where things live)**
| Field | Lives under |
|---|---|
| `volumes` | pod spec (shared resource) |
| `volumeMounts` | container (per-container) |
| `readinessProbe` / `livenessProbe` / `startupProbe` | container |
| `resources` | container |
| `env` / `envFrom` | container |
| `restartPolicy` / `nodeSelector` / `tolerations` / `serviceAccountName` | pod spec |

Strict-decoding errors like `unknown field "spec.template.spec.readinessProbe"` tell you exactly where the field landed wrongly — read the path.

**Exam format note**
- CKAD tasks are explicit: exact names, exact numeric values, exact paths. No "appropriate" or "standard" — the grader is mechanical.
- The translation skill being trained: prose ("with environment variable `LOG_LEVEL` set from a ConfigMap") → correct field path (`env.valueFrom.configMapKeyRef`).
