# Nextflow Jobs - Manual Execution Guide

## Overview

This setup converts the Nextflow Job controller to a Pod-based approach, allowing you to SSH into the container and manually execute the Nextflow pipeline.

## Step-by-Step Workflow

### 1. Current Setup Analysis

The original setup used a Kubernetes Job that:
- Installed kubectl automatically
- Set up workspace with PVC
- Copied pipeline files from ConfigMap
- Automatically ran `nextflow run fibo-jobs.nf -c nextflow.config`
- Monitored created jobs

### 2. New Pod-Based Setup

The new setup uses a Pod that:
- Installs kubectl automatically
- Sets up workspace with PVC
- Copies pipeline files from ConfigMap
- **Keeps the container alive** for manual access
- **Waits for you to manually run the Nextflow command**

### 3. Deployment Steps

#### Deploy the Pod
```bash
./deploy.sh
```

This will:
- Create the `nextflow` namespace
- Create the PVC `nextflow-workspace`
- Apply RBAC configuration
- Apply ConfigMap with pipeline files
- Deploy the controller Pod
- Wait for the Pod to be ready

#### Access the Pod
```bash
kubectl exec -it nextflow-controller -n nextflow -- /bin/bash
```

#### Manual Execution Inside Pod
Once inside the pod, navigate to the project directory and run the pipeline:

```bash
cd /workspace/project
nextflow run fibo-jobs.nf -c nextflow.config
```

### 4. What Happens When You Run the Pipeline

The `fibo-jobs.nf` pipeline will:
1. Create 3 parallel processes (channels 1, 2, 3)
2. Each process runs a Python script that generates Fibonacci numbers
3. Nextflow uses Kubernetes Job controller to create individual Jobs for each process
4. Each Job runs a Python container that generates Fibonacci numbers for 20 iterations
5. Jobs are automatically cleaned up after 10 minutes (TTL)

### 5. Monitoring

#### Check Pipeline Status
```bash
# From inside the pod
kubectl get jobs -n nextflow -l managed-by=nextflow
kubectl get pods -n nextflow -l app=fibonacci
```

#### View Logs
```bash
# From inside the pod
kubectl logs <pod-name> -n nextflow
```

#### From Outside the Pod
```bash
# Controller logs
kubectl logs -f nextflow-controller -n nextflow

# Fibonacci job logs
kubectl get pods -n nextflow -l app=fibonacci
kubectl logs <pod-name> -n nextflow
```

### 6. Cleanup

#### Clean Up Resources
```bash
./cleanup.sh
```

This will:
- Delete the controller Pod
- Delete all fibonacci Jobs
- Delete fibonacci Pods (if any stuck)
- Optionally delete the ConfigMap

### 7. Key Differences from Original Setup

| Aspect | Original (Job) | New (Pod) |
|--------|----------------|-----------|
| **Resource Type** | Job | Pod |
| **Execution** | Automatic | Manual |
| **Container Lifecycle** | Terminates after completion | Stays alive for manual access |
| **Access Method** | `kubectl logs` | `kubectl exec -it` |
| **Control** | Fully automated | Manual control over execution |

### 8. File Structure

```
nextflow-jobs/
├── controller.yaml          # Pod definition (converted from Job)
├── deploy.sh               # Deployment script (updated for Pod)
├── cleanup.sh              # Cleanup script (updated for Pod)
├── rbac.yaml              # RBAC configuration
├── pipeline-config.yaml   # ConfigMap with pipeline files
├── nextflow.config        # Nextflow configuration
└── fibo-jobs.nf           # Nextflow pipeline script
```

### 9. Configuration Details

#### Pod Configuration
- **Image**: `nextflow/nextflow:24.10.0`
- **Service Account**: `nextflow-sa` (with Job/Pod creation permissions)
- **Volumes**: 
  - PVC `nextflow-workspace` mounted at `/workspace`
  - ConfigMap `nextflow-pipeline` mounted at `/config`
- **Resources**: 512Mi-1Gi memory, 250m-500m CPU

#### Nextflow Configuration
- **Executor**: Kubernetes
- **Resource Type**: Job (creates K8s Jobs for each process)
- **Namespace**: `nextflow`
- **Storage**: Uses PVC for workspace and work directory
- **TTL**: Jobs cleaned up after 10 minutes

### 10. Troubleshooting

#### Pod Not Starting
```bash
kubectl describe pod nextflow-controller -n nextflow
kubectl logs nextflow-controller -n nextflow
```

#### Pipeline Not Creating Jobs
- Check RBAC permissions
- Verify kubectl is working inside the pod
- Check Nextflow configuration

#### Jobs Not Running
- Check resource limits
- Verify node selector
- Check PVC status

### 11. Manual Commands Reference

```bash
# Deploy everything
./deploy.sh

# Access the pod
kubectl exec -it nextflow-controller -n nextflow -- /bin/bash

# Inside the pod - run pipeline
cd /workspace/project
nextflow run fibo-jobs.nf -c nextflow.config

# Monitor from outside
kubectl get pods,jobs -n nextflow
kubectl logs -f nextflow-controller -n nextflow

# Clean up
./cleanup.sh
```

This setup gives you full manual control over when and how the Nextflow pipeline executes, while maintaining all the Kubernetes integration features.
