#!/bin/bash

echo "Verifying HPA Configuration for CKA Exam..."
echo "============================================"
echo

# Configuration to verify
HPA_NAME="apache-server"
NAMESPACE="autoscale"
TARGET_DEPLOYMENT="apache-deployment"
EXPECTED_CPU_TARGET="50"
EXPECTED_MIN_REPLICAS="1"
EXPECTED_MAX_REPLICAS="4"
EXPECTED_STABILIZATION="30"

ERRORS=0

# Function for error handling
check_and_report() {
    local condition="$1"
    local success_msg="$2"
    local error_msg="$3"
    
    if eval "$condition"; then
        echo "✓ $success_msg"
        return 0
    else
        echo "✗ $error_msg"
        return 1
    fi
}

# 1. Check HPA exists with correct name and namespace
echo "1. Checking HPA existence..."
if ! kubectl get hpa "$HPA_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "✗ HPA '$HPA_NAME' not found in namespace '$NAMESPACE'"
    echo "  Run: kubectl get hpa -n $NAMESPACE"
    echo "  Expected: HPA named 'apache-server' in 'autoscale' namespace"
    exit 1
fi
echo "✓ HPA 'apache-server' exists in 'autoscale' namespace"

# 2. Check target deployment
echo "2. Checking target deployment..."
TARGET_REF=$(kubectl get hpa "$HPA_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.scaleTargetRef.name}')
if ! check_and_report "[ '$TARGET_REF' = '$TARGET_DEPLOYMENT' ]" \
    "Target deployment: $TARGET_REF" \
    "Expected target deployment: $TARGET_DEPLOYMENT, got: $TARGET_REF"; then
    ((ERRORS++))
fi

# 3. Check min replicas
echo "3. Checking minimum replicas..."
MIN_REPLICAS=$(kubectl get hpa "$HPA_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.minReplicas}')
if ! check_and_report "[ '$MIN_REPLICAS' = '$EXPECTED_MIN_REPLICAS' ]" \
    "Min replicas: $MIN_REPLICAS" \
    "Expected minReplicas: $EXPECTED_MIN_REPLICAS, got: $MIN_REPLICAS"; then
    ((ERRORS++))
fi

# 4. Check max replicas  
echo "4. Checking maximum replicas..."
MAX_REPLICAS=$(kubectl get hpa "$HPA_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.maxReplicas}')
if ! check_and_report "[ '$MAX_REPLICAS' = '$EXPECTED_MAX_REPLICAS' ]" \
    "Max replicas: $MAX_REPLICAS" \
    "Expected maxReplicas: $EXPECTED_MAX_REPLICAS, got: $MAX_REPLICAS"; then
    ((ERRORS++))
fi

# 5. Check CPU utilization target
echo "5. Checking CPU utilization target..."
API_VERSION=$(kubectl get hpa "$HPA_NAME" -n "$NAMESPACE" -o jsonpath='{.apiVersion}')

if [[ "$API_VERSION" == "autoscaling/v2"* ]]; then
    # Check autoscaling/v2 format
    CPU_TARGET=$(kubectl get hpa "$HPA_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.metrics[?(@.type=="Resource" && @.resource.name=="cpu")].resource.target.averageUtilization}')
else
    # Check autoscaling/v1 format
    CPU_TARGET=$(kubectl get hpa "$HPA_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.targetCPUUtilizationPercentage}')
fi

if ! check_and_report "[ '$CPU_TARGET' = '$EXPECTED_CPU_TARGET' ]" \
    "CPU utilization target: ${CPU_TARGET}%" \
    "Expected CPU target: ${EXPECTED_CPU_TARGET}%, got: ${CPU_TARGET}%"; then
    ((ERRORS++))
fi

# 6. Check downscale stabilization window (requires autoscaling/v2)
echo "6. Checking downscale stabilization window..."
if [[ "$API_VERSION" == "autoscaling/v2"* ]]; then
    STABILIZATION_WINDOW=$(kubectl get hpa "$HPA_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}')
    
    if [ -n "$STABILIZATION_WINDOW" ]; then
        if ! check_and_report "[ '$STABILIZATION_WINDOW' = '$EXPECTED_STABILIZATION' ]" \
            "Downscale stabilization window: ${STABILIZATION_WINDOW}s" \
            "Expected stabilization window: ${EXPECTED_STABILIZATION}s, got: ${STABILIZATION_WINDOW}s"; then
            ((ERRORS++))
        fi
    else
        echo "✗ Downscale stabilization window not configured"
        echo "  Hint: Requires autoscaling/v2 API with behavior.scaleDown.stabilizationWindowSeconds"
        ((ERRORS++))
    fi
else
    echo "✗ API version is $API_VERSION - stabilization window requires autoscaling/v2"
    ((ERRORS++))
fi

# 7. Check HPA status and scaling capability
echo "7. Checking HPA status..."
ABLE_TO_SCALE=$(kubectl get hpa "$HPA_NAME" -n "$NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="AbleToScale")].status}')
if [ "$ABLE_TO_SCALE" = "True" ]; then
    echo "✓ HPA is able to scale (AbleToScale: True)"
else
    echo "⚠ Warning: HPA may not be ready to scale (AbleToScale: $ABLE_TO_SCALE)"
    echo "  This may be normal if metrics are not yet available"
fi

# Final results
echo
echo "Verification Summary:"
echo "===================="
if [ $ERRORS -eq 0 ]; then
    echo "🎉 SUCCESS: All HPA requirements verified!"
    echo "✓ Name: apache-server"
    echo "✓ Namespace: autoscale" 
    echo "✓ Target: apache-deployment"
    echo "✓ CPU Target: 50%"
    echo "✓ Min Replicas: 1"
    echo "✓ Max Replicas: 4"
    echo "✓ Downscale Stabilization: 30s"
    echo
    echo "Your HPA configuration meets all CKA exam requirements!"
    exit 0
else
    echo "❌ FAILED: $ERRORS error(s) found in HPA configuration"
    echo
    echo "Review the errors above and correct your HPA configuration."
    echo "Run 'kubectl describe hpa apache-server -n autoscale' for more details."
    exit 1
fi
