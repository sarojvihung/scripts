#!/usr/bin/env bash

if [[ $# -eq 3 ]] ; then
	timeDur="$3"
    experimentDir="$2"
	echo "mongotop duration = $timeDur"
    echo "Experiment Directory = $experimentDir"
elif [[ $# -eq 2 ]] ; then
	experimentDir="$2"
	echo "Experiment Directory = $experimentDir"
elif [[ $# -eq 1 ]] ; then
    experimentDir=`date '+%F_%H-%M-%S'`
    echo "Experiment Directory = $experimentDir"
else
	echo "Expected at least 1 CLI arguments - Directory to save output"
    exit 1
fi

pcsDir="$1"
sleepTime=$((10 + timeDur))
scmd="cd /opt/ && mkdir -p Experiments && cd Experiments && mkdir -p $experimentDir && cd $experimentDir && mkdir -p $pcsDir && cd $pcsDir && rm -f mongo_stats.txt && (mongostat -o='host,mem.bits,metrics.document.returned.diff()=returned diff,metrics.document.returned=returned,metrics.document.inserted.diff()=inserted diff,metrics.document.inserted=inserted,metrics.document.updated.diff()=updated diff,metrics.document.updated=updated,metrics.document.deleted.diff()=deleted diff,metrics.document.deleted=deleted,getmore,command,dirty,used,flushes,vsize,res,qrw,arw,net_in,net_out,conn,time' >> /opt/Experiments/$experimentDir/$pcsDir/mongo_stats.txt &)"
tcmd="cd /opt/ && mkdir -p Experiments && cd Experiments && mkdir -p $experimentDir && cd $experimentDir && mkdir -p $pcsDir && cd $pcsDir && rm -f mongo_top.txt && (mongotop $timeDur >> /opt/Experiments/$experimentDir/$pcsDir/mongo_top.txt &)"

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
