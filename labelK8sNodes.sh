#!/usr/bin/env bash

if [[ $# -ne 2 ]] ; then
	echo "Expected 2 CLI arguments - Number of worker nodes to label and nodePrefix"
    exit 1
fi

#declare -a arr=("master" "amf" "smf" "upf" "udsf" "udm" "pcf" "bsf" "nrf" "ausf" "udr")
declare -a arr=("master" "amf" "smf" "upf" "udsf")

numWorkerNodes="$1"
nodePrefix="$2"
startNodeNum=0
endNodeNum=$((0 + numWorkerNodes))
for i in $(seq $startNodeNum $endNodeNum);
do	
	node=node$i
	echo ""
	echo "Labelling Node - $node"
	echo ""
    kubectl label --overwrite nodes node$i.$nodePrefix kubernetes.io/pcs-nf-type=${arr[i]}
	echo ""
	echo "Finished Labelling Node - $node"
        echo ""
        nodeNum=$((nodeNum + 1))
done