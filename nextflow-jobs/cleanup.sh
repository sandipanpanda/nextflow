#!/bin/bash

echo "🧹 Cleaning up Nextflow resources..."

# Delete the controller pod
echo "Deleting controller pod..."
kubectl delete pod nextflow-controller -n nextflow
# Delete all fibonacci jobs
echo "Deleting fibonacci jobs..."
kubectl delete jobs -n nextflow -l managed-by=nextflow

# Delete all fibonacci pods (if any stuck)
echo "Deleting fibonacci pods..."
kubectl delete pods -n nextflow -l app=fibonacci

kubectl delete configmap nextflow-pipeline -n nextflow
echo "ConfigMap deleted"

kubectl delete all --all --force -n nextflow

echo "✅ Cleanup complete!"
echo ""
echo "Current status:"
kubectl get pods -n nextflow
