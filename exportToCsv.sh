#!/usr/bin/env bash

exp=/opt/Results

declare -a experimentDirAry=("nonsecure" "secure" "noistio")

declare -a amf_params=("CSCAmfReadIOTime" "CSCAmfReadSDTime" "CSCAmfWriteIOTime" "CSCAmfWriteSDTime" "N1N2AmfReadIOTime" "N1N2AmfReadSDTime" "N1N2AmfWriteIOTime" "N1N2AmfWriteSDTime" "USCAmfReadIOTime" "USCAmfReadSDTime" "USCAmfWriteIOTime" "USCAmfWriteSDTime")
    
declare -a smf_params=("CSCAmfReadIOTime" "CSCAmfReadSDTime" "CSCAmfWriteIOTime" "CSCAmfWriteSDTime" "N1N2AmfReadIOTime" "N1N2AmfReadSDTime" "N1N2AmfWriteIOTime" "N1N2AmfWriteSDTime" "USCAmfReadIOTime" "USCAmfReadSDTime" "USCAmfWriteIOTime" "USCAmfWriteSDTime")
    
declare -a upf_params=("CSCAmfReadIOTime" "CSCAmfReadSDTime" "CSCAmfWriteIOTime" "CSCAmfWriteSDTime" "N1N2AmfReadIOTime" "N1N2AmfReadSDTime" "N1N2AmfWriteIOTime" "N1N2AmfWriteSDTime" "USCAmfReadIOTime" "USCAmfReadSDTime" "USCAmfWriteIOTime" "USCAmfWriteSDTime")

serialize_trans_times () {
    nf_file="$1"
    tran_times=""

    for tra in "${amf_params[@]}"
    do
        param_time=$(cat $nf_file | grep $tra | cut -d "," -f2)
        tran_times=$tran_times,$param_time
    done
    for tra in "${smf_params[@]}"
    do
        param_time=$(cat $nf_file | grep $tra | cut -d "," -f2)
        tran_times=$tran_times,$param_time
    done
    for tra in "${upf_params[@]}"
    do
        param_time=$(cat $nf_file | grep $tra | cut -d "," -f2)
        tran_times=$tran_times,$param_time
    done
    echo $tran_times
}

for f1 in "${experimentDirAry[@]}"
do
    rm -f $exp/$f1-data.csv
    echo "numSessions,ueSessCount,amfQueueLength,smfQueueLength,upfQueueLength,amfTimeTaken,smfTimeTaken,upfTimeTaken" >> $exp/$f1-data.csv
    for subexp in `seq 100 100 1000`
    do
        for j in `seq 1 1 10`
        do
            ueipn13File=$exp/$f1-$j/$subexp/pcs_ueips.txt_node13
            ueipn15File=$exp/$f1-$j/$subexp/pcs_ueips.txt_node15
            nfFile=$exp/$f1-$j/$subexp/nf_max_queue.txt
            if [ -f "$ueipn13File" ] && [ -f "$ueipn15File" ] && [ -f "$nfFile" ]; then
                ueSessCount=$(($(cat $ueipn13File | wc -l) + $(cat $ueipn15File | wc -l)))
                amfQueueLength=$(cat $nfFile | grep amf | cut -d "," -f2)
                smfQueueLength=$(cat $nfFile | grep smf | cut -d "," -f2)
                upfQueueLength=$(cat $nfFile | grep upf | cut -d "," -f2)
                amfTimeTaken=$(printf '%.9f\n' $(cat $nfFile | grep amf | cut -d "," -f3))
                smfTimeTaken=$(printf '%.9f\n' $(cat $nfFile | grep smf | cut -d "," -f3))
                upfTimeTaken=$(printf '%.9f\n' $(cat $nfFile | grep upf | cut -d "," -f3))
                echo "$f1-$j-$subexp,$ueSessCount,$amfQueueLength,$smfQueueLength,$upfQueueLength,$amfTimeTaken,$smfTimeTaken,$upfTimeTaken" >> $exp/$f1-data.csv
            fi
        done
        echo "Mean-$subexp, 0,0,0,0,0,0,0" >> $exp/$f1-data.csv
    done
done