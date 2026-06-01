# CKAD Study Plan (AI-Driven Weekly Scheduler)

This document defines a structured 9-week preparation plan for the
Certified Kubernetes Application Developer (CKAD) certification.

Use this file with an AI agent by referencing:
- "Week N"
- or specific sections like "Week 4 Milestone"

Primary course:
Kubernetes for the Absolute Beginners + CKAD with Practice Tests (Mumshad Mannambeth on Udemy)

---

# GLOBAL RULES (apply when generating daily schedules)

- 60–90 min weekdays, 2–3 hrs weekends
- Every day must include:
  1. Learning (Udemy course sections)
  2. **kubectl scaffold + refine cycle (15 min) — PRIMARY FOCUS**
  3. Task interpretation drills (5 min)
  4. Mixed atomic tasks with VARIABLE difficulty
  5. **kubectl explain speed lookups (5 min) — MANDATORY**

- **Core technique — kubectl-generated YAML + manual refinement**:
  Generate a scaffold imperatively, output to a file, edit to add fields not produced by the generator.
  This is the primary exam technique — not writing YAML from scratch.
  ```bash
  kubectl run mypod --image=nginx --dry-run=client -o yaml > pod.yaml
  kubectl create deployment myapp --image=nginx --replicas=3 --dry-run=client -o yaml > deploy.yaml
  kubectl create service clusterip mysvc --tcp=80:80 --dry-run=client -o yaml > svc.yaml
  kubectl create configmap mycm --from-literal=key=val --dry-run=client -o yaml > cm.yaml
  kubectl create role myrole --verb=get,list --resource=pods --dry-run=client -o yaml > role.yaml
  ```
  The practice goal: know which fields to add after generation (probes, volumes, securityContext,
  command/args, etc.) and add them quickly without looking them up.

- **Session Structure**: Flexible time windows, not rigid per-task limits
- **Task Mixing**: 30% of tasks must combine 2+ domains
- **Skip Rule**: Stop task if no progress after 3 minutes
- **Variability**: Mix 2-minute "easy" tasks with 8-minute "complex" ones
- Start timed drills no later than Week 2 Day 2
- Optimize for exam speed via scaffold + refine, not passive learning or scratch YAML

## Review Integration Rules
- **Week 2+**: Every session starts with a 15-min scaffold + refine sprint
- **Week 3+**: Task interpretation speed drills before each session
- **Week 4+**: 30% cross-domain tasks minimum
- **Weekly reviews**: Focus on scaffold speed and refinement accuracy

## Milestone Results Convention
- Every week with a milestone assessment generates a `week-N/milestone-results.md` file
- The day-6 (or milestone day) file references it but does not duplicate it
- Results file contains: pass/fail, total time, per-task timing + assessment, gaps to carry forward, what's solid
- Gaps listed in milestone-results.md feed directly into the following week's plan
- Deep practice after the milestone does NOT update the results file — gap closure is tracked in notes.md per-day

Core tools:
- **kubectl --dry-run=client -o yaml** (primary generation technique)
- **Manual YAML editing** in vim — adding fields the generator doesn't produce
- **kubectl explain** — mandatory daily drill; no internet on exam, this is your documentation
- **Imperative kubectl mutations**: label, annotate, set image, patch, edit, scale, rollout
- Practice environments: killercoda.com, labs.k8s.io, or local cluster

---

# WEEK 1 — Core Application Concepts
## Status: COMPLETE

## Focus
Pods, multi-container patterns (sidecar, init), container lifecycle,
probes, command/args overrides, basic debugging

## Topics Covered
- Pod scaffold generation and refinement
- Multi-container pod patterns: sidecar and init containers
- **Probes**: liveness, readiness, startup — httpGet, exec, tcpSocket
- **command/args overrides**: difference between Dockerfile CMD/ENTRYPOINT and pod `command`/`args`
- Basic debugging: kubectl describe, logs, exec
- ConfigMap basics (introduced)
- Service exposure basics (introduced)

## Exam Domain Mapping
- Application Design and Build (20%): pod lifecycle, multi-container patterns

---

