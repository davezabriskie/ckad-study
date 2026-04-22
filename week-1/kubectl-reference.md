# Week 1 kubectl Reference

Quick reference commands for pod management and debugging.

## Pod Creation

```bash
# Imperative pod creation
kubectl run my-pod --image=nginx:1.21
kubectl run my-pod --image=nginx:1.21 --labels='tier=frontend'
kubectl run my-pod --image=nginx:1.21 --port=80

# Apply from YAML
kubectl apply -f pod.yaml
```

## Pod Inspection

```bash
# Basic pod info
kubectl get pods
kubectl get pods -o wide
kubectl get pods -o yaml
kubectl describe pod my-pod

# Specific field extraction
kubectl get pod my-pod -o jsonpath='{.status.phase}'
kubectl get pod my-pod -o jsonpath='{.spec.containers[*].image}'
```

## Pod Debugging

```bash
# Logs
kubectl logs my-pod
kubectl logs my-pod -c container-name    # for multi-container
kubectl logs my-pod --previous           # previous container instance

# Execute into containers
kubectl exec -it my-pod -- /bin/bash
kubectl exec -it my-pod -c container-name -- /bin/bash
```

## Pod Management

```bash
# Delete pods
kubectl delete pod my-pod
kubectl delete pod my-pod --force --grace-period=0

# Port forwarding
kubectl port-forward pod/my-pod 8080:80
```

## Learning with kubectl explain

```bash
# Pod structure
kubectl explain pod
kubectl explain pod.spec
kubectl explain pod.spec.containers
kubectl explain pod.spec.containers.resources
kubectl explain pod.metadata

# Container specifications
kubectl explain pod.spec.containers.image
kubectl explain pod.spec.containers.ports
```

## YAML Generation

```bash
# Generate YAML without creating
kubectl run my-pod --image=nginx:1.21 --dry-run=client -o yaml

# Save to file
kubectl run my-pod --image=nginx:1.21 --dry-run=client -o yaml > pod.yaml
```

## Multi-Container Debugging

```bash
# Get pod status
kubectl get pods
kubectl describe pod multi-pod

# Container-specific logs
kubectl logs multi-pod -c container1
kubectl logs multi-pod -c container2

# Execute into specific container
kubectl exec -it multi-pod -c container1 -- /bin/sh
```

## Week 1 Practice Commands

Use these during your daily practice sessions to build muscle memory with pod operations.