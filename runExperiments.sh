#!/usr/bin/env bash

if [[ $# -ne 1 ]] ; then
	echo "Expected 1 CLI argument - Experiment directory"
    exit 1
fi

experimentDirPrefix="$1"

#0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17
#0 - master
#1-11 - worker
#12,14 - gnb
#13,15 - UE 

#mongoPod=`kubectl -n open5gs get po -o json |  jq '.items[] | select(.metadata.name|contains("open5gs"))| .metadata.name' | grep "mongo" | sed 's/"//g'`
#kubectl exec -it $mongoPod -- bash -c "apt-get update && apt -y install git vim python3-pip && git clone https://github.com/UmakantKulkarni/scripts"

mkdir -p /opt/Experiments/

declare -a subDir=("100" "200" "300" "400" "500" "600" "700" "800" "900" "1000")

declare -a experimentDirAry=("$experimentDirPrefix-1")

declare -a ueNodes=("10.10.1.2")

for experimentDir in "${experimentDirAry[@]}"
do
    for pcsDir in "${subDir[@]}"
    do

        echo "Sub-dir is $pcsDir"
        rm -rf /opt/Experiments/${pcsDir}
        mkdir -p /opt/Experiments/${pcsDir}

        numSessions=$(( pcsDir / 1 ))
        callTime=$(( pcsDir / 25 ))

        #cleanup
        kubectl get pods --no-headers=true | awk '/upf|amf|bsf|pcf|udm|ausf|nrf|nssf|udr|smf/{print $1}'| xargs  kubectl delete pod

        sleep 120

        rm -rf /opt/Experiments/$experimentDir/$pcsDir/istioPerf
        mkdir -p /opt/Experiments/$experimentDir/$pcsDir/istioPerf
        PODARRAY=()
        for pod in `kubectl -n open5gs get po -o json |  jq '.items[] | select(.metadata.name|contains("open5gs"))| .metadata.name' | grep -v "test\|webui\|upf\|mongo" | sed 's/"//g'` ;
        do
            echo $pod
            PODARRAY+=($pod)
        done

        for pod in "${PODARRAY[@]}"
        do

            POD=$pod
            NS=open5gs
            PROFILER="cpu" # Can also be "heap", for a heap profile
            kubectl exec -n "$NS" "$POD" -c istio-proxy -- curl -X POST -s "http://localhost:15000/${PROFILER}profiler?enable=y"
            PROFILER="heap" # Can also be "heap", for a heap profile
            kubectl exec -n "$NS" "$POD" -c istio-proxy -- curl -X POST -s "http://localhost:15000/${PROFILER}profiler?enable=y"
        done

        #start-ran
        bash /opt/scripts/runNodeCmd.sh "nr-gnb -c /opt/UERANSIM/config/open5gs-gnb.yaml > /dev/null 2>&1 &" 1

        #bash /opt/scripts/runNodeCmd.sh "/opt/scripts/launchUeSim.py > /dev/null 2>&1 &" 1

        #start-ue
        for ueNodeIp in "${ueNodes[@]}"
        do
            echo "UE-SIM IP Address is $ueNodeIp"
            curl --verbose --request POST --header "Content-Type:application/json" --data '{"numSessions":"'$numSessions'","expDir":"'$experimentDir'","subExpDir":"'$pcsDir'"}'  http://$ueNodeIp:15692
        done

        sleep $callTime

        bash /opt/scripts/savePodLogs.sh $experimentDir $pcsDir

        #sleep 60

        for pod in "${PODARRAY[@]}"
        do
            POD=$pod
            NS=open5gs
            nfName=$(echo $pod | awk -v FS="(open5gs-|-deployment)" '{print $2}')
            mkdir -p /opt/Experiments/$experimentDir/$pcsDir/istioPerf/${nfName}
            PROFILER="cpu" # Can also be "heap", for a heap profile
            kubectl exec -n "$NS" "$POD" -c istio-proxy -- curl -X POST -s "http://localhost:15000/${PROFILER}profiler?enable=n"
            PROFILER="heap" # Can also be "heap", for a heap profile
            kubectl exec -n "$NS" "$POD" -c istio-proxy -- curl -X POST -s "http://localhost:15000/${PROFILER}profiler?enable=n"
            kubectl cp -n "$NS" "$POD":/var/lib/istio/data /opt/Experiments/$experimentDir/$pcsDir/istioPerf/${nfName} -c istio-proxy
            kubectl cp -n "$NS" "$POD":/lib/x86_64-linux-gnu /opt/Experiments/$experimentDir/$pcsDir/istioPerf/${nfName}/lib -c istio-proxy
            kubectl cp -n "$NS" "$POD":/usr/local/bin/envoy /opt/Experiments/$experimentDir/$pcsDir/istioPerf/${nfName}/lib/envoy -c istio-proxy
        done

        #stop-ran
        bash /opt/scripts/runNodeCmd.sh "pkill -f nr-ue" 1

        sleep 5

        bash /opt/scripts/runNodeCmd.sh "pkill -f nr-gnb" 1

        sleep 5
        
        #bash /opt/scripts/runNodeCmd.sh "pkill -f launchUeSim.py" 12 14

        #sleep 5

        #kubectl exec -it $mongoPod -- bash -c "pkill -f mongoMonitor.py"

        #sleep 5

    done
done