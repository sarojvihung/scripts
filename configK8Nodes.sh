#!/usr/bin/env bash

if [ "$#" -lt 1 ]; then
	echo "Expected at least 1 CLI argument - Interface name"
    exit 1
elif [ "$#" -eq 1 ]; then
	repeatFlag="0"
	echo "repeatFlag is $repeatFlag"
elif [ "$#" -eq 2 ]; then
	repeatFlag="$2"
	echo "repeatFlag is $repeatFlag"
fi

intf="$1"
masterNode="0"
declare -a workerNodes=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11")
declare -a ranNodes=("12" "13" "14" "15")

#https://computingforgeeks.com/deploy-kubernetes-cluster-on-ubuntu-with-kubeadm/
#https://computingforgeeks.com/install-mirantis-cri-dockerd-as-docker-engine-shim-for-kubernetes/
#https://www.tutorialworks.com/difference-docker-containerd-runc-crio-oci/

#cri_socket="unix:///var/run/crio/crio.sock"
#cri_socket="unix:///run/containerd/containerd.sock"
#cri_socket="unix:///run/cri-dockerd.sock"

echo ""
echo "Configuring Master Node"
echo ""

mcmd="cd /opt/scripts/ && bash /opt/scripts/configMasterNode.sh $intf $repeatFlag"
ssh -o StrictHostKeyChecking=no root@node$masterNode "$mcmd"
kjoincmdorig="kubeadm token create --print-join-command"
kjoincmd=$(ssh -o StrictHostKeyChecking=no root@node$masterNode "$kjoincmdorig")

echo ""
echo "Finished Configuring Master Node. Sleep for 30 seconds..."
echo ""

sleep 30

echo ""
echo "Configuring Worker Nodes with command - $kjoincmd"
echo ""


wcmd="cd /opt/scripts/ && bash /opt/scripts/configWorkerNode.sh $repeatFlag \"$kjoincmd\" && exit"
for nodeNum in "${workerNodes[@]}"
do	
	node=node$nodeNum
	echo ""
	echo "Configuring Node - $node"
	echo ""
	ssh -o StrictHostKeyChecking=no root@$node "$wcmd"
	echo ""
	echo "Finished Configuring Worker Node - $node"
    echo ""
done

echo ""
echo "Finished Configuring Worker Nodes"
echo ""

if [ $repeatFlag = "0" ] ; then
	echo ""
	echo "Started Configuring RAN Nodes"
	echo ""

	rcmd="cd /opt/scripts/ && bash /opt/scripts/configRanNode.sh && exit"
	for nodeNum in "${ranNodes[@]}"
	do	
		node=node$nodeNum
		echo ""
		echo "Configuring Node - $node"
		echo ""
		ssh -o StrictHostKeyChecking=no root@$node "$rcmd"
		echo ""
		echo "Finished Configuring RAN Node - $node"
		echo ""
	done

	echo ""
	echo "Finished Configuring RAN Nodes"
	echo ""
fi
