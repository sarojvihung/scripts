#!/usr/bin/env bash
Hostname=$(hostname --short)
while true
do
        date >> top_data_$Hostname.txt
        COLUMNS=500 top -b -n 1 >> top_data_$Hostname.txt
        echo " " >> top_data_$Hostname.txt
        sleep 0.2
done