# WEEK 2 — Workload Management + Deployment Strategies
## Status: COMPLETE

## Focus
Deployments, ReplicaSets, Jobs, CronJobs, rolling updates, rollbacks,
blue/green and canary patterns, imperative kubectl mutations

## Requirements
- **Scaffold + refine**: Generate all Deployment/Job/CronJob YAML imperatively, then add fields
- Variable task complexity within each session
- Cross-domain mixing: deployment + configuration
- **Remaining days — Deployment strategies**:
  - Blue/green: two Deployments (v1, v2); Service selector switches between them
  - Canary: two Deployments share selector label `app=myapp`; ratio controlled by replica count
- **Imperative kubectl mutations (daily drill)**:
  ```bash
  kubectl set image deployment/web nginx=nginx:1.22
  kubectl scale deployment web --replicas=5
  kubectl rollout undo deployment/web
  kubectl label pod mypod env=prod
  kubectl annotate pod mypod description="my note"
  kubectl patch deployment web -p '{"spec":{"replicas":3}}'
  ```

## Topics to Cover
- Deployment scaffold + refinement (selector/template label relationship)
- Rolling updates: `kubectl rollout status/history/undo`, `kubectl set image`
- Jobs: `completions`, `parallelism`, `restartPolicy: Never/OnFailure`
- CronJobs: `spec.schedule`, relationship to Job
- Blue/green and canary patterns
- Imperative mutation commands as daily practice

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Scale a Deployment; update image imperatively
- **Medium**: Generate Deployment scaffold + add probes + expose as Service
- **Complex**: Implement blue/green switch using two Deployments and one Service
- **Cross-domain**: Deployment + service + ingress combination

## Milestone
Complete mixed workload set in **25-minute flexible window**:
- 3 quick tasks: deployments, scaling, rollback — all via imperative mutations
- 2 medium tasks: scaffold + probe addition + service exposure
- 1 complex task: blue/green or canary pattern from scratch

## Exam Domain Mapping
- Application Deployment (20%): rolling updates, rollbacks, blue/green, canary

---

# WEEK 3 — Application Configuration + Deployment Tooling
## Status: COMPLETE (milestone Fri May 22, 2026 — 4 PASS / 1 FAIL / 1 partial, 38 min exact)

## Weekly Review (10 min)
**Scaffold Sprint**: Generate 3 resource types imperatively + add one non-default field each

## Focus
ConfigMaps, Secrets, environment variables, volume-mounted config, Helm, Kustomize

## Requirements
- **Scaffold + refine**: Generate ConfigMap/Secret imperatively; add volume mounts manually
- All three ConfigMap injection patterns from memory (not from scratch — from a generated pod scaffold):
  - `env` with `valueFrom.configMapKeyRef`
  - `envFrom` with `configMapRef`
  - `volumeMounts` with `volumes.configMap`
- **Cross-domain focus**: 40% of tasks combine config + other domains
- **Helm (Days 1-2)**:
  - `helm repo add`, `helm install`, `helm upgrade --install`
  - Override values: `--set key=value`, `-f values.yaml`
  - `helm list`, `helm get values`, `helm status`, `helm uninstall`
  - Scope: use existing charts — not authoring
- **Kustomize (Days 3-4)**:
  - `kubectl apply -k ./dir`
  - `kustomization.yaml`: `resources`, `commonLabels`, `namePrefix`, `images`
  - Apply a simple overlay that patches a base resource
  - Scope: apply overlays — not designing complex hierarchies

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Generate configmap + inject as env var into existing pod
- **Medium**: Pod scaffold + configmap + secret (env pattern + volume pattern)
- **Complex**: Deploy an app via Helm with custom values; verify pods running and config applied
- **Cross-domain**: Kustomize overlay that patches a Deployment image and adds a label

## Milestone
Complete configuration + tooling mix in **30-minute flexible window**:
- 2 quick tasks (configmap + secret — at least 2 injection patterns)
- 2 medium cross-domain combinations
- 1 Helm install/upgrade task with value overrides
- 1 Kustomize apply task from an overlay

