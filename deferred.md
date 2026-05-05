# Deferred Topics

Topics that are out of scope for the CKAD exam or current study phase, but worth revisiting for real-world EKS work.

---

## Blue/Green and Canary in Real EKS (vs CKAD approach)

**What the exam teaches**: Swap a Service selector between two Deployments (blue/green), or share a label across two Deployments and ratio traffic by replica count (canary). This is pure Kubernetes — no external dependencies.

**What you'd actually do in EKS prod**:

Traffic splitting in real EKS is handled at the load balancer level, not the Service level.

### Blue/Green via AWS Load Balancer Controller
```yaml
# Two target groups, one ALB Ingress
# Switch by changing which target group is "primary" in the Ingress annotation
alb.ingress.kubernetes.io/actions.blue-green: |
  {"type":"forward","forwardConfig":{"targetGroups":[
    {"serviceName":"web-v1","servicePort":"80","weight":100},
    {"serviceName":"web-v2","servicePort":"80","weight":0}
  ]}}
```
To cut over: update weights to `0` / `100` and re-apply. Instant, no pod changes needed.

### Canary via AWS Load Balancer Controller
Same pattern — set weights to `90` / `10` for a 10% canary, adjust as confidence grows.

### Why this is better than the K8s-native approach
- **Exact percentages**: replica ratio is approximate (3+1 = 75/25 but load isn't perfectly distributed). ALB weights are precise.
- **No pod count games**: you don't scale down prod replicas to increase canary ratio.
- **Instant rollback**: flip the weight to 0, done. No selector patching.
- **Connection draining**: ALB handles graceful draining; Service selector switch is abrupt.

### When the K8s-native pattern still matters
- Clusters without an Ingress controller or ALB
- Exam (no AWS-specific resources available)
- Simple internal service-to-service traffic (no ingress involved)

**Bottom line**: Know the K8s-native pattern for the exam. In your EKS env, reach for ALB weighted target groups.

---

## Topics to Add

> Add future deferred topics here as they come up during study.