#!/usr/bin/env bash

usage() { echo "Usage: $0 [-e <string>] [-s <string>] [-n <string>] [-u <string>]" 1>&2; exit 1; }

while getopts ":e:s:n:u:" o; do
    case "${o}" in
        e)
            e=${OPTARG}
            ;;
        s)
            s=${OPTARG}
            ;;
        n)
            n=${OPTARG}
            ;;
        u)
            ues+=("$OPTARG")
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

expdir=${e}
subexpdir=${s}
numSession=${n}
edir="/opt/Experiments/$expdir/$subexpdir"
cmd1="(mkdir -p $edir && cd $edir && nr-ue -c /opt/UERANSIM/config/open5gs/1ue.yaml -n $numSession > $edir/uesim.logs 2>&1 &) && exit"
cmd2="(sleep 30 && pkill -f nr-ue && sleep 5 && rm -f $edir/* &) && exit"
cmd3="(mkdir -p $edir && cd $edir && nr-ue -c /opt/UERANSIM/config/open5gs/ue.yaml -n $numSession > $edir/uesim.logs 2>&1 &) && exit"
for i in "${ues[@]}"; do
    node=node$i
	echo ""
	echo "Starting UE Sim on From Node - $node"
	echo ""
    if [[ $numSession -eq 1 ]] ; then
        ssh -o StrictHostKeyChecking=no root@$node "$cmd1"
        ssh -o StrictHostKeyChecking=no root@$node "$cmd2"
    else
        ssh -o StrictHostKeyChecking=no root@$node "$cmd3"
    fi
	echo ""
	echo "Started UE Sim on Node - $node"
        echo ""
        nodeNum=$((nodeNum + 1))
done