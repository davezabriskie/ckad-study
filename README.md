# CKAD Study Repository

This repository contains my 9-week study plan and practice materials for the Certified Kubernetes Application Developer (CKAD) certification.

## Structure

- `ckad-plan.md` - Complete 9-week study plan
- `week-X/` - Weekly practice materials
- `resources/` - Shared reference materials

## Study Approach

- **Primary Technique**: `kubectl --dry-run=client -o yaml` scaffold + manual refinement
- **Cross-domain Tasks**: Combining multiple Kubernetes concepts
- **Variable Difficulty**: Mixing quick (2-3 min) and complex (7-10 min) tasks
- **Time Pressure Training**: 3-minute skip rule with flexible windows

## Weekly Progress

- [X] Week 1 - Core Application Concepts
- [X] Week 2 - Workload Management
- [X] Week 3 - Application Configuration + Deployment Tooling
- [X] Week 4 - Networking & Services (milestone PASS 7/7, May 31)
- [ ] Week 5 - Storage + Resource Management + Container Images (in progress — Day 1 done)
- [ ] Week 6 - Advanced Application Patterns
- [ ] Week 7 - Integration & Review
- [ ] Week 8 - Full Application Simulation
- [ ] Week 9 - Final Prep

## Practice Environment

- Primary: local **kind** cluster (Calico CNI as of W5 — NetworkPolicy enforced; metrics-server installed)
- Secondary: killercoda.com, labs.k8s.io
- Course: Kubernetes for the Absolute Beginners + CKAD with Practice Tests (Mumshad Mannambeth)

---

🎯 **Goal**: Pass CKAD certification with focus on real-world application development skills