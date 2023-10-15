#!/usr/bin/env bash

declare -a nodeLabels=("master" "amf" "smf" "upf" "nf")
declare -a nodes=("master" "worker1" "worker2" "worker3" "worker4")

arrayIndex=0
for node in "${nodes[@]}"
do	
	echo ""
	echo "Labelling Node - $node"
	echo ""
    kubectl --kubeconfig=/etc/kubernetes/admin.conf label --overwrite nodes $node pcs-nf-type=${nodeLabels[arrayIndex]}
	echo ""
	echo "Finished Labelling Node - $node"
    echo ""
    arrayIndex=$((arrayIndex + 1))
done