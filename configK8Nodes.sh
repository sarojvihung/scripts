#!/usr/bin/env bash

if [[ $# -ne 2 ]] ; then
    echo 'Expected 2 CLI arguments - Interface name and Number of worker nodes to configure'
    exit 1
fi

echo ""
echo "Configuring Master Node"
echo ""

intf="$1"
numNodes="$2"
nodeNum=1

mcmd="bash /opt/scripts/configMasterNode.sh $intf"
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
wcmd="bash /opt/scripts/configWorkerNode.sh \"$kjoincmd\" && exit"
for i in $(seq 1 $numNodes);
do	
	node=node$nodeNum
	echo ""
	echo "Configuring Node - $node"
	echo ""
	ssh -o StrictHostKeyChecking=no root@$node "$wcmd"
	echo ""
	echo "Finished Configuring Node - $node"
        echo ""
        nodeNum=$((nodeNum+1))
done

echo ""
echo "Finished Configuring Worker Nodes"
echo ""
