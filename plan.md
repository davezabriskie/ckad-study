# CKA Study Plan (AI-Driven Weekly Scheduler)

This document defines a structured 9-week preparation plan for the  
Certified Kubernetes Administrator (CKA) certification.

Use this file with an AI agent by referencing:
- "Week N"
- or specific sections like "Week 4 Milestone"

Primary course:
Certified Kubernetes Administrator (CKA) with Practice Tests (Mumshad Mannambeth on Udemy)

---

# GLOBAL RULES (apply when generating daily schedules)

- 60–90 min weekdays, 2–3 hrs weekends
- Every day must include:
  1. Learning (Udemy course sections)
  2. Hands-on labs
  3. Debugging / break-fix scenarios
  4. kubectl command repetition (including jsonpath queries)
  5. Advanced kubectl output formatting practice
- Prefer imperative kubectl over YAML unless necessary
- Start timed drills no later than Week 2 Day 2
- Always include failure scenarios
- Optimize for exam speed + troubleshooting, not passive learning

## Review Integration Rules
- **Week 4+**: Every session starts with 5-min foundation drill from previous weeks
- **Week 6+**: All troubleshooting scenarios must include foundation elements
- **Week 7+**: Mix domains in every exercise (never practice one skill in isolation)
- **Weekly reviews**: Maintain speed on basics while learning advanced topics

Core tools:
- kubectl (CLI mastery is critical)
- jsonpath for complex queries
- Practice environments: killercoda.com, labs.k8s.io, or local cluster

---

# WEEK 1 — Core Kubernetes + First Debugging

## Focus
Pods, Deployments, Services, Namespaces, kubectl basics

## Requirements
- Introduce failure scenarios from Day 1
- Emphasize imperative kubectl commands
- Include debugging using:
  - kubectl describe
  - kubectl logs
  - kubectl get events
- Daily jsonpath practice (5-10 min):
  - Extract specific fields: `kubectl get pods -o jsonpath='{.items[*].metadata.name}'`
  - Filter by conditions
  - Format output for exam speed

## Failure scenarios
- ImagePullBackOff
- CrashLoopBackOff
- Label mismatch causing service failure

## Milestone (PASS/FAIL)
Complete in <15 minutes:
- Create deployment
- Scale to 3 replicas
- Expose service
- Introduce 2 failures (bad image + wrong label)
- Fix both

## Udemy requirement
Use:
- Kubernetes Architecture
- Pods
- Deployments
- Services sections

---

# WEEK 2 — Scheduling + Probes + Resources

## Focus
- Liveness/readiness probes
- Resource limits/requests
- Scheduling (nodeSelector, taints, tolerations)

## Requirements
- Multi-cause failures (not single issue debugging)
- Timed drills from Day 2 onward
- Advanced kubectl queries:
  - Custom columns: `--custom-columns`
  - Resource sorting: `--sort-by`
  - Jsonpath filtering for complex scenarios

## Failure scenarios
- Probe misconfigurations
- Resource exhaustion
- Pod Pending due to scheduling
- Combined failures

## Milestone
Fix 3 broken pods in <20 minutes:
- Pod A: bad probe + wrong image
- Pod B: resource + scheduling issue
- Pod C: label mismatch + service issue

---

# WEEK 3 — Workloads

## Weekly Review (10 min)
**Foundation Speed Drill**: Complete Week 1 milestone in <10 minutes

## Focus
Jobs, CronJobs, DaemonSets, multi-container pods

## Requirements
- Workload selection reasoning
- Include failing Jobs and CronJobs
- Continue timed drills

## Failure scenarios
- Job never completes
- CronJob not triggering
- DaemonSet scheduling issues

## Milestone
In <25 minutes:
- Create CronJob
- Create DaemonSet
- Fix failing Job with multiple issues

---

# WEEK 4 — Networking (HIGH WEIGHT)

## Weekly Review (15 min)
**Foundation Speed Drill**:
- Week 1: Pod/deployment tasks (5 min)
- Week 2: Scheduling/probe fixes (10 min)

## Focus
Services, DNS, Ingress basics, NetworkPolicies

## Requirements
- Deep debugging of connectivity
- Endpoint inspection required
- **Daily foundation drill** (5 min): 1 basic task from Weeks 1-2

