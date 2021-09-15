#!/usr/bin/env bash

for exp in Blocking-Api-Disabled/* ;
do
    echo $exp
    f1=`basename $exp`
    for subexp in `seq 100 100 1000`
    do
        for p in `seq 0 1 10`
        do
            filename=$exp/$subexp/top_data_node${p}.txt
            echo "Working on $filename"
            awk '/open5gs|docker|kube|calico|container|bash|python|systemd-journal|2021-|top -|Tasks:|Cpu\(s\)|MiB Mem|MiB Swap:/' $filename > $filename-tmp
            sed '/2021-/s/^/\n/' $filename-tmp > $filename
            rm -f $filename-tmp
        done
    done
done