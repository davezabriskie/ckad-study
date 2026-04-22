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
  2. **YAML speed writing (15 min) - PRIMARY FOCUS**
  3. Task interpretation drills (5 min)
  4. Mixed atomic tasks with VARIABLE difficulty
  5. kubectl explain speed lookups (5 min optional)

- **Session Structure**: Flexible time windows, not rigid per-task limits
- **Task Mixing**: 30% of tasks must combine 2+ domains
- **Skip Rule**: Stop task if no progress after 3 minutes
- **Variability**: Mix 2-minute "easy" tasks with 8-minute "complex" ones
- Start timed drills no later than Week 2 Day 2
- Optimize for exam speed + YAML fluency, not passive learning

## Review Integration Rules
- **Week 2+**: Every session starts with 15-min YAML sprint (PRIMARY)
- **Week 3+**: Task interpretation speed drills before each session
- **Week 4+**: 30% cross-domain tasks minimum
- **Weekly reviews**: Focus on YAML fluency and interpretation speed

Core tools:
- **YAML writing from memory (80% of practice time)**
- kubectl imperative commands (20% of practice time)
- kubectl explain for quick reference
- Practice environments: killercoda.com, labs.k8s.io, or local cluster
- Focus: YAML fluency + task interpretation speed

---

# WEEK 1 — Core Application Concepts

## Focus
Pods, multi-container patterns, container lifecycle, basic debugging

## Requirements
- Introduce variable task difficulty from Day 1
- **PRIMARY**: YAML writing from memory (deployment, pod, service)
- Include task interpretation training:
  - Read task prompt aloud
  - Identify key requirements (10-15 seconds)
  - Map to YAML structure before writing
- **NEW**: 30% tasks combine pod + configuration concepts

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick (2-3 min)**: Create simple pod from memory
- **Medium (4-6 min)**: Create multi-container pod with specific labels/annotations
- **Complex (7-10 min)**: Pod + configmap + resource limits combination
- **Cross-domain**: Pod with service exposure (pod + networking)

## Milestone (PASS/FAIL)
Complete mixed task set in **20-minute flexible window**:
- 2 quick YAML tasks (pods, services)
- 2 medium tasks (multi-container scenarios)
- 1 complex cross-domain task (pod + config + service)
- Apply 3-minute individual skip rule
- **NEW**: Include 30-second interpretation phase per task

## Udemy requirement
Use:
- Pods
- Multi-Container Pods
- Pod Design sections

---

# WEEK 2 — Workload Management

## Focus
Deployments, ReplicaSets, Jobs, CronJobs, rolling updates, rollbacks

## Requirements
- **YAML Priority**: 80% time on YAML writing, 20% on kubectl commands
- Variable task complexity within each session
- Cross-domain mixing: deployment + configuration
- Speed documentation lookup (kubectl explain deployment.spec)

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Update deployment image via YAML
- **Medium**: Create deployment + service + configmap from memory
- **Complex**: Deployment with multiple containers + init container + probes
- **Cross-domain**: Deployment + service + ingress combination

## Milestone
Complete mixed workload set in **25-minute flexible window**:
- 3 quick tasks: Basic deployments and scaling
- 2 medium tasks: Multi-component workloads
- 1 complex task: Full deployment stack
- **NEW**: Use kubectl explain for 1-2 quick references
- **NEW**: Each task starts with 15-second interpretation drill

---

# WEEK 3 — Application Configuration

## Weekly Review (10 min)
**YAML Speed Drill**: Write 3 YAML files from memory in <10 minutes

## Focus
ConfigMaps, Secrets, Environment Variables, volume mounting for config

## Requirements
- **YAML mastery**: ConfigMap and Secret YAML from memory
- Variable difficulty configuration scenarios
- **Cross-domain focus**: 40% of tasks combine config + other domains
- Quick kubectl explain usage for configuration specs

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Create configmap from literals via YAML
- **Medium**: Pod + configmap + secret combination
- **Complex**: Multi-container pod with different config sources
- **Cross-domain**: Deployment + configmap + service (full app config)

## Milestone
Complete configuration mix in **25-minute flexible window**:
- 2 quick YAML tasks (configmap, secret creation)
- 3 medium cross-domain combinations
- 1 complex multi-component configuration scenario
- **NEW**: Include kubectl explain for config specifications
- **NEW**: Task interpretation phase (15 seconds per task)

---

# WEEK 4 — Networking & Services (HIGH WEIGHT)

## Weekly Review (15 min)
**YAML Speed Drill**:
- Week 1: Pod and service YAML (5 min)
- Week 2: Deployment and job YAML (10 min)

## Focus
Services, Ingress, NetworkPolicies, service discovery, application connectivity

## Requirements
- **YAML mastery**: Service and Ingress YAML from memory
- **Cross-domain focus**: 50% of tasks combine networking + other domains
- Variable difficulty to simulate exam unpredictability
- Quick kubectl explain usage for networking concepts

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Expose deployment via service YAML
- **Medium**: Service + ingress + TLS configuration
- **Complex**: NetworkPolicy + service + pod + troubleshooting
- **Cross-domain examples**:
  - Service + ConfigMap (service configuration)
  - Ingress + Secret (TLS certificates)
  - NetworkPolicy + Deployment + Service (full stack)

## Milestone
Complete networking mix in **25-minute flexible window**:
- 2 quick service/exposure tasks
- 2 medium cross-domain combinations
- 1 complex multi-component networking scenario
- **NEW**: Include kubectl explain usage for networking specs
- **NEW**: Task interpretation phase (15 seconds per task)

---

# WEEK 5 — Persistence & Storage

