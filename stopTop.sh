#!/usr/bin/env bash

if [[ $# -ne 1 ]] ; then
	echo "Expected 1 CLI argument - Number of worker nodes"
    exit 1
fi

numWorkerNodes="$1"
startNodeNum=0
endNodeNum=$((0 + numWorkerNodes))
ocmd="kill $(ps aux | grep '[b]ash topFile.sh' | awk '{print $2}')"
wcmd="$ocmd && exit"
for i in $(seq $startNodeNum $endNodeNum);
do	
	node=node$i
	echo ""
	echo "Stopping top-start script on Node - $node"
	echo ""
    if [[ $i -eq 0 ]] ; then
        eval "$ocmd"
    else
        ssh -o StrictHostKeyChecking=no root@$node "$wcmd"
    fi
	echo ""
	echo "Stopped top-start script on Node - $node"
        echo ""
        nodeNum=$((nodeNum + 1))
done