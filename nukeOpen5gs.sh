#!/usr/bin/env bash

kubectl delete namespace open5gs
sleep 30 
kubectl delete pv mongodb-pv-volume-open5gs
sleep 30
kubectl create namespace open5gs
Hostname=$(hostname)
if [ "$Hostname" = "wabash" ] ; then
    cd /home/ukulkarn/opensource-5g-core/helm-chart/ 
else
    cd /opt/opensource-5g-core/helm-chart/ 
fi
helm -n open5gs install -f values.yaml 5gcore ./
sleep 10
kubectl config set-context --current --namespace=open5gs