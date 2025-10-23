# Nextflow Kubernetes Jobs Pipeline

This setup allows Nextflow to create Kubernetes Jobs (which then create Pods) instead of creating Pods directly.

## 📁 File Structure

- `rbac.yaml` - ServiceAccount, Role, and RoleBinding for permissions
- `pipeline-config.yaml` - ConfigMap with Nextflow pipeline and configuration
- `controller.yaml` - Kubernetes Job that runs the Nextflow controller
- `deploy.sh` - Script to deploy everything
- `cleanup.sh` - Script to clean up resources for quick reruns

## 🚀 Quick Start

1. **First time setup:**
```bash
cd nextflow-jobs
chmod +x deploy.sh cleanup.sh
./deploy.sh
```

2. **Monitor the pipeline:**
```bash
# Watch controller logs
kubectl logs -f job/nextflow-controller -n nextflow

# Check created jobs
kubectl get jobs -n nextflow -l managed-by=nextflow

# Check fibonacci pods
kubectl get pods -n nextflow -l app=fibonacci

# View fibonacci logs
kubectl logs <pod-name> -n nextflow
```

3. **Clean up and rerun:**
```bash
./cleanup.sh
./deploy.sh
```

## 🔄 Pipeline Flow

1. **Nextflow Controller Job** starts
2. **Controller runs Nextflow** which executes the pipeline
3. **Nextflow creates 3 Kubernetes Jobs** (fibonacci-job-1, fibonacci-job-2, fibonacci-job-3)
4. **Each Job creates its own Pod** that runs the Fibonacci sequence
5. **Jobs auto-cleanup** after 100 minutes (configurable in pipeline-config.yaml)

## ⚙️ Customization

### Change number of jobs:
Edit `pipeline-config.yaml`:
```groovy
channel.of(1..5)  // Creates 5 jobs instead of 3
```

### Change Fibonacci iterations:
Edit `pipeline-config.yaml`:
```python
for i in range(200):  # Number of iterations
```

### Change auto-cleanup time:
Edit `pipeline-config.yaml`:
```yaml
ttlSecondsAfterFinished: 6000  # Time in seconds
```

## 📊 Monitoring Commands

```bash
# All resources
kubectl get all -n nextflow

# Jobs only
kubectl get jobs -n nextflow

# Pods with status
kubectl get pods -n nextflow -o wide

# Clean up old completed jobs manually
kubectl delete jobs -n nextflow --field-selector status.successful=1