## Exam Domain Mapping
- Application Deployment (20%): Helm, Kustomize
- Application Environment, Configuration and Security (25%): ConfigMaps, Secrets

---

# WEEK 4 — Networking & Services + Debugging

## Weekly Review (15 min)
**Scaffold Sprint**:
- Generate pod + deployment + service imperatively; add one custom field each

## Focus
Services, Ingress (HIGH REPETITION), NetworkPolicies (HIGH REPETITION),
service discovery, connectivity debugging workflows

## Why Ingress and NetworkPolicy get high repetition
These two resource types are never generated cleanly by `kubectl --dry-run`. You must
know their YAML structure from muscle memory. They are high-frequency, easy to get
wrong under time pressure, and have no shortcut.

## Requirements
- **YAML from memory (exception to scaffold rule)**: Ingress and NetworkPolicy only —
  these cannot be generated imperatively; write them directly
- **Cross-domain focus**: 50% of tasks combine networking + other domains
- **Ingress repetition**: minimum 3 Ingress YAML reps per session — path rules, host rules, TLS
- **NetworkPolicy repetition**: minimum 3 NetworkPolicy YAML reps per session —
  ingress rules, egress rules, podSelector, namespaceSelector, combined selectors
- **Selector forms (NEW — covers field-alternates gap)**: at least one NetworkPolicy
  rep per session must use `matchExpressions` (set-based: `In` / `NotIn` / `Exists` /
  `DoesNotExist`) instead of `matchLabels`. Same applies if a Deployment selector task
  comes up. Default has been `matchLabels`; the exam can ask for either
- **Service type variety**: across the week, write at least one each of `ClusterIP`,
  `NodePort`, `LoadBalancer`, and `ExternalName`. `NodePort` and `ExternalName` are the
  surprise picks — know the YAML shape, not just the name
- **Probe type variety**: at least one `exec` probe and one `tcpSocket` probe across
  the week — defaulting to `httpGet` leaves a gap. `exec` is common when there's no
  HTTP endpoint (databases, queue workers); `tcpSocket` for plain TCP services
- **Debugging workflows (Day 3-4)**:
  ```
  Pod not reachable via Service →
    kubectl get endpoints <svc>        # are there endpoints?
    kubectl describe svc <svc>         # selector correct?
    kubectl get pods -l <selector>     # do pods match?
    kubectl describe pod               # is pod Ready?
    kubectl exec -it <pod> -- curl     # is port actually listening?
  ```

## Ingress YAML to know cold
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-svc
            port:
              number: 80
```

## NetworkPolicy YAML to know cold
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-frontend
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
  policyTypes:
  - Ingress
```

## Observability Commands (NEW — addressing 15% domain gap)
Pair with debugging workflows. Day 3 or Day 4 should include a dedicated 30-min block:

```bash
# Logs — depth beyond `kubectl logs <pod>`
kubectl logs <pod> -c <container>           # multi-container pod
kubectl logs <pod> --previous                # last restart's logs
kubectl logs <pod> -f                        # stream
kubectl logs <pod> --tail=50 --since=10m     # filtering

# Resource monitoring (metrics-server required)
kubectl top pods
kubectl top nodes
kubectl top pods --sort-by=cpu

# Event inspection — primary tool for "what just happened"
kubectl get events --sort-by=.lastTimestamp
kubectl get events --field-selector type=Warning
kubectl describe pod <pod>   # Events section at the bottom
```

The exam tests these as part of debugging tasks ("why is this pod not running") — knowing the command flags cold saves time over `kubectl explain` lookups.

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Write a ClusterIP service; write a basic Ingress
- **Medium**: Ingress + TLS (add Secret reference); NetworkPolicy allowing specific pod traffic
- **Complex**: Full connectivity debug — broken service, wrong selector, missing endpoint
- **Cross-domain**: NetworkPolicy + Deployment + Service + ConfigMap (full isolated app stack)
- **Observability**: Find a failing pod using only `kubectl get events` and `kubectl logs --previous` — no other hints

