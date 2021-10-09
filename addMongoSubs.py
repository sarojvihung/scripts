#!/usr/bin/env python3

import sys
import pymongo
import bson

num_subs = int(sys.argv[1])
#mongo_ip = sys.argv[2]
#mongo_port = 27017
imsi = 208930000000000

slice_data = [
    {
        "sst": 1,
        "default_indicator": True,
        "session": [
            {
                "name": "internet",
                "type": 3, "pcc_rule": [], "ambr": {"uplink": {"value": 1, "unit": 3}, "downlink": {"value": 1, "unit": 3}},
                "qos": {
                    "index": 9,
                    "arp": {"priority_level": 8, "pre_emption_capability": 1, "pre_emption_vulnerability": 1}
                }
            }
        ]
    }
]

sub_data = {
    "imsi": "208930000000000",
    "subscribed_rau_tau_timer": 12,
    "network_access_mode": 2,
    "subscriber_status": 0,
    "access_restriction_data": 32,
    "slice": slice_data,
    "ambr": {"uplink": {"value": 1, "unit": 3}, "downlink": {"value": 1, "unit": 3}},
    "security": {
        "k": "465B5CE8 B199B49F AA5F0A2E E238A6BC",
        "amf": "8000",
        'op': None,
        "opc": "E8ED289D EBA952E4 283B54E8 8E6183CA",
        "sqn": bson.Int64(129)
    },
    "schema_version": 1,
    "__v": 0
}

#myclient = pymongo.MongoClient("mongodb://" + str(mongo_ip) + ":" + str(mongo_port) + "/")
myclient = pymongo.MongoClient("mongodb://mongodb-svc:27017/")
mydb = myclient["open5gs"]
mycol = mydb["subscribers"]

for i in range(0, num_subs+1):
    sub_data["imsi"] = "{}".format(imsi)
    mycol.update_one(sub_data, {'$set': sub_data}, upsert=True)
    print("Added subscriber {} with IMSI : {}".format(i+1, imsi))
    imsi = imsi + 1
