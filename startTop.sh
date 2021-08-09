#!/usr/bin/env bash

if [[ $# -ne 2 ]] ; then
	echo "Expected 2 CLI arguments - Number of worker nodes and directory to save output"
    exit 1
fi

numWorkerNodes="$1"
pcsDir="$2"
startNodeNum=0
endNodeNum=$((0 + numWorkerNodes))
rcmd="cd /opt/scripts/ && bash topFile.sh > /dev/null 2>&1 & && exit"
for i in $(seq $startNodeNum $endNodeNum);
do	
	node=node$i
	echo ""
	echo "Starting top-start script on Node - $node"
	echo ""
    if [[ $i -eq 0 ]] ; then
        cd /opt/scripts/ && bash topFile.sh > /dev/null 2>&1 &
    else
        ssh -o StrictHostKeyChecking=no root@$node "$rcmd"
    fi
	echo ""
	echo "Started top-start script on Node - $node"
        echo ""
        nodeNum=$((nodeNum + 1))
done