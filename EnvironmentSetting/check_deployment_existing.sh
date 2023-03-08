#!/bin/bash

deployment_name=goweb-deployment

kubectl get deployment -n azuredevopsapp |grep -i ${deployment_name}
if [$? -eq 0]; then 
kubectl delete deployment ${deployment_name} -n azuredevopsapp
else
echo "No old deployment ${deployment_name}"
fi