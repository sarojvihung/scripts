#!/usr/bin/env bash

if [[ $# -eq 4 ]] ; then
	numMasterNodes="$4"
	echo "Number of Master nodes = $numMasterNodes"
elif [[ $# -eq 3 ]] ; then
	numMasterNodes=1
	echo "Number of Master nodes = $numMasterNodes"
else
	echo "Expected at least 3 CLI arguments - Interface name, Number of worker nodes and total num of VMs to configure"
    exit 1
fi

intf="$1"
numWorkerNodes="$2"
numTotalNodes="$3"

#https://computingforgeeks.com/deploy-kubernetes-cluster-on-ubuntu-with-kubeadm/
#https://computingforgeeks.com/install-mirantis-cri-dockerd-as-docker-engine-shim-for-kubernetes/
#https://www.tutorialworks.com/difference-docker-containerd-runc-crio-oci/

#cri_socket="unix:///var/run/crio/crio.sock"
#cri_socket="unix:///run/containerd/containerd.sock"
cri_socket="unix:///run/cri-dockerd.sock"

echo ""
echo "Configuring Master Node"
echo ""

mcmd="bash /opt/scripts/configMasterNode.sh $intf $cri_socket"
eval $mcmd
kjoincmd=$(kubeadm token create --print-join-command)

echo ""
echo "Finished Configuring Master Node. Sleep for 120 seconds..."
echo ""

sleep 120

echo ""
echo "Configuring Worker Nodes"
echo ""


#cmd="rm -rf /opt/scripts/dockerInstall.sh && echo \"sh /opt/scripts/dockerInstall.sh\" >> /opt/configWorkerNode.sh && echo \"systemctl enable docker.service\" >> /opt/configWorkerNode.sh && echo \"swapoff -a\" >> /opt/configWorkerNode.sh && echo \"kubeadm reset --force\" >> /opt/configWorkerNode.sh && echo \"systemctl restart kubelet\" >> /opt/configWorkerNode.sh && echo \"eval $kjoincmd\" >> /opt/configWorkerNode.sh && chmod +x /opt/configWorkerNode.sh && sh /opt/configWorkerNode.sh && exit"
wcmd="cd /opt/scripts/ && git pull && bash /opt/scripts/configWorkerNode.sh \"$kjoincmd\" && exit"
nodeNum=$((0 + numMasterNodes))
startNodeNum=$((0 + numMasterNodes))
endNodeNum=$((numWorkerNodes + numMasterNodes - 1))
for i in $(seq $startNodeNum $endNodeNum);
do	
	node=node$nodeNum
	echo ""
	echo "Configuring Node - $node"
	echo ""
	ssh -o StrictHostKeyChecking=no root@$node "$wcmd"
	echo ""
	echo "Finished Configuring Worker Node - $node"
        echo ""
        nodeNum=$((nodeNum + 1))
done

echo ""
echo "Finished Configuring Worker Nodes"
echo ""

echo ""
echo "Started Configuring RAN Nodes"
echo ""

rcmd="cd /opt/scripts/ && git pull && bash /opt/scripts/configRanNode.sh && exit"
nodeNum=$(($numWorkerNodes + $numMasterNodes))
startNodeNum=$(($numWorkerNodes + $numMasterNodes))
endNodeNum=$((numTotalNodes - 1))
for i in $(seq $startNodeNum $endNodeNum);
do	
	node=node$nodeNum
	echo ""
	echo "Configuring Node - $node"
	echo ""
	ssh -o StrictHostKeyChecking=no root@$node "$rcmd"
	echo ""
	echo "Finished Configuring RAN Node - $node"
        echo ""
        nodeNum=$((nodeNum + 1))
done

echo ""
echo "Finished Configuring RAN Nodes"
echo ""
