#!/usr/bin/env bash

declare -a NFs=("amf" "smf" "ausf" "bsf" "pcf" "nrf" "nssf" "udr" "udm")
exp="/opt/Experiments"
echo $exp
f1="IstioBench1"
for subexp in `seq 100 100 400`
do
    for j in `seq 1 1 1`
    do
        ueLogFile=$exp/$f1-$j/$subexp/uesim.logs
        nfFile=$exp/$f1-$j/$subexp/nf_max_queue.txt
        for nf in "${NFs[@]}"
        do
            nfIstioLogFile=$exp/$f1-$j/$subexp/open5gs-${nf}-deployment-*_istio_logs.txt
            echo "Working on $nfIstioLogFile"
            LINE_NUM=$(grep -n "Envoy proxy is ready" $nfIstioLogFile | cut -d: -f1)
            tail -n +$((LINE_NUM + 1)) $nfIstioLogFile > $exp/$f1-$j/$subexp/${nf}IstioLogs.json
            sed -i '/Starting tracking the heap/d' $exp/$f1-$j/$subexp/${nf}IstioLogs.json
            sed -i '/^[[:space:]]*$/d' $exp/$f1-$j/$subexp/${nf}IstioLogs.json
        done
    done
done



