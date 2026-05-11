# Week 3 — Day 2 (Tuesday May 12)

**Total time**: 75 min | Secrets

> Secrets follow the exact same three injection patterns as ConfigMaps. The structural difference is minimal — the exam tests whether you know the field name swaps and the base64 requirement.

---

## Block 0 — Scaffold + Refine Sprint (15 min)

1. Deployment `api`, image `nginx:1.21`, 3 replicas, label `app=api`. Add a **readinessProbe** (httpGet, `/healthz`, port 8080) and resource limits only (`cpu: 200m, memory: 128Mi`).
2. ClusterIP Service `api-svc` targeting `app=api` on port 8080 — imperative scaffold.
3. CronJob `backup` that runs **every day at 2am**, image `busybox`, command `echo backup`.

Save to `yaml-practice/sprint-{1,2,3}.yaml`. Apply all three.

---

## Block 1 — Task Interpretation Drills (5 min)

15 seconds each.

**Prompt A**: "Create a Secret with username `admin` and password `s3cr3t`, inject both as env vars"

**Prompt B**: "Mount a Secret named `tls-secret` into a pod at `/etc/tls`"

**Prompt C**: "Create a Deployment that injects all keys from a ConfigMap and a single key from a Secret as env vars"

Check against `day-2-answers.md` → Block 1.

---

## Block 2 — Udemy: Secrets (15 min)

Watch the **Secrets** section. Focus on:
- Why Secrets exist separately from ConfigMaps (access control, not encryption at rest by default)
- `type: Opaque` — the generic type
- Base64 encoding requirement in YAML form
- `kubectl create secret generic` handles encoding automatically
- Field name swaps vs ConfigMap: `secretKeyRef`, `secretRef`
- Volume mount works identically to ConfigMap

### `stringData` vs `data` (know cold)

- `data:` — values must be base64 encoded. Read back returns the encoded form.
- `stringData:` — values are plain text. kubectl base64-encodes them on apply. Read back always returns `data:` (encoded).

Use `stringData` when writing YAML by hand to skip the encoding step. Use `data` if you've already encoded values (e.g. piping from another tool).

---

## Block 3 — Secret YAML + injection practice (20 min)

**Study the reference** in `day-2-answers.md` → Block 3. Close it. Then write from memory.

**Rep 1**: Create Secret `db-secret` with `username=admin` and `password=postgres123`. Inject both as env vars into Deployment `db-client` using `envFrom`.

Save to `yaml-practice/db-secret.yaml` and `yaml-practice/db-client.yaml`.

**Rep 2**: Same Secret. Inject only `password` as an env var named `DB_PASSWORD` using `valueFrom.secretKeyRef`.

Save to `yaml-practice/db-client-single.yaml`.

**Rep 3**: Mount `db-secret` as a volume in Deployment `db-client-vol` at `/etc/db-creds`.

Save to `yaml-practice/db-client-vol.yaml`.

Verify rep 3:
```bash
kubectl exec deploy/db-client-vol -- ls /etc/db-creds
kubectl exec deploy/db-client-vol -- cat /etc/db-creds/username
```

**Rep 4 — Secret from file (TLS pattern)**: Generate a self-signed TLS cert + key pair, then create a Secret from those files. This is the realistic exam scenario.

```bash
openssl req -x509 -newkey rsa:2048 -nodes -keyout tls.key -out tls.crt -days 1 -subj "/CN=test"
kubectl create secret generic tls-secret --from-file=tls.crt --from-file=tls.key
kubectl describe secret tls-secret   # should show both keys
```

Mount it into a Deployment `tls-app` at `/etc/tls`. Save to `yaml-practice/tls-app.yaml`.

Verify:
```bash
kubectl exec deploy/tls-app -- ls /etc/tls
kubectl exec deploy/tls-app -- cat /etc/tls/tls.crt | head -3
```

Check against `day-2-answers.md` → Block 3.

---

## Block 4 — Cross-domain task (15 min)

This is the 40% cross-domain requirement for the week.

Create the following stack in a single YAML file (`yaml-practice/full-stack.yaml`):
- ConfigMap `app-cfg`: `ENV=prod`, `LOG_LEVEL=info`
- Secret `app-secret`: `API_KEY=abc123`
- Deployment `app`, 2 replicas, `nginx:1.21`, label `app=app`:
  - Inject all ConfigMap keys via `envFrom`
  - Inject `API_KEY` from the Secret as env var `APP_API_KEY` via `valueFrom`
  - Add a **readinessProbe** httpGet on `/` port 80
- ClusterIP Service `app-svc` on port 80

Verify all env vars are present in a running pod.

Check against `day-2-answers.md` → Block 4.

---

## Block 5 — kubectl explain drill (5 min)

```bash
kubectl explain pod.spec.containers.env.valueFrom.secretKeyRef
kubectl explain pod.spec.containers.envFrom.secretRef
kubectl explain pod.spec.volumes.secret
```

---

## End-of-Session Checklist

Fill in `week-3/notes.md` Day 2 tracking:
- [ ] Scaffold sprint: probe type correct? CronJob schedule correct?
- [ ] All three Secret injection patterns clean?
- [ ] Cross-domain full stack: all resources wired and env vars verified?
- [ ] Field name swaps memorised: `secretKeyRef` / `secretRef` vs `configMapKeyRef` / `configMapRef`?
- [ ] Areas to improve?