## Weekly Review (15 min)
**YAML Integration**: Cross-domain YAML writing
- Write 4 different YAML files that work together (pod + config + service + storage)

## Focus
Volumes, PVC/PV, StatefulSets, persistent application data

## Requirements
- **YAML mastery**: PVC and StatefulSet YAML from memory
- Variable complexity storage scenarios
- **Cross-domain focus**: 40% tasks combine storage + other domains
- kubectl explain usage for storage specifications

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Create PVC from memory
- **Medium**: StatefulSet + PVC combination
- **Complex**: Multi-container pod with multiple volume types
- **Cross-domain**: StatefulSet + service + configmap (stateful application)

## Milestone
Complete storage mix in **22-minute flexible window**:
- 2 quick YAML tasks (PVC, basic volume mount)
- 2 medium cross-domain combinations
- 1 complex stateful application scenario
- **NEW**: Use kubectl explain for storage specs
- **NEW**: Task interpretation training (15 seconds per task)

---

# WEEK 6 — Advanced Application Patterns

## Weekly Review (15 min)
**Complex YAML Drill**: Advanced patterns from memory
- Write init container + probes + resources YAML without reference

## Focus
Init containers, sidecar patterns, probes (liveness/readiness/startup), resource management

## Requirements
- **YAML mastery**: Advanced pod patterns from memory
- Variable complexity probe and resource scenarios
- **Cross-domain focus**: 50% tasks combine advanced patterns + other domains
- kubectl explain for advanced pod specifications

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Add probes to existing deployment YAML
- **Medium**: Init container + main container + resource limits
- **Complex**: Multi-container + probes + shared volumes + resources
- **Cross-domain**: Advanced deployment + service + config integration

## Milestone
Complete advanced patterns in **28-minute flexible window**:
- 2 quick probe/resource tasks
- 3 medium multi-container scenarios
- 1 complex cross-domain advanced application
- **NEW**: Heavy kubectl explain usage for complex specifications
- **NEW**: Extended task interpretation (20 seconds for complex tasks)

---

# WEEK 7 — Integration & Review

## Weekly Review (15 min)
**Master YAML Sprint**: All core patterns
- Write 6 different YAML types from memory without reference (pod, deployment, service, configmap, pvc, ingress)

## Focus
Mixed domain atomic tasks, speed optimization, advanced pod patterns

## Requirements
- **YAML mastery**: All core resource types from memory
- **Cross-domain intensive**: 60% tasks combine 3+ domains
- Variable difficulty with emphasis on complex scenarios
- Heavy kubectl explain usage for speed and accuracy

## Mixed task types (VARIABLE DIFFICULTY)
- **Quick**: Security context or RBAC basics via YAML
- **Medium**: Three-domain combinations (deployment + config + service)
- **Complex**: Four-domain integrations (stateful app + networking + security + config)
- **Cross-domain intensive**: End-to-end application scenarios

## Milestone
Complete integration challenge in **30-minute flexible window**:
- 2 quick single-domain YAML tasks
- 3 medium cross-domain combinations (2-3 domains each)
- 1 complex end-to-end application (4+ domains)
- **NEW**: Extensive kubectl explain usage (expect 5-8 lookups)
- **NEW**: Variable interpretation time (15-30 seconds based on complexity)

---

# WEEK 8 — Full Application Simulation

## Structure
**Day 1-2: Systematic Foundation Review**
- Day 1: Weeks 1-2 weak spots (pods, containers, workloads)
- Day 2: Weeks 3-4 weak spots (configuration, networking)

**Day 3-4: Advanced Application Review**
- Day 3: Week 5-6 concepts (storage, advanced patterns)
- Day 4: Week 7 concepts (integration tasks, speed optimization)

**Day 5-7: Full Integration**
- Day 5-7: End-to-end YAML-based application scenarios with maximum cross-domain mixing

## Focus
Full application lifecycle scenarios + YAML fluency validation + curriculum alignment

## Requirements
- Simulate real exam conditions with YAML-heavy focus
- Must include variable task timing and cross-domain mixing
- **NEW**: Cross-reference with official CKAD curriculum (cncf.io/certification/ckad)
- **NEW**: Verify all domains covered at exam weights:
  - Application Design and Build: 20%
  - Application Deployment: 20%
  - Application Observability and Maintenance: 15%
  - Application Environment, Configuration and Security: 25%
  - Services and Networking: 20%
- **NEW**: Heavy kubectl explain usage simulation

## Milestone
- 2 full mock exams (Days 6-7) with variable task difficulty
- ≥75% score with emphasis on YAML speed
- Successfully manage time across mixed-complexity tasks
- **NEW**: Validate YAML fluency across all resource types
- **NEW**: Confirm kubectl explain speed and accuracy

---

# WEEK 9 — Final Prep

## Focus
Weak areas + speed + repetition + final validation

## Requirements
- No new content
- Focus only on YAML speed refinement and cross-domain fluency
- **NEW**: Final curriculum cross-check
- **NEW**: Intensive YAML sprints on weakest resource types from Week 8
- **NEW**: Maximum kubectl explain efficiency training
- Practice variable-difficulty scenarios under time pressure

## Milestone
- 1 full mock exam ≥80% with heavy YAML emphasis
- Finish with ≥15 minutes remaining
- Write 10 different YAML resource types from memory in <20 minutes
- Complete complex cross-domain scenario in <45 minutes using kubectl explain strategically

---

# USAGE INSTRUCTIONS (for CLI AI agent)

Examples:

- "Generate daily plan for Week 3"
- "Extract Week 6 milestones"
- "List Week 4 failure scenarios"
- "Create a Day 2 schedule from Week 2"