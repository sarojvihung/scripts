#!/bin/bash
while true
do
        date >> kt_data.txt
        kubectl top pods -A --containers >> kt_data.txt
        echo " " >> kt_data.txt
        sleep 1
done