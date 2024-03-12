#!/usr/bin/env python3

import os
import json
import pandas as pd
from glob import glob
json_data = []

expName = "/opt/Experiments/IstioBench1"
IstioCsvLogFile = "/opt/Experiments/IstioBench1.csv"
NFs = ["amf" "smf" "ausf" "bsf" "pcf" "nrf" "nssf" "udr" "udm"]
json_data = []

for runCount in range(1,2):
    expRunDir = "{}-{}".format(expName,runCount)
    for sessionCount in list(range(100, 401, 100)):
        expSessionDir = os.path.join(expRunDir,sessionCount)
        for nf in NFs:
            nfJsonLogFileList = glob("{}/{}IstioLogs.json".format(expSessionDir, nf))
            if len(nfJsonLogFileList) > 0:
                nfJsonLogFile = nfJsonLogFileList[0]
            else:
                continue
            print("Working on {}".format(nfJsonLogFile))
            with open(nfJsonLogFile) as f:
                for line in f:
                    try:
                        json_line = json.loads(line.strip())
                        json_line["NF"] = nf
                        json_line["sessionCount"] = sessionCount
                        json_data.append(json_line)
                    except:
                        pass

df = pd.DataFrame(json_data)
df.to_csv(IstioCsvLogFile, index=False)