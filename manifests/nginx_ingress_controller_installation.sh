#!/bin/bash
helm version
if [ $? -eq 0 ]; then
echo $(helm version)
else
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
fi
ingress_controller_namespace="ingress-basic"

kubectl get namespace|grep "${ingress_controller_namespace}"
if [ $? -eq 0 ]; then
echo "namespace ${ingress_controller_namespace} exists"
else
kubectl create namespace ${ingress_controller_namespace}
fi

kubectl get SecretProviderClass -n ${ingress_controller_namespace}|grep azure-tls
if [ $? -eq 0 ]; then
  echo "SecretProviderClass azure-tls already exists"
elif [ ${BUILD_SOURCEBRANCH} == "refs/heads/main" ]; then
  kubectl apply -f SecretProviderClass_azure-tls.yaml -n ${ingress_controller_namespace}
else
  kubectl apply -f Dev_SecretProviderClass_azure-tls.yaml -n ${ingress_controller_namespace}
fi
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade -i nginx-ingress ingress-nginx/ingress-nginx \
    --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
    -f - <<EOF
controller:
  extraVolumes:
      - name: secrets-store-inline
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: "azure-tls"
  extraVolumeMounts:
      - name: secrets-store-inline
        mountPath: "/mnt/secrets-store"
        readOnly: true
EOF
