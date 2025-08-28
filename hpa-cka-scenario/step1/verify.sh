#!/bin/bash

kubectl get hpa apache-server -n autoscale -o=jsonpath='{.spec.metrics[0].resource.target.averageUtilization}{.spec.minReplicas}{.spec.maxReplicas}{.spec.behavior.scaleDown.stabilizationWindowSeconds}' | grep -q '501430'
