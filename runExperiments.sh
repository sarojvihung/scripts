#!/usr/bin/env bash

if [[ $# -ne 1 ]] ; then
	echo "Expected 1 CLI argument - Experiment directory"
    exit 1
fi

experimentDir="$1"
numWorkerNodes=10

mongoPod=`kubectl -n open5gs get po -o json |  jq '.items[] | select(.metadata.name|contains("open5gs"))| .metadata.name' | grep "mongo" | sed 's/"//g'`
kubectl exec -it $mongoPod -- bash -c "apt-get update && apt -y install git vim python3-pip && git clone https://github.com/UmakantKulkarni/scripts"

declare -a subDir=("100" "200" "300" "400" "500" "600" "700" "800" "900" "1000")

for pcs_it in "${subDir[@]}"
do

    echo "Sub-dir is $pcs_it"
    numSessions=$(( pcs_it / 2 ))

    #cleanup
    kubectl get pods --no-headers=true | awk '/upf|amf|bsf|pcf|udm|ausf|nrf|nssf|udr|smf/{print $1}'| xargs  kubectl delete pod
    sleep 120


    #start-ran
    sh /opt/scripts/runNodeCmd.sh "nr-gnb -c /opt/UERANSIM/config/open5gs/gnb.yaml > /dev/null 2>&1 &" 11 13

    sh /opt/scripts/runNodeCmd.sh "/opt/scripts/launchUeSim.py > /dev/null 2>&1 &" 12 14


    #start-monitoring
    kubectl exec -it $mongoPod -- /bin/bash /scripts/mongoMonitor.sh $experimentDir $pcsDir 30

    sh /opt/scripts/startTop.sh $numWorkerNodes $experimentDir $pcsDir


    #start-ue
    sh /opt/scripts/startUeCalls.sh $numSessions $experimentDir $pcsDir 0.3
    sleep 15


    #stop-monitoring
    sh /opt/scripts/stopTop.sh $numWorkerNodes

    sh /opt/scripts/savePodLogs.sh $experimentDir $pcsDir

    sleep 25
    kubectl exec -it $mongoPod -- bash -c "pkill -f mongostat"
    kubectl exec -it $mongoPod -- bash -c "pkill -f mongotop"


    #save-db-sessions
    kubectl exec -it $mongoPod -- bash -c "mongo pcs_db --eval \"db.amf.count({'pcs-update-done':1})\" | tail -1 >> opt/Experiments/$experimentDir/$subDir/sessCount.txt"
    kubectl exec -it $mongoPod -- bash -c "mongo pcs_db --eval \"db.smf.count({'pcs-update-done':1})\" | tail -1 >> opt/Experiments/$experimentDir/$subDir/sessCount.txt"
    kubectl exec -it $mongoPod -- bash -c "mongo pcs_db --eval \"db.upf.count({'pcs-pfcp-update-done':1})\" | tail -1 >> opt/Experiments/$experimentDir/$subDir/sessCount.txt"

    #stop-ran
    sh /opt/scripts/runNodeCmd.sh "pkill -f nr-ue" 12 14
    sleep 5

    sh /opt/scripts/runNodeCmd.sh "pkill -f nr-gnb" 11 13
    sleep 5
    
    sh /opt/scripts/runNodeCmd.sh "pkill -f launchUeSim.py" 12 14
    sleep 5

done