#!/usr/bin/env bash

# Setup custom root certificate for istio
# https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/

if [[ $# -eq 1 ]] ; then
    istio_enabled=$1
else
    istio_enabled=0
fi

istioctl uninstall -y --purge
kubectl --kubeconfig=/etc/kubernetes/admin.conf delete namespace istio-system
kubectl --kubeconfig=/etc/kubernetes/admin.conf label namespace open5gs istio-injection=disabled --overwrite

kubectl --kubeconfig=/etc/kubernetes/admin.conf delete namespace open5gs
sleep 30
kubectl --kubeconfig=/etc/kubernetes/admin.conf delete pv mongodb-pv-volume-open5gs
sleep 30
kubectl --kubeconfig=/etc/kubernetes/admin.conf create namespace open5gs

if [[ $istio_enabled -eq 1 ]] ; then
    istioctl install --set profile=default -y
    kubectl --kubeconfig=/etc/kubernetes/admin.conf label namespace open5gs istio-injection=enabled --overwrite
fi

Hostname=$(hostname)
if [ "$Hostname" = "wabash" ] ; then
    cd /home/ukulkarn/opensource-5g-core/helm-chart/
else
    cd /opt/opensource-5g-core/helm-chart/
fi
helm -n open5gs install -f values.yaml 5gcore ./
sleep 10
kubectl --kubeconfig=/etc/kubernetes/admin.conf config set-context --current --namespace=open5gs

if [[ $istio_enabled -eq 1 ]] ; then
    # Enable mTLS strict mode - STRICT, PERMISSIVE
    # https://istio.io/latest/docs/tasks/security/authentication/mtls-migration/#lock-down-to-mutual-tls-by-namespace
    # In case we want to enable it globally - https://istio.io/latest/docs/tasks/security/authentication/authn-policy/#globally-enabling-istio-mutual-tls-in-strict-mode
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -n open5gs -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: "default"
spec:
  mtls:
    mode: STRICT
EOF
fi
