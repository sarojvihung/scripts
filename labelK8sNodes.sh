#!/usr/bin/env bash

nodePrefix="$1"
declare -a nodeLabels=("master" "amf" "smf" "upf" "udsf" "ausf" "bsf" "nrf" "nssf" "pcf" "udm" "udr")
declare -a workerNodes=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11")

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