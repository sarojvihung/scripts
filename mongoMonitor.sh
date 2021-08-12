#!/usr/bin/env bash

#apt-get update && apt -y install git vim && git clone https://github.com/UmakantKulkarni/scripts

if [[ $# -eq 3 ]] ; then
	timeDur="$3"
	echo "mongotop duration = $timeDur"
elif [[ $# -eq 2 ]] ; then
    timeDur=60
    echo "mongotop duration = $timeDur"
else
	echo "Expected at least 2 CLI arguments - Exp Directory & sub-exp directory to save output"
    exit 1
fi

experimentDir="$1"
pcsDir="$2"
sleepTime=$((10 + timeDur))
scmd="cd /opt/ && mkdir -p Experiments && cd Experiments && mkdir -p $experimentDir && cd $experimentDir && mkdir -p $pcsDir && cd $pcsDir && rm -f mongo_stats.txt && (mongostat -o='host,mem.bits,metrics.document.returned.diff()=returned diff,metrics.document.returned=returned,metrics.document.inserted.diff()=inserted diff,metrics.document.inserted=inserted,metrics.document.updated.diff()=updated diff,metrics.document.updated=updated,metrics.document.deleted.diff()=deleted diff,metrics.document.deleted=deleted,getmore,command,dirty,used,flushes,vsize,res,qrw,arw,net_in,net_out,conn,time' >> /opt/Experiments/$experimentDir/$pcsDir/mongo_stats.txt &)"
tcmd="cd /opt/ && mkdir -p Experiments && cd Experiments && mkdir -p $experimentDir && cd $experimentDir && mkdir -p $pcsDir && cd $pcsDir && rm -f mongo_top.txt && (mongotop --json $timeDur >> /opt/Experiments/$experimentDir/$pcsDir/mongo_top.txt &)"

echo ""
echo "Starting mongostat script"
echo ""
eval "$scmd"
echo ""
echo "Starting mongotop script"
echo ""
eval "$tcmd"
echo ""

echo ""
echo "Waiting/Sleeping for $sleepTime seconds"
echo ""
sleep $sleepTime

echo "Stopping mongostat script"
echo ""
kscmd="pkill -f mongostat"
eval "$kscmd"
echo ""
echo "Stopping mongotop script"
echo ""
ktcmd="pkill -f mongotop"
eval "$ktcmd"
echo ""
echo "Finished mongo-monitor script"
echo ""
