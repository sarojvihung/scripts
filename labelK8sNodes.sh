#!/usr/bin/env bash

nodePrefix="$1"
declare -a nodeLabels=("master" "amf" "smf" "upf" "udsf" "ausf" "nrf" "pcf" "udm")
declare -a workerNodes=("02" "08" "09" "11" "12" "14" "16" "17" "18")

arrayIndex=0
for nodeNum in "${workerNodes[@]}"
do	
	node=node$nodeNum
	echo ""
	echo "Labelling Node - $node"
	echo ""
    kubectl label --overwrite nodes $node.$nodePrefix kubernetes.io/pcs-nf-type=${nodeLabels[arrayIndex]}
	echo ""
	echo "Finished Labelling Node - $node"
    echo ""
    arrayIndex=$((arrayIndex + 1))
done