## Failure scenarios
- Service selector mismatch
- No endpoints
- DNS resolution failure
- Combined networking failures

## Milestone
Fix broken app in <20 minutes:
- Service misconfigured
- Pod labels wrong
- DNS failing

---

# WEEK 5 — Storage

## Weekly Review (15 min)
**Foundation Integration**: Networking + basic workloads combo
- Deploy app with service + probe issues (from Weeks 1-4)

## Focus
Volumes, PVC/PV, StorageClasses

## Requirements
- Real mounting scenarios
- Binding failures
- **Daily foundation drill** (5 min): 1 basic task from Weeks 1-4

## Failure scenarios
- PVC stuck Pending
- Volume not mounting
- StorageClass mismatch

## Milestone
In <20 minutes:
- Create PVC-backed pod
- Fix PVC + mount issue

---

# WEEK 6 — Cluster Operations (CRITICAL)

## Weekly Review (15 min)
**Services Troubleshooting + Storage**: Combine Week 4-5 concepts
- Fix broken app with service + PVC issues

## Focus
kubeadm, etcd backup/restore, node troubleshooting, cluster upgrades

## Requirements
- Full break/fix scenarios
- No guided steps allowed
- **NEW**: Cluster upgrade scenarios (kubeadm upgrade)
- **Daily foundation drill** (5 min): Speed drill from Weeks 1-5

## Failure scenarios
- Node NotReady
- kubelet failure
- API server issues
- etcd corruption/recovery
- **NEW**: Failed cluster upgrades
- **NEW**: Version skew problems

## Milestone
In <35 minutes:
- Backup etcd
- Restore etcd
- Fix node issue
- Recover control plane component
- **NEW**: Perform cluster upgrade (control plane + worker)

---

# WEEK 7 — Security + RBAC

## Weekly Review (15 min)
**Full Foundation Stack**: End-to-end review
- Deploy app: pods → services → storage → fix cluster issue

## Focus
RBAC, ServiceAccounts, permissions debugging

## Requirements
- Combine RBAC + workload issues
- Continue timed drills
- **Daily foundation drill** (5 min): Mixed domain tasks from Weeks 1-6

## Failure scenarios
- Forbidden errors
- RBAC misconfiguration
- Combined permission + workload issues

## Milestone
In <20 minutes:
- Create RBAC policy
- Fix permission issue
- Fix one cluster issue

---

# WEEK 8 — Full Exam Simulation

## Structure
**Day 1-2: Systematic Foundation Review**
- Day 1: Weeks 1-2 weak spots (pods, deployments, scheduling, probes)
- Day 2: Weeks 3-4 weak spots (workloads, networking)

**Day 3-4: Advanced Concepts Review**
- Day 3: Week 5-6 concepts (storage, cluster operations)
- Day 4: Week 7 concepts (RBAC, security)

**Day 5-7: Full Integration**
- Day 5-7: Mock exams with mixed domains

## Focus
Full mixed-domain scenarios + time management + curriculum validation

## Requirements
- Simulate real exam conditions
- Must include skipping strategy (3-minute rule)
- **NEW**: Cross-reference with official CKA curriculum (cncf.io/certification/cka)
- **NEW**: Verify all domains covered at exam weights:
  - Cluster Architecture: 25%
  - Workloads & Scheduling: 15%
  - Services & Networking: 20%
  - Storage: 10%
  - Troubleshooting: 30%

## Milestone
- 2 full mock exams (Days 6-7)
- ≥75% score
- Successfully skip + return to 2 tasks
- **NEW**: Validate no curriculum gaps using official CKA outline

---

# WEEK 9 — Final Prep

## Focus
Weak areas + speed + repetition + final validation

## Requirements
- No new content
- Focus only on refinement
- **NEW**: Final curriculum cross-check
- **NEW**: Speed drills on weakest domains identified from Week 8

## Milestone
- 1 full mock exam ≥80%
- Finish with ≥15 minutes remaining

---

# USAGE INSTRUCTIONS (for CLI AI agent)

Examples:

- "Generate daily plan for Week 3"
- "Extract Week 6 milestones"
- "List Week 4 failure scenarios"
- "Create a Day 2 schedule from Week 2"
