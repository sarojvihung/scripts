#!/usr/bin/env bash

exp_dirs = {'Fully-Stateful':'Stateful',
            'Blocking-Api-Disabled':'Non-Blocking',
            'N1n2-Amf-Update-Api-Disabled': 'Delete-Create API',
            'TS-Amf-Smf-Share-UDSF':'AMF-SMF Share Database',
            'Fully-Procedural-Stateless':'Procedural Stateless',
            'N1n2-Smf-Update-Api-Disabled':'I dont really care',
            'TS-All-NFs-Share-UDSF':'All NFs Share Database',
            'Fully-Transactional-Stateless':'Transactional Stateless'}

declare -a experimentDirAry=("Fully-Stateful" "Fully-Procedural-Stateless" "Fully-Transactional-Stateless" "All-NFs-Share-Udsf" "Amf-Smf-Share-UDSF" "$experimentDirPrefix-6" "$experimentDirPrefix-7" "$experimentDirPrefix-8" "$experimentDirPrefix-9" "$experimentDirPrefix-10")

for exp in /proj/sfcs-PG0/opt/Results/* ;
do
    echo $exp
    f1=`basename $exp`
    rm -f $exp/$f1-data.csv
    for subexp in `seq 100 100 1000`
    do
        echo "$subexp-Sessions, ueSessCount, dbAmfSessCount, dbSmfSessCount, dbUpfSessCount, amfQueueLength, smfQueueLength, upfQueueLength, amfTimeTaken, smfTimeTaken, upfTimeTaken" >> $exp/$f1-data.csv
        for j in `seq 0 1 10`
        do
            ueipn12File=$exp/$f1-$j/$subexp/pcs_ueips.txt_node12
            ueipn14File=$exp/$f1-$j/$subexp/pcs_ueips.txt_node14
            dbSessCntFile=$exp/$f1-$j/$subexp/sessCount.txt
            nfFile=$exp/$f1-$j/$subexp/nf_max_queue.txt            
            if [ -f "$ueipn12File" ] && [ -f "$ueipn14File" ] && [ -f "$dbSessCntFile" ] && [ -f "$nfFile" ]; then
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
                echo "$f1-$j, $ueSessCount, $dbAmfSessCount, $dbSmfSessCount, $dbUpfSessCount, $amfQueueLength, $smfQueueLength, $upfQueueLength, $amfTimeTaken, $smfTimeTaken, $upfTimeTaken" >> $exp/$f1-data.csv
            fi
        done
        echo "Mean" >> $exp/$f1-data.csv
        echo "" >> $exp/$f1-data.csv
    done
done