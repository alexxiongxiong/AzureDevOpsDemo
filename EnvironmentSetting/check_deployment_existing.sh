#!/bin/bash
deployment_name="goweb-deployment"
namespace_name="azuredevopsapp"
kubectl get deployment -n ${namespace_name} | grep -i ${deployment_name}
if [ $? -eq 0 ]
then
  kubectl delete deployment ${deployment_name} -n ${namespace_name}
else
  echo "No old deployment! Start to deploy!"
fi