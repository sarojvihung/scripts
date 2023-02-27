#!/usr/bin/env bash

commonTZ="MDT"
exp=/opt/Results
cpuapp="open5gs-amfd"

declare -a experimentDirAry=("secure" "noistio")

for f1 in "${experimentDirAry[@]}"
do
    echo "Working on $exp/$f1"
    echo " "
    subexp=800
    if [[ $f1 == "secure" ]]; then
        jarray=(1 4 5 9)
    elif [[ $f1 == "noistio" ]]; then
        jarray=(2 5 7 8 )
    fi
    for j in ${jarray[@]}
    do
        amfTopFile=$exp/$f1-$j/$subexp/top_data_node1.txt
        topCpuOpFile=$exp/$f1-$j/$subexp/topCpuOp$j.csv
        queueLenFile=$exp/$f1-$j/$subexp/queueLen$j.csv
        rm -f $topCpuOpFile
        rm -f $queueLenFile
        
        echo "Working on $topCpuOpFile"
        sjCount=$(cat $amfTopFile | grep systemd-journal | wc -l)
        echo "UTC-Time, Time-Diff, CPU-Usage" >> $topCpuOpFile
        timestamps=( $(cat $amfTopFile | grep 2023- | grep -o '\-\-.*' | cut -c 3-) )
        if (( $sjCount < 5 )); then
            timestamps=("${timestamps[@]:1}")
        fi
        cpusage=( $(cat $amfTopFile | grep $cpuapp | awk '{print $9}') )
        basecpu="0.0"
        k=0
        for i in "${!cpusage[@]}";
        do
            if (( $(echo "${cpusage[$i]} > $basecpu" |bc -l) )); then
                mdtTs=${timestamps[$i]}
                if [[ $k == 0 ]]; then
                    firstTs=$(TZ=$commonTZ date -d "$mdtTs MDT - 0.2 second"  +'%T.%3N')
                    firstEpochTs=$(date -d "$firstTs" +"%s.%3N")
                    echo "$firstTs, 0, $basecpu" >> $topCpuOpFile
                fi
                utcTs=$(TZ=$commonTZ date -d "$mdtTs MDT"  +'%T.%3N')
                epochTs=$(date -d "$utcTs" +"%s.%3N")
                timediff=$(echo -e "$epochTs-$firstEpochTs" | bc)
                timediff=$(echo -e "$timediff*1000" | bc | rev | cut -c 5- | rev)
                echo "$utcTs, $timediff, ${cpusage[$i]}" >> $topCpuOpFile
                k=$k+1
            fi
        done
        utcTs=$(TZ=$commonTZ date -d "$mdtTs MDT + 0.2 second"  +'%T.%3N')
        epochTs=$(date -d "$utcTs" +"%s.%3N")
        timediff=$(echo -e "$epochTs-$firstEpochTs" | bc)
        timediff=$(echo -e "$timediff*1000" | bc | rev | cut -c 5- | rev)
        echo "$utcTs, $timediff, $basecpu" >> $topCpuOpFile
        
        echo "Working on $queueLenFile"
        echo "UTC-Time, Time-Diff, Queue-Length" >> $queueLenFile
        mints=$(date -d "$(cat $topCpuOpFile | sed -n 2p | awk '{print $1}' | rev | cut -c 2- | rev)" +"%s.%3N")
        maxts=$(date -d "$(cat $topCpuOpFile | tail -n1 | awk '{print $1}' | rev | cut -c 2- | rev)" +"%s.%3N")
        #utcTs=( $(cat $exp/$f1-$j/$subexp/open5gs-amf-deployment-*_logs.txt | grep " ogs_queue_size is" | grep "PCS " | awk '{print $2}' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | rev | cut -c 2- | rev) )
        #queuelens=( $(cat $exp/$f1-$j/$subexp/open5gs-amf-deployment-*_logs.txt | grep " ogs_queue_size is" | grep "PCS " | awk '{print $9}') )
        sed -i '/Open5GS daemon v2/d' $exp/$f1-$j/$subexp/open5gs-amf-deployment-*_logs.txt
        cat $exp/$f1-$j/$subexp/open5gs-amf-deployment-*_logs.txt | grep " ogs_queue_size is" | grep "PCS " | awk '{print $1,$2}' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | rev | cut -c 2- | rev > /tmp/utcTs.txt
        cat $exp/$f1-$j/$subexp/open5gs-amf-deployment-*_logs.txt | grep " ogs_queue_size is" | grep "PCS " | awk '{print $9}' > /tmp/queuelens.txt
        i=0
        while IFS="" read -r line || [ -n "$line" ]
        do
            lineNum=$(( ++i ))
            utcTs=$(TZ=$commonTZ date -d "$line MDT"  +'%T.%3N')
            opfmt=$(echo $utcTs | cut -c 1-)
            epochTs=$(date -d "$utcTs" +"%s.%3N")
            if (( $(echo "$epochTs > $mints" |bc -l) )); then
                if (( $(echo "$epochTs < $maxts" |bc -l) )); then
                    timediff=$(echo -e "$epochTs-$mints" | bc)
                    timediff=$(echo -e "$timediff*1000" | bc | rev | cut -c 5- | rev)
                    qln=$(cat /tmp/queuelens.txt | sed -n ${lineNum}p)
                    echo "$opfmt, $timediff, $qln" >> $queueLenFile
                fi
            fi
        done < /tmp/utcTs.txt
        rm -f /tmp/utcTs.txt
        rm -f /tmp/queuelens.txt
        echo "Completed processing files from $exp/$f1-$j/$subexp/"
        echo " "
    done
done