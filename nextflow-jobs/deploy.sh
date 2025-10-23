#!/bin/bash

echo "🚀 Deploying Nextflow Jobs Pipeline"
echo "======================================"

# Check if namespace exists
if ! kubectl get namespace nextflow &> /dev/null; then
    echo "📦 Creating namespace 'nextflow'..."
    kubectl create namespace nextflow
else
    echo "✓ Namespace 'nextflow' exists"
fi

# Check if PVC exists
if ! kubectl get pvc nextflow-workspace -n nextflow &> /dev/null; then
    echo "📦 Creating PVC 'nextflow-workspace'..."
    kubectl apply -f ../nxtflow-pvc.yaml --validate=false
else
    echo "✓ PVC 'nextflow-workspace' exists"
fi

# Apply RBAC
echo "🔐 Applying RBAC configuration..."
kubectl apply -f rbac.yaml --validate=false

# Apply ConfigMap
echo "📝 Applying pipeline configuration..."
kubectl apply -f pipeline-config.yaml --validate=false

# Deploy controller pod
echo "🎮 Deploying Nextflow controller pod..."
kubectl apply -f controller.yaml --validate=false

# Wait for pod to start
echo "⏳ Waiting for pod to start..."
kubectl wait --for=condition=Ready pod/nextflow-controller -n nextflow --timeout=60s

# Show status
echo ""
echo "📊 Current status:"
kubectl get pods -n nextflow

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🔧 To access the pod manually:"
echo "  kubectl exec -it nextflow-controller -n nextflow -- /bin/bash"
echo ""
echo "📝 Once inside the pod, run:"
echo "  cd /workspace/project"
echo "  nextflow run fibo-jobs.nf -c nextflow.config"
echo ""
echo "📊 To monitor the controller logs:"
echo "  kubectl logs -f nextflow-controller -n nextflow"
echo ""
echo "🔍 To check fibonacci job logs:"
echo "  kubectl get pods -n nextflow -l app=fibonacci"
echo "  kubectl logs <pod-name> -n nextflow"
echo ""
echo "🧹 To clean up and rerun:"
echo "  ./cleanup.sh"
echo "  ./deploy.sh"
