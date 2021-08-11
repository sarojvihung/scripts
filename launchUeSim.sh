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
cmd="mkdir -p $edir && cd $edir && (bash /opt/scripts/startUeCalls.sh -e $expdir -s $subexpdir -n $numSession &) && exit"

for i in "${ues[@]}";
do
    node=node$i
    echo ""
    echo "Starting UE Sim on Node - $node"
    echo ""
    ssh -o StrictHostKeyChecking=no root@$node "$cmd"
    echo ""
    echo "Started UE Sim on Node - $node"
        echo ""
        nodeNum=$((nodeNum + 1))
done
    