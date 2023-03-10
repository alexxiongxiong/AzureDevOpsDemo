#!/bin/bash
deployment_name="goweb-deployment"
namespace_name="azuredevopsapp"
kubectl get namespace | grep -i ${deployment_name}
if [ $? -eq 0 ]
then
  "Namespace ${deployment_name} already exists"
else
  kubectl create namespace $namespace_name
fi

kubectl get deployment -n ${namespace_name} | grep -i ${deployment_name}
if [ $? -eq 0 ]
then
  kubectl delete deployment ${deployment_name} -n ${namespace_name}
else
  echo "No old deployment! Start to deploy!"
fi