# Week 1 — Core Application Concepts

**Focus**: Pods, multi-container patterns, container lifecycle, basic debugging

## Learning Objectives
- Master pod YAML writing from memory
- Understand multi-container patterns (sidecar, init containers)
- Practice task interpretation and requirement mapping
- Begin cross-domain thinking (pods + configuration)

## This Week's Schedule

### Wednesday (Today) - 75 minutes
- **Learning**: Udemy Pods section (30 min)
- **YAML Speed Writing**: Pod YAML from memory (15 min)
- **Task Interpretation Drills**: Read prompts → identify requirements (5 min)
- **Mixed Tasks** (20 min flexible window):
  - Quick: Create simple pod with labels
  - Medium: Multi-container pod (main + sidecar)
- **kubectl explain practice**: pod.spec (5 min)

### Thursday - 75 minutes
- **Learning**: Udemy Multi-Container Pods (30 min)
- **YAML Speed Writing**: Multi-container pod YAML (sidecar + init container variants) (15 min)
- **Task Interpretation Drills** (5 min)
- **Mixed Tasks** (20 min flexible window):
  - Quick: Pod with resource limits
  - Complex: Pod + ConfigMap combination (cross-domain)
- **kubectl explain practice**: pod.spec.containers (5 min)

### Friday - 90 minutes
- **Learning**: Pod Design patterns (35 min)
- **YAML Speed Writing**: Pod + Service YAML (15 min)
- **Task Interpretation Drills** (5 min)
- **Mixed Tasks** (30 min flexible window):
  - 2 Quick tasks: Basic pods with different configs
  - 1 Medium: Multi-container with shared volume
  - 1 Cross-domain: Pod + Service exposure
- **Practice 3-minute skip rule** (5 min)

### Saturday - 2 hours
- **Extended Learning**: Review all Week 1 Udemy sections (45 min)
- **YAML Marathon**: Write 5 different pod variations from memory (25 min)
- **Week 1 Milestone Practice** (20 min flexible window):
  - 2 quick YAML tasks (pods, services)
  - 2 medium tasks (multi-container scenarios)
  - 1 complex cross-domain task (pod + config + service)
- **Troubleshooting practice**: Fix broken pod scenarios (20 min)

### Sunday - 2.5 hours
- **Week 1 Milestone Assessment** (20 min):
  - Complete the full milestone as described in main plan
  - Must include 30-second interpretation per task
- **Deep practice session** (60 min):
  - Variable difficulty tasks mixing all week's concepts
- **YAML fluency test**: Write 10 pods from memory (30 min)
- **Week review and preparation for Week 2** (40 min)

## Daily Requirements

Every session must include:
1. **YAML Speed Writing (15 min)** - PRIMARY FOCUS
2. **Task Interpretation Drills (5 min)**
3. **Mixed atomic tasks with VARIABLE difficulty**
4. **kubectl explain speed lookups (5 min optional)**

## Success Metrics

By end of week, you should:
- [ ] Write pod and service YAML from memory (single-container and multi-container variants)
- [ ] Complete 30% tasks that combine pod + configuration
- [ ] Complete milestone in under 20 minutes
- [ ] Master task interpretation speed (10-15 seconds)
- [ ] Understand multi-container patterns

## Week 1 Milestone (PASS/FAIL)

Complete mixed task set in **20-minute flexible window**:
- 2 quick YAML tasks (pods, services)
- 2 medium tasks (multi-container scenarios)
- 1 complex cross-domain task (pod + config + service)
- Apply 3-minute individual skip rule
- Include 30-second interpretation phase per task

## Practice Files Structure

```
week-1/
├── plan.md (this file)
├── yaml-practice/
│   ├── basic-pods/
│   ├── multi-container/
│   ├── cross-domain/
│   └── milestone-attempts/
├── scripts/
│   └── kubectl-commands.sh
├── milestone-results.md
└── notes.md
```

## Notes

- Focus on YAML accuracy over speed initially
- Practice the 3-minute skip rule religiously
- 30% of tasks should be cross-domain from Day 1
- Task interpretation is as important as execution