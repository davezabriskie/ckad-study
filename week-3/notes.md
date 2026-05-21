# Week 3 Study Notes

## Gaps Carried from Week 2

- **CronJob schedule syntax**: `*/N * * * *` = every N minutes, `N * * * *` = at minute N of every hour
- **Service imperative scaffold**: `kubectl create service clusterip <name> --tcp=<port>:<port> --dry-run=client -o yaml`
- **Probe type discipline**: read the task twice — `readinessProbe` removes from endpoints (no restart), `livenessProbe` restarts the container
- **`Pod.spec.containers` is always plural** — typo `container` (singular) in explain path wastes time

---

## Key Concepts

### ConfigMap — Volume Mount Pattern

```yaml
# In pod/deployment spec:
containers:
  - name: app
    volumeMounts:
      - name: config-vol
        mountPath: /etc/config
volumes:
  - name: config-vol
    configMap:
      name: my-cfg
```

- Each ConfigMap key becomes a file in `mountPath`
- File contents = the key's value
- `volumes[].name` must match `volumeMounts[].name` exactly — the glue
- Useful for config files (nginx.conf, prometheus.yml, fluent-bit.conf, postgresql.conf)

### `subPath` — mount one key as a single file

```yaml
volumeMounts:
  - name: cfg
    mountPath: /etc/app/app.conf   # path INCLUDING filename
    subPath: app.conf              # which CM key to use
```

- **Without `subPath`**: `mountPath` is always a *directory*. Mounting at `/etc/app/app.conf` creates a directory named `app.conf` — the `.conf` extension is meaningless to k8s.
- **With `subPath`**: mounts just that key as a single file. Siblings in the parent directory survive.
- Tradeoff: `subPath` mounts **never auto-update** when the ConfigMap changes. Pod restart required.

### ConfigMap update propagation

| Mount type | Auto-updates? | Notes |
|---|---|---|
| Whole-directory volume mount | Yes (~60–90s) | Atomic symlink swap; app still needs reload unless it watches the file |
| `subPath` mount | **No** | File is copied at pod start; restart required |
| Env var (`envFrom` / `valueFrom`) | **No** | Frozen at pod start |
| Immutable ConfigMap (`immutable: true`) | N/A | Can't be edited; create versioned CM and update Deployment ref |

### Field placement — pod-level vs container-level

| Field | Lives under |
|---|---|
| `volumes` | pod spec |
| `volumeMounts` | container |
| `readinessProbe` / `livenessProbe` / `startupProbe` | container |
| `resources` | container |
| `env` / `envFrom` | container |
| `restartPolicy` / `nodeSelector` / `tolerations` / `serviceAccountName` / `imagePullSecrets` | pod spec |

Rule: per-process → container. Shared/pod-lifecycle → pod spec. `volumes` is the split case (declared pod-level, mounted container-level).

Strict-decoding errors (`unknown field "spec.template.spec.X"`) name the wrong path — read it to find the misplaced field.

### Iteration workflow — `apply` over `create`

- `kubectl apply -f file.yaml` is idempotent: creates if missing, patches if present. No `delete` needed between edits
- `kubectl create -f` errors on AlreadyExists, forcing a `delete deployment` cycle that costs ~15s per iteration
- Default to `apply` for everything except the very first creation. Reserve `create` for one-shot imperative scaffolds (`kubectl create deployment ... --dry-run=client -o yaml`)

### Imperative scaffold — name the resource, not the file

```bash
# BAD — bakes ".yaml" into the deployment name forever
kubectl create deployment tls-app.yaml --image=nginx --dry-run=client -o yaml > tls-app.yaml

# GOOD
kubectl create deployment tls-app --image=nginx --dry-run=client -o yaml > tls-app.yaml
```

The first positional arg is the **resource name**, not the output filename.

### Service endpoints = Ready pods only

- Empty `kubectl get endpoints <svc>` with matching pods running → check pod READY column
- A `readinessProbe` that never succeeds (wrong path/port for the image) keeps pods out of the endpoint list. Service exists, no traffic flows
- Quick triage: `kubectl get pods` → if `0/1 READY`, the probe is the suspect

### Verifying env vars — non-interactive

```bash
kubectl exec deploy/app -- env | grep -E 'API_KEY|LOG_LEVEL'
```

One shot, no `-it /bin/sh`. Faster on the exam.

### CronJob schedule — common slip

