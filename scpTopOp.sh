#!/usr/bin/env bash

if [[ $# -ne 1 ]] ; then
	echo "Expected 1 CLI argument - Number of worker nodes"
    exit 1
fi

cd /opt/ && mkdir -p Node_Ops

numWorkerNodes="$1"
startNodeNum=0
endNodeNum=$((0 + numWorkerNodes))
ocmd="scp -o StrictHostKeyChecking=no -r /opt/Experiments root@node0:/opt/Node_Ops"
for i in $(seq $startNodeNum $endNodeNum);
do	
	node=node$i
	echo ""
	echo "Starting top-start script on Node - $node"
	echo ""
    cd /opt/Node_Ops && mkdir -p $node
    if [[ $i -eq 0 ]] ; then
        mcmd="$ocmd/$node/"
        eval "$mcmd"
    else
        wcmd="$ocmd/$node/ && exit"
        ssh -o StrictHostKeyChecking=no root@$node "$wcmd"
    fi
	echo ""
	echo "Started top-start script on Node - $node"
        echo ""
        nodeNum=$((nodeNum + 1))
done