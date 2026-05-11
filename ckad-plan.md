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

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Write a ClusterIP service; write a basic Ingress
- **Medium**: Ingress + TLS (add Secret reference); NetworkPolicy allowing specific pod traffic
- **Complex**: Full connectivity debug — broken service, wrong selector, missing endpoint
- **Cross-domain**: NetworkPolicy + Deployment + Service + ConfigMap (full isolated app stack)

## Milestone
Complete networking mix in **25-minute flexible window**:
- 2 quick tasks (service + Ingress, written cold)
- 2 medium cross-domain combinations
- 1 complex connectivity debugging scenario (fix broken access, no hints on what's wrong)
- 1 NetworkPolicy written cold (specific ingress/egress rule)

## Exam Domain Mapping
- Services and Networking (20%): Services, Ingress, NetworkPolicies
- Application Observability and Maintenance (15%): debugging workflows, logs

---

# WEEK 5 — Storage + Resource Management

## Weekly Review (15 min)
**Mixed Sprint**: Scaffold pod + deployment + service; write one Ingress and one NetworkPolicy cold

## Focus
Volumes, PVC/PV, StatefulSets, resource requests/limits, ResourceQuota, LimitRange

## Requirements
- **Scaffold + refine**: Generate pod scaffold, add volume/PVC fields manually
- **PVC and StatefulSet YAML from memory** (no generator shortcut for volumeClaimTemplates)
- Variable complexity storage scenarios
- **Cross-domain focus**: 40% tasks combine storage + other domains
- **Resource management**:
  - `resources.requests` and `resources.limits` in pod specs (CPU + memory)
  - ResourceQuota at namespace level
  - LimitRange: default requests/limits per container
- kubectl explain for storage and resource spec fields

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Scaffold pod + add volume mount; add resource limits to existing Deployment
- **Medium**: StatefulSet + PVC combination with headless service
- **Complex**: Multi-container pod + multiple volume types + resource constraints + NetworkPolicy
- **Cross-domain**: StatefulSet + service + configmap + ResourceQuota

## Milestone
Complete storage + resource mix in **25-minute flexible window**:
- 2 quick tasks (PVC scaffold + resource limits)
- 2 medium cross-domain combinations
- 1 complex stateful application scenario with resource constraints

## Exam Domain Mapping
- Application Design and Build (20%): persistent and ephemeral volumes
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

## Debugging scenarios to include
- Pod stuck in CrashLoopBackOff: wrong command/args override
- Pod stuck Pending: resource limits exceed node capacity
- Service has no endpoints: label selector mismatch
- Forbidden error: missing RoleBinding or wrong ServiceAccount
- PVC stuck Pending: StorageClass mismatch or no available PV
- Probe failing: wrong port or path causing container restart loop

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Fix a broken resource (single issue, no hints)
- **Medium**: Three-domain scaffold + refine + verify running
- **Complex**: Four-domain end-to-end (stateful app + networking + security + config)
- **Break/fix**: Broken application, multiple issues, no guidance on what's wrong

## Milestone
Complete integration challenge in **30-minute flexible window**:
- 2 quick single-domain tasks
- 3 medium cross-domain combinations (2-3 domains each)
- 1 complex end-to-end application (4+ domains, all verified running)
- 1 break/fix scenario with no hints

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
- Day 4: Speed optimization — scaffold + refine cycle under time pressure

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
- Self-mock Day 5: ≥70%, all domains attempted
- killer.sh Session 1: score recorded; target ≥60%
- No single domain below 50% across mock results
- Context switches executed without hesitation

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

## Milestone
- **killer.sh Session 2** (Day 4-5): target ≥65%
- 1 full mock exam ≥80%, all domains
- Finish with ≥15 minutes remaining

---

# USAGE INSTRUCTIONS (for CLI AI agent)

Examples:

- "Generate daily plan for Week 3"
- "Extract Week 6 milestones"
- "List Week 4 failure scenarios"
- "Create a Day 2 schedule from Week 2"
