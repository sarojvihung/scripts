#!/usr/bin/env bash

if [[ $# -ne 2 ]] ; then
	echo "Expected 2 CLI arguments - sub-directory & experiment directory to save output"
    exit 1
fi

experimentDir="$1"
pcsDir="$2"

ARRAY=()
for pod in `kubectl -n open5gs get po -o json |  jq '.items[] | select(.metadata.name|contains("open5gs"))| .metadata.name' | grep "amf\|smf\|upf" | sed 's/"//g'` ; 
do
    echo $pod
    ARRAY+=($pod)
done

for pod in "${ARRAY[@]}"
do
    kubectl logs $pod -n open5gs > /opt/Experiments/$experimentDir/$pcsDir/${pod}_logs.txt
done

