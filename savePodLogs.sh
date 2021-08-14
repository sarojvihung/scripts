#!/usr/bin/env bash

if [[ $# -ne 2 ]] ; then
        echo "Expected 2 CLI arguments - sub-directory & experiment directory to save output"
    exit 1
fi

experimentDir="$1"
pcsDir="$2"

ARRAY=()
for pod in `kubectl -n open5gs get po -o json |  jq '.items[] | select(.metadata.name|contains("open5gs"))| .metadata.name' | grep -v "test\|webui\|mongo" | sed 's/"//g'` ;
do
    echo $pod
    ARRAY+=($pod)
done

rm -f /opt/Experiments/$experimentDir/$pcsDir/nf_max_queue.txt

for pod in "${ARRAY[@]}"
do
    rm -f /opt/Experiments/$experimentDir/$pcsDir/${pod}_logs.txt
    kubectl logs $pod -n open5gs > /opt/Experiments/$experimentDir/$pcsDir/${pod}_logs.txt
    nfName=$(echo $pod | awk -v FS="(open5gs-|-deployment)" '{print $2}')
    maxQueue=$(cat /opt/Experiments/$experimentDir/$pcsDir/${pod}_logs.txt | grep " ogs_queue_size is" | grep "PCS " | awk '{print $9}' | sort -rn | head -n 1)
    if [[ "$nfName" == "amf" ]] ; then
        startTime=$(cat /opt/Experiments/$experimentDir/$pcsDir/${pod}_logs.txt | grep InitialUEMessage | head -1 | awk '{print $2}' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | rev | cut -c 2- | rev)
        stopTime=$(cat /opt/Experiments/$experimentDir/$pcsDir/${pod}_logs.txt | grep PCS | grep -v "ogs_queue_size" | tail -1 | awk '{print $2}' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | rev | cut -c 2- | rev)
        d1=$(date -d $startTime "+%s.%N")
        d2=$(date -d $stopTime "+%s.%N")
        timediff=$(echo "$d2 - $d1" | bc)
        echo "$nfName,$maxQueue,$timediff" >> /opt/Experiments/$experimentDir/$pcsDir/nf_max_queue.txt
        echo " " >> /opt/Experiments/$experimentDir/$pcsDir/nf_max_queue.txt
    else
        echo "$nfName,$maxQueue" >> /opt/Experiments/$experimentDir/$pcsDir/nf_max_queue.txt
        echo " " >> /opt/Experiments/$experimentDir/$pcsDir/nf_max_queue.txt
    fi
done