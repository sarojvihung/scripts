kubectl delete namespace open5gs
sleep 30 
kubectl delete pv mongodb-pv-volume-open5gs
sleep 30
kubectl create namespace open5gs
cd /opt/opensource-5g-core/helm-chart/ 
helm -n open5gs install -f values.yaml 5gcore ./
sleep 10
kubectl config set-context --current --namespace=open5gs