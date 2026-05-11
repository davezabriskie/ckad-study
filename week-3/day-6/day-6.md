# Week 3 — Day 6 (Saturday May 17)

**Total time**: 2+ hours | Week 3 Milestone

---

## Milestone Assessment (30 min)

**Rules**: Timed. No notes. 3-minute skip rule per task. 15-second interpretation phase before writing anything.

Start the timer now.

---

### Task 1 — Quick (4 min)

Create ConfigMap `app-cfg` with keys `ENV=prod`, `LOG_LEVEL=warn`, and `REGION=us-east-1`.
Create Deployment `app`, 2 replicas, `nginx:1.21`, label `app=app`.
Inject all ConfigMap keys as env vars. Add a **readinessProbe** httpGet on `/` port 80.

---

### Task 2 — Quick (4 min)

Create Secret `db-secret` with `username=admin` and `password=s3cr3t`.
Inject `password` only into a Deployment `db-client` as env var `DB_PASSWORD`.
Expose `db-client` with a ClusterIP service on port 5432.

---

### Task 3 — Medium (6 min)

Create ConfigMap `nginx-cfg` with key `server.conf` containing a minimal nginx config block.
Mount it into Deployment `web-server` at `/etc/nginx/conf.d`.
Add a **readinessProbe** httpGet `/` port 80.

---

### Task 4 — Medium (7 min)

Install `bitnami/nginx` as Helm release `prod-web` with `replicaCount=3`.
Verify pods are running.
Upgrade the release to `replicaCount=2` using `helm upgrade --install`.
Verify the replica count changed.

---

### Task 5 — Medium (7 min)

Create a base Kustomize directory with a simple Deployment (`nginx:1.21`, 2 replicas).
Create an overlay that patches the image to `nginx:1.22`, adds `namePrefix: staging-`, and adds `commonLabels: env=staging`.
Apply the overlay. Verify the Deployment is named `staging-<name>` with the correct label.

---

### Task 6 — Complex (10 min)

Create the following in a single YAML file:
- ConfigMap `stack-cfg`: `APP_ENV=production`, `LOG_LEVEL=error`
- Secret `stack-secret`: `API_TOKEN=tok-xyz`
- Deployment `stack`, 3 replicas, `nginx:1.21`, label `app=stack`:
  - Mount `stack-cfg` as files at `/etc/app`
  - Inject `API_TOKEN` from `stack-secret` as env var `TOKEN`
  - Add **readinessProbe** httpGet `/` port 80
  - Add resource requests `cpu: 100m, memory: 128Mi`
- ClusterIP Service `stack-svc` on port 80

Verify volume mount and env var are present in a running pod.

---

**Stop timer. Record result in `week-3/milestone-results.md`.**

---

## Deep Practice (60 min)

Focus on whatever tripped you in the milestone.

**If Task 3 or 6 was slow**: 3 more volume mount reps — ConfigMap mounted as files, verified with `kubectl exec`.

**If Task 2 was slow**: 3 Secret injection reps — `secretKeyRef`, `secretRef`, volume mount.

**If Task 4 was slow**: drill the 4 Helm commands (`install`, `upgrade --install`, `get values`, `uninstall`) 3 times each from memory.

**If Task 5 was slow**: write a `kustomization.yaml` from memory 5 times with different fields each time.
