#!/usr/bin/env bash
Hostname=$(hostname --short)
while true
do
        date +"%F--%T.%N" >> top_data_$Hostname.txt
        COLUMNS=500 top -b -n 1 >> top_data_$Hostname.txt 2>&1 &
        echo " " >> top_data_$Hostname.txt
        sleep 0.2
done