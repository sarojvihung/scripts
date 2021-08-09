#!/usr/bin/env bash

if [[ $# -ne 2 ]] ; then
	echo "Expected 2 CLI arguments - Number of worker nodes and repo"
    exit 1
fi

numWorkerNodes="$1"
pcsRepo="$2"
startNodeNum=0
endNodeNum=$((0 + numWorkerNodes))
ocmd="cd /opt/$pcsRepo/ && git pull"
wcmd="$ocmd && exit"
for i in $(seq $startNodeNum $endNodeNum);
do	
	node=node$i
	echo ""
	echo "Starting git-pull script on Node - $node"
	echo ""
    if [[ $i -eq 0 ]] ; then
        eval "$ocmd"
    else
        ssh -o StrictHostKeyChecking=no root@$node "$wcmd"
    fi
	echo ""
	echo "Finished git-pull script on Node - $node"
        echo ""
        nodeNum=$((nodeNum + 1))
done