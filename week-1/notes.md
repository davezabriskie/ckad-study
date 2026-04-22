# Week 1 Study Notes

## Key Concepts

### Pod Basics
- Smallest deployable unit in Kubernetes
- Can contain one or more containers
- Containers share network and storage
- Ephemeral by nature

### Multi-Container Patterns
1. **Sidecar**: Helper container alongside main container
2. **Init Container**: Runs before main container starts
3. **Adapter**: Modifies output of main container
4. **Ambassador**: Proxy connections for main container

### Essential YAML Structure

#### Basic Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  labels:
    app: my-app
spec:
  containers:
  - name: my-container
    image: nginx:1.21
    ports:
    - containerPort: 80
```

#### Multi-Container Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-pod
spec:
  containers:
  - name: main-app
    image: nginx:1.21
  - name: sidecar
    image: busybox
    command: ['sh', '-c', 'while true; do echo sidecar; sleep 30; done']
```

## kubectl Commands for Week 1

### Pod Management
```bash
# Create pod from YAML
kubectl apply -f pod.yaml

# Create pod imperatively
kubectl run my-pod --image=nginx:1.21

# Get pod details
kubectl get pods -o wide
kubectl describe pod my-pod

# Pod logs
kubectl logs my-pod
kubectl logs my-pod -c container-name  # for multi-container

# Execute into pod
kubectl exec -it my-pod -- /bin/bash
kubectl exec -it my-pod -c container-name -- /bin/bash  # for multi-container
```

### kubectl explain Practice
```bash
# Pod specification
kubectl explain pod.spec
kubectl explain pod.spec.containers
kubectl explain pod.spec.containers.resources

# Learn field requirements
kubectl explain pod.spec.containers.name
```

## Task Interpretation Practice

### Sample Prompts and Analysis

**Prompt**: "Create a pod named 'web-server' running nginx:1.21 with label 'tier=frontend' and exposed on port 80"

**Interpretation (15 seconds)**:
- Resource: Pod
- Name: web-server
- Image: nginx:1.21
- Label: tier=frontend
- Port: 80

**YAML Structure**:
- metadata.name
- metadata.labels
- spec.containers[].name
- spec.containers[].image
- spec.containers[].ports

## Common Mistakes to Avoid
1. Forgetting apiVersion and kind
2. Incorrect indentation in YAML
3. Missing required fields (name, image)
4. Not reading the prompt carefully
5. Spending too long on stuck tasks (use 3-min skip rule!)

## Daily Progress Tracking

### Day 1 (Wednesday)
- YAML Speed: ___/10 pods in 15 minutes
- Interpretation Speed: _____ seconds average
- Tasks Completed: ____/____
- Areas to improve:

### Day 2 (Thursday)
- YAML Speed: ___/10 pods in 15 minutes
- Interpretation Speed: _____ seconds average
- Tasks Completed: ____/____
- Areas to improve:

### Day 3 (Friday)
- YAML Speed: ___/10 pods in 15 minutes
- Interpretation Speed: _____ seconds average
- Tasks Completed: ____/____
- Areas to improve:

### Day 4 (Saturday)
- YAML Speed: ___/10 pods in 15 minutes
- Interpretation Speed: _____ seconds average
- Tasks Completed: ____/____
- Areas to improve:

### Day 5 (Sunday)
- YAML Speed: ___/10 pods in 15 minutes
- Interpretation Speed: _____ seconds average
- Milestone Result: PASS/FAIL
- Week 1 Completion: _____%