## Milestone
Complete networking + observability mix in **25-minute flexible window**:
- 2 quick tasks (service + Ingress, written cold)
- 2 medium cross-domain combinations
- 1 complex connectivity debugging scenario (fix broken access, no hints on what's wrong)
- 1 NetworkPolicy written cold (specific ingress/egress rule)
- 1 observability task (identify cause of failure using logs/events/top only)

## Exam Domain Mapping
- Services and Networking (20%): Services, Ingress, NetworkPolicies
- Application Observability and Maintenance (15%): debugging workflows, logs, monitoring commands

## Status: COMPLETE (milestone Sun May 31, 2026 — PASS 7/7, ~37 min, conditional on NetworkPolicy authoring)
- Strength: connectivity debugging cold (both stacked faults found). Gap carried to Week 5: cold NetworkPolicy authoring (egress collapsed: spec-as-list + OR/AND peer) and a genuinely-cold Ingress rep. See `week-4/milestone-results.md`.

---

# WEEK 5 — Storage + Resource Management + Container Images

## Weekly Review (15 min)
**Mixed Sprint**: Scaffold pod + deployment + service; write one Ingress and one NetworkPolicy cold

### Kustomize selector + field drill (NEW — carry from W4, the 3-week stumble; reference-open, ~15 min)
Reps against a small base (Deployment `web` + Service `web-svc`, shared `app: web` selector). **Render each with `kubectl kustomize <dir>` before any apply.**
1. `labels:` with `includeSelectors: false` (the default) — label lands on metadata only, selectors untouched. The re-apply-safe form.
2. `labels:` with `includeSelectors: true` — apply **twice**, observe the `spec.selector: field is immutable` error on the Deployment (the trap, on purpose). Explain why in one line.
3. `images:` — bump the running tag via **`newTag: "1.25"`** (the field is `newTag`, NOT `version`/`tag`); `name:` matches the **base image name** (e.g. `nginx`), optional `newName:` swaps repo/name.
4. `namePrefix:`/`nameSuffix:` + `namespace:` + `replicas:` (`- name: web` / `count: 4`) — all from the overlay, base untouched.
5. `configMapGenerator:` from literals (`LOG_LEVEL=debug`, `MAX_CONN=100`) — note the **hash suffix** kustomize appends to the rendered name.

**Selector mechanics cheat** (both toggles default `false`):

| Target | base `pairs:` always | `includeSelectors: true` | `includeTemplates: true` |
|---|:---:|:---:|:---:|
| every `metadata.labels` | ✅ | — | — |
| Deployment `spec.selector` + Service selector | — | ✅ | — |
| pod template labels | — | — | ✅ |

CKAD-safe default = **`includeSelectors: false`** (selectors are immutable → re-apply breaks). Avoid legacy `commonLabels:` (forces selectors true, no opt-out). The `sh -c`/argv rule and this drill are both seeded into the W7 Persistent-Error Ledger.

## Focus
Volumes (persistent + ephemeral), PVC/PV, StatefulSets, resource requests/limits, ResourceQuota, LimitRange, container image build/modify

## Requirements
- **Scaffold + refine**: Generate pod scaffold, add volume/PVC fields manually
- **PVC and StatefulSet YAML from memory** (no generator shortcut for volumeClaimTemplates)
- Variable complexity storage scenarios
- **Cross-domain focus**: 40% tasks combine storage + other domains
- **Resource management**:
  - `resources.requests` and `resources.limits` in pod specs (CPU + memory)
  - ResourceQuota at namespace level
  - LimitRange: default requests/limits per container
- **Ephemeral volumes (NEW — addressing Application Design gap)**:
  - `emptyDir` — pod-lifetime scratch space, also memory-backed (`medium: Memory`)
  - `downwardAPI` — expose pod metadata (labels, annotations, fields) as files
  - `projected` — combine ConfigMap + Secret + downwardAPI + ServiceAccount token into one volume
- **`valueFrom` sources beyond ConfigMap/Secret (NEW — field-alternates gap)**:
  - `fieldRef` — expose pod metadata as an env var (`status.podIP`, `metadata.name`,
    `metadata.namespace`, `spec.nodeName`). The env-var counterpart to `downwardAPI` volumes
  - `resourceFieldRef` — expose container resource limits/requests as env vars
    (e.g. `limits.memory`, `requests.cpu`). Useful for apps that self-tune to limits
  - Pair with at least one drill: pod with `fieldRef` exposing its own IP as `MY_POD_IP`
- **Container image build/modify (NEW — addressing Application Design gap, ~30 min block)**:
  - Dockerfile basics: `FROM`, `RUN`, `COPY`, `CMD`, `ENTRYPOINT`, `EXPOSE`
  - Build: `docker build -t myimage:tag .`
  - Difference between `CMD` and `ENTRYPOINT` — and how Kubernetes pod `command`/`args` override them
  - **`command`/`args` are argv — one token per array element (NEW — carry from W4, recurring 3× slip)**:
    `["sleep","3600"]` ✅, not `["sleep 3600"]` ✗ (the latter seeks a binary literally named
    "sleep 3600"). Quote numeric args (they're strings). Use `sh -c "..."` ONLY for shell features
    (pipe, redirect, `&&`, `$VAR` expansion, globbing) — never to wrap a plain binary + args.
  - Modify an existing Dockerfile, rebuild, push (or `kind load` / `minikube image load` for local clusters)
  - Run the new image in a Pod scaffold
- kubectl explain for storage and resource spec fields

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Scaffold pod + add volume mount; add resource limits to existing Deployment; add an `emptyDir` to a pod
- **Medium**: StatefulSet + PVC combination with headless service; pod with `downwardAPI` exposing pod name as a file
- **Complex**: Multi-container pod + multiple volume types + resource constraints + NetworkPolicy
- **Cross-domain**: StatefulSet + service + configmap + ResourceQuota
- **Image build**: Modify a provided Dockerfile (e.g. change base image or entrypoint), rebuild, run in a pod

## Milestone
Complete storage + resource + image mix in **30-minute flexible window**:
- 2 quick tasks (PVC scaffold + resource limits)
- 1 ephemeral volume task (`emptyDir` or `downwardAPI`)
- 1 medium cross-domain combination
- 1 complex stateful application scenario with resource constraints
- 1 image task (modify Dockerfile + rebuild + run)

## Exam Domain Mapping
- Application Design and Build (20%): persistent + ephemeral volumes, container image build/modify
- Application Environment, Configuration and Security (25%): resource requests, limits, quotas

---

# WEEK 6 — Security & Environment

## Weekly Review (15 min)
**Security Scaffold Drill**:
- Generate pod scaffold + add SecurityContext fields cold
- Generate Role + RoleBinding + ServiceAccount cold (no scaffold for Role — write directly)

## Focus
SecurityContexts, Capabilities, RBAC (Roles/ClusterRoles/RoleBindings),
ServiceAccounts, CRD awareness (light)

## Why this week is a full week
Application Environment, Configuration and Security is **25% of the exam** — the largest domain.
RBAC and SecurityContexts appear in most complex exam scenarios.

## Requirements
- **Scaffold + refine for pods**: Generate pod scaffold, add securityContext block manually
- **YAML cold for RBAC**: Role, RoleBinding, ClusterRole, ClusterRoleBinding — no generator produces
  a useful scaffold; know the structure directly
- **SecurityContext fields to add to any pod scaffold**:
  ```yaml
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
      add: ["NET_ADMIN"]
  ```
- **CRD awareness (light — one session only)**:
  - `kubectl get crd` and `kubectl describe crd`
  - Create a resource of a custom type from a given spec
  - No Operator theory required
- **Cross-domain focus**: 50% tasks combine security + other domains
- kubectl explain for all security spec fields

## RBAC scope
- Role: namespace-scoped; specific verbs (get/list/create/delete) on specific resources
- ClusterRole: cluster-wide permissions
- RoleBinding: bind Role or ClusterRole to a ServiceAccount in a namespace
- ServiceAccount: create and mount to a pod (`spec.serviceAccountName`)
- Debug Forbidden: `kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<ns>:<sa>`

## Admission Control Awareness (NEW — addressing Config/Security gap, ~15 min)
- Admission controllers run after authentication/authorization, before persistence — they can reject or mutate requests
- Common ones that affect CKAD scenarios:
  - **ResourceQuota** — enforces namespace-level quotas (already covered in Week 5)
  - **LimitRanger** — applies default requests/limits when missing (already covered in Week 5)
  - **NamespaceLifecycle** — prevents creating resources in terminating namespaces
- Scope for exam: recognize when an admission controller is rejecting a request (e.g. "exceeded quota" errors), not configure them
- Quick drill: create a pod that violates a ResourceQuota, observe the rejection message

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Add SecurityContext to generated pod scaffold; create ServiceAccount
- **Medium**: Role + RoleBinding + ServiceAccount wired to a Deployment
- **Complex**: Pod with SecurityContext + dropped capabilities + non-default ServiceAccount + RBAC
- **Cross-domain**: Deployment + ConfigMap + RBAC + ServiceAccount + NetworkPolicy

## Milestone
Complete security mix in **30-minute flexible window**:
- 2 quick tasks (SecurityContext addition + ServiceAccount)
- 2 medium RBAC combinations (Role + RoleBinding + ServiceAccount)
- 1 complex end-to-end security scenario
- 1 CRD task (create a resource of a custom type from a given spec)

## Exam Domain Mapping
- Application Environment, Configuration and Security (25%): all of it

---

# WEEK 7 — Integration, Debugging & Review

## Weekly Review (15 min)
**Full Sprint**: Scaffold pod + deployment + service; write Ingress + NetworkPolicy + Role + RoleBinding cold

## Focus
Mixed domain atomic tasks, speed optimization, debugging workflows at full complexity

## Requirements
- **Scaffold + refine** for all generatable resources; cold write for Ingress, NetworkPolicy, RBAC
- **Cross-domain intensive**: 60% tasks combine 3+ domains
- **Debugging emphasis**: every session includes at least one break/fix scenario with no hints
- All 5 exam domains must appear in this week's tasks
- kubectl explain — target <20 seconds per lookup
- **Context-switch discipline (NEW — meta-skill gap)**: every task begins with its
  `kubectl config use-context <ctx>` line. A forgotten context switch = correct work on
  the wrong cluster = automatic zero. By end of W7 this is reflexive, not a checklist item
- **Full-length conditioning (NEW)**: at least one 90+ min uninterrupted integration block
  this week to build stamina before the Day 5 mock — the jump from 35-min milestones to a
  2-hour exam is the real shock, not the task difficulty

## Exam-Craft Rituals (NEW — addressing meta-skill gap; establish this week)

These are the points marginal candidates lose *despite knowing the material*. Drill until automatic.

### 1. Context + namespace first, every single task
```bash
kubectl config use-context <task-context>                  # FIRST line of every task — no exceptions
kubectl config set-context --current --namespace=<ns>      # if the task pins a namespace
```
Forgetting the context = zero credit on otherwise-correct work. A namespace miss = resources land
in `default` = also zero (this already bit Week 4 Day 4). Make the context line muscle memory.

### 2. Terminal setup ritual (first 60 seconds of the exam)
Set once at exam start; pays for itself within three tasks. Automation belongs **here** — after
mastery, not as a learning crutch.
```bash
alias k=kubectl
export do='--dry-run=client -o yaml'        # k run x --image=nginx $do > x.yaml
export now='--force --grace-period=0'        # k delete pod x $now
source <(kubectl completion bash)            # tab-completion
```
vim — the YAML indentation footgun (a stray tab breaks the whole manifest):
```vim
" ~/.vimrc
set expandtab tabstop=2 shiftwidth=2
set number
```
Drill the full setup cold until it takes under a minute.

### 3. Docs-navigation drill (the docs are open — use them fast)
kubernetes.io is allowed in the exam browser; speed at finding the copy-paste YAML is trainable.
- Curate a bookmark set: Pod spec, Ingress, NetworkPolicy, RBAC, SecurityContext, volumes, Kustomize.
- Drill: "find the `<resource>` example and copy it in <30 seconds." Time it.

## Persistent-Error Ledger (NEW — kills recurring mistakes)

Per-week gap carry has NOT retired the sticky errors (literal-name slips: 7+ across W3–W4;
Kustomize selector trap: 3 weeks running). Add a spaced-repetition mechanism:

- Maintain a running ledger (`persistent-errors.md`) of any error that has recurred **2+ times**.
- At the **start of every session W7–W9**, spend 60 seconds drilling the ledger items cold.
- An item graduates off the ledger after **3 consecutive clean sessions** (no recurrence).
- Ledger seed (from W3–W4 notes):
  1. Literal prompt-name discipline (`metadata.name` exact — hyphens + word order)
  2. Kustomize `includeSelectors: false` + `includeTemplates: true` on the `labels:` transformer
  3. `-f` (file) vs `-k` (directory)
  4. Namespace discipline (set context, verify resources land where intended)
  5. `command`/`args` argv tokenization — bare `["sleep","3600"]`; `sh -c` only for shell features (3× across W4)

## Debugging scenarios to include
- Pod stuck in CrashLoopBackOff: wrong command/args override
- Pod stuck Pending: resource limits exceed node capacity
- Service has no endpoints: label selector mismatch
- Forbidden error: missing RoleBinding or wrong ServiceAccount
- PVC stuck Pending: StorageClass mismatch or no available PV
- Probe failing: wrong port or path causing container restart loop

## Integration Topics (NEW — addressing remaining curriculum gaps)

### DaemonSet (Application Design and Build, 20% domain)
~30 min block. Workload resource for running one pod per node — system agents, log collectors, network plugins.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-agent
spec:
  selector:
    matchLabels:
      app: log-agent
  template:
    metadata:
      labels:
        app: log-agent
    spec:
      containers:
        - name: agent
          image: busybox
          command: ['sh', '-c', 'tail -f /var/log/syslog']
```

Key facts:
- No `replicas` field — one pod per matching node, scheduler-driven
- `nodeSelector` or `affinity` controls which nodes get the pod
- Tolerations often needed to run on tainted nodes (e.g. control plane)

### API Deprecations (Observability and Maintenance, 15% domain)
~20 min block. The exam may give you a manifest using a deprecated API and ask you to migrate it.

```bash
# Check what's available
kubectl api-versions

# Common deprecated → current migrations:
# extensions/v1beta1 Deployment        → apps/v1 Deployment
# extensions/v1beta1 Ingress           → networking.k8s.io/v1 Ingress
# policy/v1beta1 PodSecurityPolicy     → removed (Pod Security Admission instead)
# autoscaling/v2beta2 HPA              → autoscaling/v2 HPA

# Convert a manifest
kubectl convert -f old-manifest.yaml --output-version apps/v1   # if kubectl-convert installed
```

Drill: take a deprecated manifest, identify what to change, apply the migrated version.

### Ambassador & Adapter Multi-Container Patterns (NEW — App Design gap, ~15 min)
W1 covered sidecar + init; the official curriculum lists all four. Close the gap:
- **Ambassador** — a proxy container brokering the main container's outbound connections (e.g. a
  localhost proxy to a sharded DB). The app talks to `localhost:<port>`; the ambassador handles routing.
- **Adapter** — a container that transforms the main container's output into a standard format
  (e.g. reshaping app logs/metrics for a scraper).

Both are just multi-container Pods sharing an `emptyDir` or `localhost` networking — no new API.
Drill: one Pod with a main container + an adapter sidecar tailing/transforming a shared log file.

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Fix a broken resource (single issue, no hints); DaemonSet from scaffold
- **Medium**: Three-domain scaffold + refine + verify running; migrate a deprecated API manifest
- **Complex**: Four-domain end-to-end (stateful app + networking + security + config)
- **Break/fix**: Broken application, multiple issues, no guidance on what's wrong

## Milestone
Complete integration challenge in **35-minute flexible window**:
- 2 quick single-domain tasks (one of which is DaemonSet or API migration)
- 3 medium cross-domain combinations (2-3 domains each)
- 1 complex end-to-end application (4+ domains, all verified running)
- 1 break/fix scenario with no hints
- **Time trendline**: record target (35 min) vs actual; compare against W2–W6 milestone times.
  Times should be converging downward — if they aren't, speed is the explicit W8–W9 priority

## Day 5 — Udemy Mock Exam (KodeKloud)
Run one of the full mock exams from the Mumshad CKAD course (KodeKloud platform).
Timed, no outside resources, treat it as a real exam attempt.

After completion:
- Record score per domain (KodeKloud shows breakdown)
- List every task you skipped or got wrong
- This feeds directly into Week 8's targeted review — don't skip the post-mortem

**Why Day 5 of Week 7, not Week 8**: All 5 domains are covered by end of Week 6.
Running the mock here gives a full week of targeted drilling before killer.sh.

---

# WEEK 8 — Full Application Simulation

## Structure
**Day 1-2: Targeted Review from Week 7 Mock Results**
- Day 1: Drill the lowest-scoring domain from the Udemy mock
- Day 2: Drill second-lowest domain + any individual tasks missed

**Day 3-4: Full-Stack Integration**
- Day 3: Cross-domain scenarios covering all 5 domains
- Day 4: Speed optimization — scaffold + refine cycle under time pressure; close with a
  self-mock (≥70%, all domains) as the conditioning rep before killer.sh

**Day 5-7: killer.sh**
- Day 5: **killer.sh Session 1** — official CKAD simulator bundled with exam purchase
- Day 6: Review killer.sh results; drill lowest-scoring domain
- Day 7: Final mixed scenarios based on killer.sh weak spots

## Requirements
- Simulate real exam conditions: remote desktop, timed, no outside resources
- Multi-context navigation: `kubectl config use-context` between task clusters
- Cross-reference with official CKAD curriculum; verify all domains covered:
  - Application Design and Build: 20%
  - Application Deployment: 20%
  - Application Observability and Maintenance: 15%
  - Application Environment, Configuration and Security: 25%
  - Services and Networking: 20%
- **killer.sh is harder than the real exam by design** — treat score as a floor, not a ceiling

## Milestone
- Self-mock (Day 4): ≥70%, all domains attempted
- killer.sh Session 1 (Day 5): score recorded; target ≥60%
- No single domain below 50% across mock results
- Context switches executed without hesitation (the W7 ritual, now under exam conditions)

---

# WEEK 9 — Final Prep

## Focus
Weak areas from Week 8 + speed refinement + final validation

## Requirements
- No new content
- Drill the domain(s) where Week 8 score was weakest
- Intensive Ingress + NetworkPolicy cold-write reps if either was weak
- kubectl explain target: <15 seconds per lookup
- Scaffold + refine cycle target: pod with probes + securityContext in <4 minutes
- **Setup-ritual target**: full terminal + vim + alias setup (the W7 ritual) cold in <60 seconds
- **Persistent-error ledger must be empty** — every item cleared (3 clean sessions) before exam day.
  Anything still on it is your exam-morning warm-up

## Exam-Day Logistics (NEW — do not discover these during the exam)
- PSI/proctor: ID ready, room scan, single monitor, clear desk — verify requirements the night before
- The exam terminal is a browser; copy-paste is finicky — use the provided paste and watch for mangled YAML
- You get a bookmarked kubernetes.io tab set — confirm your bookmarks are in place before starting
- **Flag-and-skip strategy**: read all tasks first, do high-weight/cheap tasks first, flag the rest.
  Partial credit counts — never leave a task fully blank
- Run a short logistics dry-run (login flow, terminal feel) if the killer.sh environment allows

## Milestone
- **killer.sh Session 2** (Day 4-5): target ≥65%
- 1 full mock exam ≥80%, all domains
- Finish with ≥15 minutes remaining
- Logistics dry-run completed — no exam-day surprises

---

# USAGE INSTRUCTIONS (for CLI AI agent)

Examples:

- "Generate daily plan for Week 3"
- "Extract Week 6 milestones"
- "List Week 4 failure scenarios"
- "Create a Day 2 schedule from Week 2"