- `*/6 * * * *` = every 6 **minutes**
- `0 */6 * * *` = every 6 **hours** (at minute 0)
- Imperative scaffold beats writing from scratch: `kubectl create cronjob NAME --image=IMG --schedule="..." -- CMD --dry-run=client -o yaml`

### ConfigMap — All Three Injection Patterns

| Pattern | Field | Use when |
|---|---|---|
| All keys as env vars | `envFrom.configMapRef` | Simple, you control the ConfigMap key names |
| Single key as env var | `env.valueFrom.configMapKeyRef` | Need to rename, or only want one key |
| Mount as files | `volumes.configMap` + `volumeMounts` | App reads config from filesystem |

### Secrets

- Same three injection patterns as ConfigMaps — just swap `configMapRef` → `secretRef`, `configMapKeyRef` → `secretKeyRef`
- Values in YAML must be base64 encoded: `echo -n "value" | base64` (the `-n` matters — without it the trailing newline gets encoded)
- `kubectl create secret generic` with `--from-literal=KEY=VALUE` handles encoding automatically. Separator is `=`, not `:` — easy slip
- `type: Opaque` is the default generic secret type
- Other types: `kubernetes.io/tls`, `kubernetes.io/dockerconfigjson` — know they exist
- `stringData:` (plain text, kubectl encodes on apply) vs `data:` (must be pre-encoded). If both define the same key, `stringData` wins
- Base64 is **encoding, not encryption**. RBAC is the real boundary. Encryption-at-rest is a cluster-level API server config, off by default

### `valueFrom.secretKeyRef` — `name:` vs `key:`

```yaml
env:
  - name: APP_API_KEY        # ← what the pod sees in its env
    valueFrom:
      secretKeyRef:
        name: app-secret     # ← which Secret
        key: API_KEY         # ← which key inside that Secret
```

The outer `name:` and the inner `key:` are independent. The task usually specifies both ("expose Secret key X as env var Y") — re-read literally before typing.

### Helm

- Package manager for Kubernetes — installs pre-built application charts
- **Argument order**: `helm <verb> <RELEASE_NAME> <CHART>`. Release name first, chart second. Same shape for `install`, `upgrade`, `upgrade --install`
- `helm upgrade --install` is preferred over `helm install` — creates if not exists, upgrades if it does (upsert; idempotent)
- `helm install` errors if release exists; `helm upgrade` errors if release missing. `--install` flag bridges both
- `helm uninstall <RELEASE>` takes the release name only — no chart argument
- `helm list` has no subcommand (not `helm list releases`)

#### Chart values discovery — the workflow

Chart value keys are author-defined and rarely match Kubernetes field names. `replicas` (K8s) may be `replicaCount` (chart). Never guess.

```bash
helm show values <chart>                    # full default values.yaml
helm show values <chart> | grep -i <thing>  # find the exact key path
helm show readme <chart>                    # human guide; bitnami's are excellent
helm show all <chart>                       # everything
```

**Discipline**: the moment a `--set` doesn't take effect, stop retrying — run `helm show values | grep` first.

#### Override precedence (last wins)
chart defaults → `-f values.yaml` → `--set key=value`

#### `--set` syntax
- Scalar: `--set key=value`
- Nested: `--set parent.child=value` (dots for nesting)
- List of objects: `--set list[0].name=foo,list[0].value=bar`
- No colons, no `[a=b]` shorthand. CLI uses `=`, never `:`

#### YAML values file — the colon-space rule

| Form | Parsed as |
|---|---|
| `replicaCount=4` | **CLI only** (--set). Not valid YAML |
| `replicaCount:4` | YAML string `"replicaCount:4"` — silently wrong |
| `replicaCount: 4` | Integer `4` — correct. Space after `:` is mandatory |

Validate before applying: `helm upgrade <release> <chart> -f values.yaml --dry-run`

#### Helm-managed resources
Don't `kubectl patch` / `kubectl edit` resources owned by a release. Next `helm upgrade` reconciles them away. Go through `helm upgrade --set` or values file.

#### Useful inspect commands
- `helm list` — installed releases
- `helm get values <release>` — only overridden values (what you set)
- `helm get values <release> --all` — full effective values
- `helm status <release>` — release state and notes

### Kustomize

