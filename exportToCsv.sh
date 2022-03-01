#!/usr/bin/env bash

exp=/proj/sfcs-PG0/opt/Results

declare -a experimentDirAry=("Fully-Stateful" "Fully-Procedural-Stateless" "Fully-Transactional-Stateless" "All-NFs-Share-Udsf" "Amf-Smf-Share-Udsf" "N1n2-Amf-Update-Api-Disabled" "Nonblocking-Api-Enabled" "Upsert-Api-Enabled" "Replace-Api-Enabled" "Single-Read-Enabled")

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
    echo "numSessions,ueSessCount,dbAmfSessCount,dbSmfSessCount,dbUpfSessCount,amfQueueLength,smfQueueLength,upfQueueLength,amfTimeTaken,smfTimeTaken,upfTimeTaken,amfDbReadTime,amfDbWriteTime,amfDbTotalTime" >> $exp/$f1-data.csv
    for subexp in `seq 100 100 1000`
    do
        for j in `seq 1 1 10`
        do
            ueipn12File=$exp/$f1-$j/$subexp/pcs_ueips.txt_node12
            ueipn14File=$exp/$f1-$j/$subexp/pcs_ueips.txt_node14
            dbSessCntFile=$exp/$f1-$j/$subexp/sessCount.txt
            nfFile=$exp/$f1-$j/$subexp/nf_max_queue.txt
            mongoTopFIle=$exp/$f1-$j/$subexp/mongo_top.txt            
            if [ -f "$ueipn12File" ] && [ -f "$ueipn14File" ] && [ -f "$dbSessCntFile" ] && [ -f "$mongoTopFIle" ] && [ -f "$nfFile" ]; then
                ueSessCount=$(($(cat $ueipn12File | wc -l) + $(cat $ueipn14File | wc -l)))
                dbAmfSessCount=$(cat $dbSessCntFile | grep AMF | cut -d "," -f2)
                dbSmfSessCount=$(cat $dbSessCntFile | grep SMF | cut -d "," -f2)
                dbUpfSessCount=$(cat $dbSessCntFile | grep UPF | cut -d "," -f2)
                amfQueueLength=$(cat $nfFile | grep amf | cut -d "," -f2)
                smfQueueLength=$(cat $nfFile | grep smf | cut -d "," -f2)
                upfQueueLength=$(cat $nfFile | grep upf | cut -d "," -f2)
                amfTimeTaken=$(printf '%.9f\n' $(cat $nfFile | grep amf | cut -d "," -f3))
                smfTimeTaken=$(printf '%.9f\n' $(cat $nfFile | grep smf | cut -d "," -f3))
                upfTimeTaken=$(printf '%.9f\n' $(cat $nfFile | grep upf | cut -d "," -f3))
                amfDbReadTime=$(cat $mongoTopFIle | jq -r '.totals."pcs_db.amf".read.time')
                amfDbWriteTime=$(cat $mongoTopFIle | jq -r '.totals."pcs_db.amf".write.time')
                amfDbTotalTime=$(cat $mongoTopFIle | jq -r '.totals."pcs_db.amf".total.time')
                local nf_trans_times=$(serialize_trans_times "$nfFile")
                echo $nf_trans_times
                echo "$f1-$j-$subexp,$ueSessCount,$dbAmfSessCount,$dbSmfSessCount,$dbUpfSessCount,$amfQueueLength,$smfQueueLength,$upfQueueLength,$amfTimeTaken,$smfTimeTaken,$upfTimeTaken,$amfDbReadTime,$amfDbWriteTime,$amfDbTotalTime" >> $exp/$f1-data.csv
            fi
        done
        echo "Mean-$subexp, 0,0,0,0,0,0,0,0,0,0,0,0,0" >> $exp/$f1-data.csv
    done
done