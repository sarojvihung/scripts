#!/usr/bin/env bash

if [[ $# -ne 3 ]] ; then
	echo "Expected 3 CLI arguments - Number of worker nodes and sub-directory & experiment directory to save output"
    exit 1
fi

numWorkerNodes="$1"
pcsDir="$2"
experimentDir="$3"
startNodeNum=0
endNodeNum=$((0 + numWorkerNodes))
ocmd="cd /opt/ && mkdir -p Experiments && cd Experiments && mkdir -p $experimentDir && cd $experimentDir && mkdir -p $pcsDir && cd $pcsDir && rm -f top_data.txt && (bash /opt/scripts/topFile.sh > /dev/null 2>&1 &)"
wcmd="$ocmd && exit"
for i in $(seq $startNodeNum $endNodeNum);
do	
	node=node$i
	echo ""
	echo "Starting top-start script on Node - $node"
	echo ""
    if [[ $i -eq 0 ]] ; then
        eval "$ocmd"
    else
        ssh -o StrictHostKeyChecking=no root@$node "$wcmd"
    fi
	echo ""
	echo "Started top-start script on Node - $node"
        echo ""
        nodeNum=$((nodeNum + 1))
done