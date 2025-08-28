#!/bin/bash

kubectl get hpa apache-server -n autoscale -o=jsonpath='{.spec.targetCPUUtilizationPercentage}{.spec.minReplicas}{.spec.maxReplicas}{.spec.behavior.scaleDown.stabilizationWindowSeconds}' | grep -q '501430'