- Built into `kubectl` — no separate install needed (separate `kustomize` CLI exists but not required)
- Client-side tool: runs before anything hits the API. **`kubectl explain kustomization` does NOT work** — no API resource, no schema, must memorize the shape
- `kustomization.yaml` is the entry point — every directory Kustomize touches needs one
- Overlays compose base resources without modifying base files

#### Directory pattern

```
myapp/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/
    └── prod/
        └── kustomization.yaml   # resources: [../../base]
```

#### `kustomization.yaml` shape (memorize)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml             # base: list files
  - ../../base                  # overlay: list base directory

namePrefix: prod-               # web → prod-web
nameSuffix: -v2                 # web → web-v2

labels:                         # modern form (commonLabels is deprecated)
  - pairs:
      env: prod
    includeSelectors: false     # don't touch immutable selectors
    includeTemplates: true      # do add to pod template labels

images:
  - name: nginx                 # match by image name in base (no tag)
    newTag: "1.22"              # patch tag
    # newName: nginx-fork       # optional: swap image
```

#### The four CKAD-relevant transformations
`resources`, `namePrefix`/`nameSuffix`, `labels` (or deprecated `commonLabels`), `images`

#### The three commands
```bash
kubectl apply -k overlays/prod/      # apply (directory, not file)
kubectl diff  -k overlays/prod/      # preview diff vs cluster
kubectl kustomize overlays/prod/     # render merged YAML to stdout, no cluster touch
```

`kubectl kustomize` is the highest-value inspect command — use it before `apply` to sanity-check the merged output.

#### `commonLabels` is deprecated — danger of the old form

`commonLabels` always touches **selectors**, which are **immutable on existing Deployments**. Applying an overlay with `commonLabels` to a base that's already in the cluster errors with:
```
spec.selector: Invalid value: ...: field is immutable
```

Use the new `labels:` form with `includeSelectors: false, includeTemplates: true` instead. Same effect on metadata + pod templates, leaves selector alone.

#### Generators (low CKAD priority)

```yaml
configMapGenerator:
  - name: app-config
    literals: [LOG_LEVEL=DEBUG]
secretGenerator:
  - name: app-secret
    literals: [API_KEY=abc123]
```

- Create *new* ConfigMaps/Secrets at render time with a **content-hash suffix** in the name
- Kustomize auto-rewrites references (`configMapKeyRef.name`, `volumes.configMap.name`, etc.) in resources it manages to point to the hashed name
- Hash changes when content changes → Deployment ref changes → automatic rolling restart
- Disable with `generatorOptions: {disableNameSuffixHash: true}` if something outside Kustomize references the original name
- **Literals are verbatim** — `$(date)` does NOT shell-expand
- For CKAD: know they exist and the auto-rollout concept. Don't grind reps

#### Patches (low CKAD priority)

```yaml
patches:
  - path: patch-env.yaml          # strategic merge file
  - target: {kind: Deployment, name: web}
    patch: |                      # inline JSON 6902
      - op: add
        path: /spec/template/spec/containers/0/env/-
        value: {name: ENV, value: prod}
```

- Strategic merge: write partial K8s YAML that names what to change; merges by `kind` + `name` at top level, by `name` for list items (`containers`, `env`, `volumeMounts`)
- For env-var changes on the exam, `kubectl set env deployment/X K=V` is the shorter path. Patches are GitOps territory more than CKAD
- Patch references the **base** resource name, not the prefixed name

#### Immutable fields under selectors

Deployment `spec.selector` cannot be changed after creation. `commonLabels` slipped into the selector silently is the most common trap. Once you've applied a base with a given selector, any overlay that mutates that selector requires `kubectl delete` + re-apply, not just `apply -k`.

#### Apply target

`kubectl apply -k <DIR>` takes a **directory**, not a file. `-f` takes a file. Easy to conflate under pressure (`kubectl apply -k overlays/prod/kustomization.yaml` fails).

## kubectl Commands for Week 3

```bash
# ConfigMap
kubectl create configmap my-cfg --from-literal=key=val
kubectl create configmap my-cfg --from-file=config.properties
kubectl create configmap my-cfg --from-env-file=.env

# Secret
kubectl create secret generic my-secret --from-literal=username=admin --from-literal=password=pass
kubectl create secret generic my-secret --from-file=tls.crt
echo -n "admin" | base64   # encode a value manually

# Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-release bitnami/nginx
helm upgrade --install my-release bitnami/nginx --set replicaCount=2
helm upgrade --install my-release bitnami/nginx -f values.yaml
helm list
helm get values my-release
helm status my-release
helm uninstall my-release

