#!/bin/bash
helm version
if [ $? -eq 0 ]; then
  echo $(helm version)
else
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
fi

source SecretProviderClass_azure-tls.yaml
source Dev_SecretProviderClass_azure-tls.yaml
kubectl get SecretProviderClass|grep azure-tls
if [ $? -eq 0 ]; then
  echo "SecretProviderClass azure-tls already exists"
elif [ ${Build.SourceBranch} = "refs/heads/main" ]
  kubectl apply -f SecretProviderClass_azure-tls.yaml
else
  kubectl apply -f Dev_SecretProviderClass_azure-tls.yaml
fi

helm install ingress-nginx/ingress-nginx --generate-name \
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
