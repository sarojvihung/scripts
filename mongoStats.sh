#!/usr/bin/env bash

if [[ $# -eq 2 ]] ; then
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
startNodeNum=0
endNodeNum=$((0 + numWorkerNodes))
ocmd="cd /opt/ && mkdir -p Experiments && cd Experiments && mkdir -p $experimentDir && cd $experimentDir && mkdir -p $pcsDir && cd $pcsDir && rm -f mongo_stats.txt && mongostat >> /opt/Experiments/$experimentDir/$pcsDir/mongo_stats.txt"
echo ""
echo "Starting mongostat script"
echo ""
eval "$ocmd"
