# Week 3 — Day 1 (Monday May 11)

**Total time**: 75 min | ConfigMaps deep — volume mount pattern

> Week 2 introduced env injection. Today adds the third pattern: mounting ConfigMap data as files via volumes. Also covers `--from-file`, which the exam uses for config-file scenarios.

---

## Block 0 — Scaffold + Refine Sprint (15 min)

Three reps, back to back. No notes.

1. Deployment `web`, image `nginx:1.21`, 2 replicas, label `app=web`. Add a **readinessProbe** (httpGet, path `/`, port 80, `initialDelaySeconds: 5`) and resource requests + limits.
2. ClusterIP Service `web-svc` targeting `app=web` on port 80 — imperative scaffold only, no manual YAML.
3. CronJob `log-rotate` that runs **every 6 hours**, image `busybox`, command `echo rotate`.

Save to `yaml-practice/sprint-{1,2,3}.yaml`. Apply all three.

> Reminder: `kubectl explain` path is always `Pod.spec.containers` — plural. Never `Pod.spec.container`.

---

## Block 1 — Task Interpretation Drills (5 min)

15 seconds each. Write field names only — no full YAML.

**Prompt A**: "Create a ConfigMap from a file called `app.properties` and mount it into a pod at `/etc/app`"

**Prompt B**: "Inject a single Secret key `DB_PASS` into a Deployment as an env var named `DATABASE_PASSWORD`"

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

**Rep 2**: Create ConfigMap `app-settings` with two keys: `LOG_LEVEL=warn` and `MAX_CONN=100`. Mount into Deployment `app` at `/etc/settings` (both keys become files). Also inject `LOG_LEVEL` as an env var via `valueFrom` in the same Deployment.

Save to `yaml-practice/app-settings-cm.yaml` and `yaml-practice/app-deploy.yaml`.

Verify:
```bash
kubectl exec deploy/app -- ls /etc/settings
kubectl exec deploy/app -- cat /etc/settings/LOG_LEVEL
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

Check against `day-1-answers.md` → Block 4.

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
- [ ] Scaffold sprint: readinessProbe correct (not liveness)? CronJob schedule correct?
- [ ] Service scaffold: imperative command from memory without fumbling?
- [ ] Volume mount pattern: both reps clean?
- [ ] `--from-file` understood — key name = filename?
- [ ] Mixed tasks completed?
- [ ] Areas to improve?
