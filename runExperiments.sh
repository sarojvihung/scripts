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

for pcsDir in "${subDir[@]}"
do

    echo "Sub-dir is $pcsDir"
    numSessions=$(( pcsDir / 2 ))

    #cleanup
    kubectl get pods --no-headers=true | awk '/upf|amf|bsf|pcf|udm|ausf|nrf|nssf|udr|smf/{print $1}'| xargs  kubectl delete pod

    sleep 120


    #start-ran
    sh /opt/scripts/runNodeCmd.sh "nr-gnb -c /opt/UERANSIM/config/open5gs/gnb.yaml > /dev/null 2>&1 &" 11 13

    sh /opt/scripts/runNodeCmd.sh "/opt/scripts/launchUeSim.py > /dev/null 2>&1 &" 12 14


    #start-monitoring
    kubectl exec $mongoPod -- bash -c "/scripts/mongoMonitor.py" &
    mongoPodIp=$(kubectl get pod $mongoPod --template={{.status.podIP}})
    mcmd="curl --verbose --request POST --header \"Content-Type:application/json\" --data '{\"expDir\":\"$experimentDir\",\"subExpDir\":\"$pcsDir\",\"runTime\":30}' http://$mongoPodIp:15692"
    eval "$mcmd > /dev/null 2>&1 &"

    sh /opt/scripts/startTop.sh $numWorkerNodes $experimentDir $pcsDir


    #start-ue
    sh /opt/scripts/startUeCalls.sh $numSessions $experimentDir $pcsDir 0.3

    sleep 15


    #stop-monitoring
    sh /opt/scripts/stopTop.sh $numWorkerNodes

    sh /opt/scripts/savePodLogs.sh $experimentDir $pcsDir

    sleep 30

    #stop-ran
    sh /opt/scripts/runNodeCmd.sh "pkill -f nr-ue" 12 14

    sleep 5

    sh /opt/scripts/runNodeCmd.sh "pkill -f nr-gnb" 11 13

    sleep 5
    
    sh /opt/scripts/runNodeCmd.sh "pkill -f launchUeSim.py" 12 14

    sleep 5

    kubectl exec -it $mongoPod -- bash -c "pkill -f mongoMonitor.py"

    sleep 5

done