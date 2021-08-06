#!/usr/bin/env bash

numSession="$1"
for var in "$@"
do
    if [[ $var =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "UE-SIM IP Address is $var"
        cmd="curl --verbose --request POST --header \"Content-Type:application/json\" --data '{\"numSessions\":\"$numSession\"}'  http://$var:15692"
        echo "CMD is $cmd"
        eval "$cmd > /dev/null 2>&1 &"
    else
        echo "Number of sessions = $numSession"
    fi
done