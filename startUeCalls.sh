#!/usr/bin/env bash

numSession="$1"
experimentDir="$2"
pcsDir="$3"
sleepTime="$4"
for var in "${@:5}"
do
    sleep $sleepTime
    echo "UE-SIM IP Address is $var"
    cmd="curl --verbose --request POST --header \"Content-Type:application/json\" --data '{\"numSessions\":\"$numSession\",\"expDir\":\"$experimentDir\",\"subExpDir\":\"$pcsDir\"}'  http://$var:15692"
    echo "CMD is $cmd"
    eval "$cmd > /dev/null 2>&1 &"
done