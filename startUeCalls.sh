#!/usr/bin/env bash

usage() { echo "Usage: $0 [-e <string>] [-s <string>] [-n <string>]" 1>&2; exit 1; }

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
cmd1="mkdir -p $edir && cd $edir && rm -f $edir/* && nr-ue -c /opt/UERANSIM/config/open5gs/1ue.yaml -n $numSession > $edir/uesim.logs &"
cmd2="pkill -f nr-ue && sleep 2 && rm -f $edir/*"
cmd3="mkdir -p $edir && cd $edir && rm -f $edir/* && nr-ue -c /opt/UERANSIM/config/open5gs/ue.yaml -n $numSession > $edir/uesim.logs &"


if [[ $numSession -eq 1 ]] ; then
    eval "$cmd1"
    sleep 20
    eval "$cmd2"
else
    eval "$cmd3"
fi
