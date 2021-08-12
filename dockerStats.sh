#!/usr/bin/env bash
Hostname=$(hostname --short)
while true
do
        date >> docker_data_$Hostname.txt
        COLUMNS=500 docker stats --all --no-stream >> docker_data_$Hostname.txt
        echo " " >> docker_data_$Hostname.txt
done