# Kustomize
kubectl apply -k ./overlays/prod
kubectl diff -k ./overlays/prod   # preview changes before applying
```

---

## Daily Progress Tracking

### Day 1 (Monday May 11)
- YAML Speed: 2/3 reps clean (CronJob schedule slip — `*/6` vs `0 */6`)
- Tasks Completed: Block 0, 3, 4 complete; Block 1/2 deferred order (video didn't cover volume mounts)
- Areas to improve:
  - CronJob schedule: every-N-hours requires explicit minute `0 */N * * *`
  - Prefer `kubectl create cronjob` imperative over `explain`-tree walking
  - Field placement: probes/resources/volumeMounts under `containers[]`, not pod spec
  - Re-name env var to match task spec literally (Block 3 Rep 2 used `APP_LOG_LEVEL` when task said `LOG_LEVEL`)
  - Verification commands: run them separately, not chained with literal `\n`

### Day 2 (Tuesday May 12)
- YAML Speed: ~5/7 reps clean on first apply (Block 0 sprint-1 readiness mismatch was prompt-induced, not user error)
- Tasks Completed: Blocks 0, 1, 2 (TL;DW — no Udemy access), 3, 4 complete
- Areas to improve:
  - **Workflow**: use `kubectl apply -f` instead of `kubectl create -f` + `delete deployment --all` cycle. ~9 delete/recreate loops tonight that `apply` would have collapsed
  - **Imperative scaffold**: first positional arg is the resource name, not the filename. `kubectl create deployment tls-app ...` not `tls-app.yaml`
  - **`--from-literal` separator** is `=`, not `:` (`username=admin`, not `username:admin`)
  - **`valueFrom.secretKeyRef` distinction**: outer `name:` = pod-facing env var, inner `key:` = Secret's internal key. Block 4 v2 still had `API_KEY` when prompt said `APP_API_KEY`
  - **`subPath` semantics**: mounting with `subPath` makes `mountPath` a single file, not a directory. Wrong tool when you want "all keys as files"
  - **Service endpoints**: empty endpoints with running pods → check pod READY. Readiness probe gates endpoint membership
  - **YAML hygiene**: strip `status: {}`, `strategy: {}`, and unused port `name:` from dry-run output before saving
  - **Typo discipline**: `POSTGRESS_PASSWORD`, `app: tls-app.yaml` label leak — slow down on env var names and labels

### Day 3 (Friday May 15 — slipped from Wed May 13)
- YAML Speed: 3/3 Block 0 sprints clean (Deployment, Service, CronJob `0 8 * * 1` for Mon 8am — Week 2 gap closed)
- Tasks Completed: Block 0, 3, 4 worked through; Block 1/2 deferred
- Areas to improve:
  - **`helm` argument order**: `helm <verb> <RELEASE_NAME> <CHART>` — release name first, chart second. Tried `helm install bitnami/nginx web` and `helm install bitnami/nginx` before landing it
  - **`helm list` is the command** — no subcommand. Burned tries on `helm list releases`, `helm releases`, `helm release`
  - **Chart value keys ≠ K8s field names**: spent ~7 min on `--set replicas=N` before `helm show values | grep` revealed `replicaCount`. Reflex to build: the moment `--set` doesn't take effect, stop retrying and `helm show values <chart> | grep -i <thing>` first
  - **`--set` syntax**: `=` to assign, `.` to nest, `[0]` to index a list of objects. No colons, no brackets-as-list. Lists of objects: `extraEnvVars[0].name=FOO,extraEnvVars[0].value=bar`
  - **Don't `kubectl patch` helm-managed resources**: patches work for one second, next `helm upgrade` reconciles them away. Helm owns the resource — go through helm
  - **`helm uninstall` takes the release name only**, no chart argument. Tried `helm uninstall web bitnami/nginx` before landing `helm uninstall web`
  - **Labels vs env vars in bitnami charts**: pod labels = `commonLabels.KEY=value` (or `podLabels`); env vars = `extraEnvVars[N].name/value`. Different keys, different shapes
  - **YAML `:` needs a space after it** — `replicaCount:4` parses as a string and Helm silently ignores it; `replicaCount: 4` is the integer. Three iterations on values.yaml to find this
  - **`--dry-run` before applying values file**: `helm upgrade <rel> <chart> -f values.yaml --dry-run` catches YAML errors and wrong keys without touching the cluster

### Day 4 (Friday May 15 night / Saturday May 16 — slipped from Thu May 14, split across two sessions)
- YAML Speed (Block 0 only, Fri night): 3/3 scaffolds saved in ~7 min; structural fixes needed (resources block on Deployment, `-c` typo on CronJob command from vim'd-in array)
- Tasks Completed: Block 0 (Fri night). Block 1/3/4/5 → Saturday
- Areas to improve:
  - **`--labels=` uses `=` not `:`** (`--labels=app=cache`, not `app:cache`). Same separator-form trap as `--from-literal`
  - **`apply -f` discipline still slipping**: 4 `kubectl create -f` calls tonight led to a `kubectl delete service --all` workaround. The Day 2 lesson needs another rep — promote to top-of-mind: *default to `apply -f` for everything except dry-run scaffolds*
  - **Imperative resource-name discipline**: `kubectl create cronjob --schedule=...` with no name. First positional arg is always the resource name. Same shape as Helm's `<verb> <RELEASE> <CHART>` rule
  - **For CronJob/Pod commands, put them after `--` in the imperative**, not vim'd in afterward: `kubectl create cronjob name --image=X --schedule="..." -- sh -c "echo ok"`. Avoids array-syntax slips like `['sh', -'c', 'echo ok']`
  - **Imperative `kubectl create deployment` has no flag for resources/probes/volumes** — those always require post-scaffold vim editing
  - **Realistic resource values**: `cpu: 1m, memory: 8Mi` is structurally valid but redis won't boot. Pick values that match the workload

#### Day 4 continued — Wednesday May 20 (Blocks 3 + 4, ~38 min)

- YAML/Kustomize Speed: 4 overlays built clean (prod, dev with generators, block4 label task, stg). Iteration tight on prod (3 cycles to clean apply) — typical Kustomize debug loop
- Tasks Completed: Blocks 3 + 4 done. Block 2 covered via text TL;DW (no Udemy). Block 5 folded into Block 3 (`kubectl kustomize` reps inline)
- Wins (worth remembering):
  - **`kubectl diff -k` iteration loop** (~4 cycles on dev/) — preview-before-apply finally landed as muscle memory
  - **`kubectl kustomize <dir>`** used inline to inspect rendered output without touching the cluster — the right reflex for a tool with no `explain`
  - **`mkdir -p`** picked up immediately and used naturally
- Areas to improve:
  - **`create -k` slipped again** (`kubectl create -k overlays/stg`). This is now the fourth `create -*` slip across Week 3. `apply -k`/`apply -f` is idempotent; `create -*` errors on existing → forces `delete --all` cycle. Single highest-leverage habit to harden for milestone
  - **`kubectl explain kustomization` × 2** — reflex from K8s API discipline. Kustomize is client-side, no API resource, no explain. One-and-done lesson
  - **`apply -k` takes a directory, not a file**: `kubectl apply -k overlays/block4/kustomization.yaml` fails. `-f` is files, `-k` is directories
  - **Imperative resource-name discipline**: `kubectl create deployment --replicas=...` with no name argument (line 7873). Same shape as the Helm `<verb> <release>` and cronjob slips earlier in the week. First positional = resource name, every time
  - **Reaching for `kubectl delete --all` as a workaround** (line 7950) when immutable-selector error hit. The right fix was `labels: [{includeSelectors: false}]` — delete-all worked but masks the lesson
  - **Tried `kustomize edit fix`** (standalone CLI, not installed) and `kubectl kustomize edit fix` (not a real subcommand). Fine outcome (hand-edited), but worth knowing the standalone `kustomize` binary is separate from `kubectl kustomize` and not in scope for CKAD
- Concepts solidified:
  - Base + overlay mental model
  - Modern `labels:` form vs deprecated `commonLabels:` (selector immutability trap)
  - `configMapGenerator`/`secretGenerator` hash-rewrite mechanism (concept only — low exam priority)
  - Generators do nothing unless the base resources reference the logical name (`configMapKeyRef.name: simple-config`); orphan generators just sit in the cluster unused

### Day 5 (Friday May 15)
- YAML Speed: _____ reps clean
- Tasks Completed: ____/____
- Areas to improve:

### Day 6 (Saturday May 17) — Milestone
- Milestone Result: PASS / FAIL
- Tasks Completed: ____/6
- Total Time: _____ min
- Areas to improve:
