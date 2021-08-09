#!/usr/bin/env bash

if [[ $# -eq 3 ]] ; then
	experimentDir="$3"
	echo "Experiment Directory = $experimentDir"
elif [[ $# -eq 2 ]] ; then
    experimentDir=`date '+%F_%H-%M-%S'`
    echo "Experiment Directory = $experimentDir"
else
	echo "Expected at least 2 CLI arguments - Number of worker nodes and directory to save output"
    exit 1
fi

numWorkerNodes="$1"
pcsDir="$2"
startNodeNum=0
endNodeNum=$((0 + numWorkerNodes))
ocmd="cd /opt/scripts/ && mkdir -p $experimentDir && cd $experimentDir && mkdir -p $pcsDir && cd $pcsDir && cp /opt/scripts/topFile.sh . && rm -f top_data.txt && (bash topFile.sh > /dev/null 2>&1 &)"
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