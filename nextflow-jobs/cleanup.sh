#!/bin/bash

echo "🧹 Cleaning up Nextflow resources..."

# Delete the controller pod
echo "Deleting controller pod..."
kubectl delete pod nextflow-controller -n nextflow 2>/dev/null || true

# Delete all fibonacci jobs
echo "Deleting fibonacci jobs..."
kubectl delete jobs -n nextflow -l managed-by=nextflow 2>/dev/null || true

# Delete all fibonacci pods (if any stuck)
echo "Deleting fibonacci pods..."
kubectl delete pods -n nextflow -l app=fibonacci 2>/dev/null || true

# Optional: Delete ConfigMap if you want to update it
read -p "Delete ConfigMap? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete configmap nextflow-pipeline -n nextflow 2>/dev/null || true
    echo "ConfigMap deleted"
fi

echo "✅ Cleanup complete!"
echo ""
echo "Current status:"
kubectl get pods -n nextflow
