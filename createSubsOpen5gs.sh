#!/usr/bin/env bash
numSubs="$1"
imsi=208930000000000
IP=172.18.0.4
PORT=32539
username=admin
password=1423

if [ "$#" -eq 2 ]; then
  framenum=$(tshark -r ui.pcapng -Y 'http && http.request.uri=="/api/db/Subscriber"' | sed -n '1p' | awk '{print $1}')
  cookie=$(tshark -r ui.pcapng -Y frame.number==$framenum -T json | grep '"http.cookie": "connect.sid=' | awk -v FS='(sid=|",)' '{print $2}')
  auth=$(tshark -r ui.pcapng -Y frame.number==$framenum -T json | grep "Authorization: Bearer" | awk -v FS='(Bearer |\r\n",)' '{print $2}' | sed 's/.\{6\}$//')
  xcrf=$(tshark -r ui.pcapng -Y frame.number==$framenum -T json | grep "X-CSRF-TOKEN:" | awk -v FS='(X-CSRF-TOKEN: |\r\n",)' '{print $2}' | sed 's/.\{6\}$//')
else 
  cookie="s%3Ad5xw8H8mdjxx61rwlH2mp8p1id_rxApP.XHgFK7hKXjOmgt8RBrdXBQjMV4B6Mj4%2F8tSJwMdSNIA"
  auth="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7Il9pZCI6IjYwZjUwOTVhNDgwYjI5MDAxOWE3ZjIzNCIsInVzZXJuYW1lIjoiYWRtaW4iLCJyb2xlcyI6WyJhZG1pbiJdfSwiaWF0IjoxNjI2NzE4NjcxfQ.hqsVKeDTwHe0VsSE7Oaz4aD9ARxYBeCjRg_aX7wLmvU"
  xcrf="41XLxwXizPGQuRCHgobvFKfOEhqvV9Ea4xwjI="
fi

ContentTypeHeader="Content-Type: application/json"
CookieHeader="Cookie: connect.sid=$cookie"
AuthHeader="Authorization: Bearer $auth"
XCSRFTOKENHeader="X-CSRF-TOKEN: $xcrf"
URI="http://$IP:$PORT/api/db/Subscriber"

jsonStr='{"imsi":"208930000000027","security":{"k":"465B5CE8 B199B49F AA5F0A2E E238A6BC","amf":"8000","op_type":0,"op_value":"E8ED289D EBA952E4 283B54E8 8E6183CA","op":null,"opc":"E8ED289D EBA952E4 283B54E8 8E6183CA"},"ambr":{"downlink":{"value":1,"unit":3},"uplink":{"value":1,"unit":3}},"slice":[{"sst":1,"default_indicator":true,"session":[{"name":"internet","type":3,"pcc_rule":[],"ambr":{"uplink":{"value":1,"unit":3},"downlink":{"value":1,"unit":3}},"qos":{"index":9,"arp":{"priority_level":8,"pre_emption_capability":1,"pre_emption_vulnerability":1}}}]}],"schema_version":1}'

run_loop () {
  for i in $(seq 1 $numSubs);
  do
    imsi=$((imsi+1))
    variable="$imsi"
    jsonData="$(jq --arg variable "$variable" '.imsi = $variable' <<<$jsonStr)"
    status_code=$(curl --write-out '%{http_code}\n' --silent --output /dev/null -u $username:$password -H "$ContentTypeHeader" -H "$CookieHeader"  -H "$AuthHeader" -H "$XCSRFTOKENHeader" --request POST --data "$jsonData" $URI)
    if [[ "$status_code" -ne 201 ]] ; then
      echo "Failed to create subscriber #$i with imsi $imsi"
    else
      echo "Created subscriber #$i with imsi $imsi"
    fi
  done
}

run_loop
