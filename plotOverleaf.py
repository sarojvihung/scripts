#!/usr/bin/env python3

import re
import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns
import seaborn

fs_amf_time = []
fps_amf_time = []
fts_amf_time = []
ansu_amf_time = []
amsu_amf_time = []
nauad_amf_time = []
nae_amf_time = []
fts_db_time = []
nauad_db_time = []

dict_map = {"Fully-Stateful":{"amfTimeTaken": fs_amf_time, "plotname": "Stateful"},
            "Fully-Procedural-Stateless":{"amfTimeTaken": fps_amf_time, "plotname": "Procedural Stateless"},
            "Fully-Transactional-Stateless":{"amfTimeTaken": fts_amf_time, "plotname": "Transactional Stateless", "amfDbTotalTime": fts_db_time},
            "Nonblocking-Api-Enabled":{"amfTimeTaken": nae_amf_time, "plotname": "Non-Blocking"},
            "N1n2-Amf-Update-Api-Disabled":{"amfTimeTaken": nauad_amf_time, "plotname": "Delete-Create API", "amfDbTotalTime": nauad_db_time},
            "Amf-Smf-Share-Udsf":{"amfTimeTaken": amsu_amf_time, "plotname": "AMF-SMF Share Database"},
            "All-NFs-Share-Udsf":{"amfTimeTaken": ansu_amf_time, "plotname": "All NFs Share Database"}
            }
dict_map_keys = list(dict_map.keys())
session_list = [i*100 for i in range(1,11)]

def main():

    for folder_name in dict_map_keys:
        csv_file = "{}-data.csv".format(folder_name)
        df = pd.read_csv(csv_file)
        prev_mean_index = 0
        for row_section in session_list:
            this_mean_index = df.index[df["numSessions"]=="Mean-{}".format(row_section)].values[0]
            for col in list(df.columns.values)[1:]:
                col_mean = np.mean(df[prev_mean_index:this_mean_index][col].values)
                df[col].values[this_mean_index] = col_mean
                if col == "amfTimeTaken":
                    dict_map[folder_name]["amfTimeTaken"].append(col_mean)
                elif col == "amfDbTotalTime" and "amfDbTotalTime" in dict_map[folder_name]:
                    dict_map[folder_name]["amfDbTotalTime"].append(col_mean)
            prev_mean_index = this_mean_index+1
        df.to_csv(csv_file, index=False)
    
    df = pd.DataFrame({"Number-of-Sessions": session_list, "Time-{}".format(dict_map_keys[0]): fs_amf_time, "Time-{}".format(dict_map_keys[2]): fts_amf_time, "Change %": [0]*10})
    df['Change %'] = (df["Time-{}".format(dict_map_keys[2])] - df["Time-{}".format(dict_map_keys[0])])*(100/(df["Time-{}".format(dict_map_keys[0])]))
    df1 = df.append({"Number-of-Sessions": "Average", "Time-{}".format(dict_map_keys[0]): "-", "Time-{}".format(dict_map_keys[2]): "-", 'Change %': np.mean(df["Change %"].values)}, ignore_index=True)
    df1.to_csv("Stateful-Vs-Stateless-TimeTaken.csv", index=False)

    df = pd.DataFrame({"Number-of-Sessions": session_list, "Time-{}".format(dict_map_keys[1]): fps_amf_time, "Time-{}".format(dict_map_keys[2]): fts_amf_time, "Change %": [0]*10})
    df['Change %'] = (df["Time-{}".format(dict_map_keys[2])] - df["Time-{}".format(dict_map_keys[1])])*(100/(df["Time-{}".format(dict_map_keys[1])]))
    df2 = df.append({"Number-of-Sessions": "Average", "Time-{}".format(dict_map_keys[1]): "-", "Time-{}".format(dict_map_keys[2]): "-", 'Change %': np.mean(df["Change %"].values)}, ignore_index=True)
    df2.to_csv("Procedural-Vs-Transactional-Time-Taken.csv", index=False)

    df = pd.DataFrame({"Number-of-Sessions": session_list, "Time-{}".format(dict_map_keys[3]): nae_amf_time, "Time-Blocking-Api-Enabled": fts_amf_time, "Change %": [0]*10})
    df['Change %'] = (df["Time-Blocking-Api-Enabled"] - df["Time-{}".format(dict_map_keys[3])])*(100/(df["Time-{}".format(dict_map_keys[3])]))
    df3 = df.append({"Number-of-Sessions": "Average", "Time-{}".format(dict_map_keys[3]): "-", "Time-Blocking-Api-Enabled": "-", 'Change %': np.mean(df["Change %"].values)}, ignore_index=True)
    df3.to_csv("Blocking-Vs-Nonblocking-Time-Taken.csv", index=False)

    df = pd.DataFrame({"Number-of-Sessions": session_list, "Time-Delete-Create-Api-Enabled": nauad_amf_time, "Time-Update-Api-Enabled": fts_amf_time, "Change %": [0]*10})
    df['Change %'] = (df["Time-Update-Api-Enabled"] - df["Time-Delete-Create-Api-Enabled"])*(100/(df["Time-Delete-Create-Api-Enabled"]))
    df4 = df.append({"Number-of-Sessions": "Average", "Time-Delete-Create-Api-Enabled": "-", "Time-Update-Api-Enabled": "-", 'Change %': np.mean(df["Change %"].values)}, ignore_index=True)
    df4.to_csv("Update-Vs-Delete-Create-Time-Taken.csv", index=False)

    df = pd.DataFrame({"Number-of-Sessions": session_list, "Time-{}".format(dict_map_keys[5]): amsu_amf_time, "Time-{}".format(dict_map_keys[6]): ansu_amf_time, "Time-Not-Sharing-Udsf": fts_amf_time, "Change - AmfSmf Vs Unshared": [0]*10, "Change - AllShared Vs Unshared": [0]*10})
    df['Change - AmfSmf Vs Unshared'] = (df["Time-Not-Sharing-Udsf"] - df["Time-{}".format(dict_map_keys[5])])*(100/(df["Time-{}".format(dict_map_keys[5])]))
    df['Change - AllShared Vs Unshared'] = (df["Time-Not-Sharing-Udsf"] - df["Time-{}".format(dict_map_keys[6])])*(100/(df["Time-{}".format(dict_map_keys[6])]))
    df5 = df.append({"Number-of-Sessions": "Average", "Time-{}".format(dict_map_keys[5]): "-", "Time-{}".format(dict_map_keys[6]): "-", "Time-Not-Sharing-Udsf": "-", 'Change - AmfSmf Vs Unshared': np.mean(df["Change - AmfSmf Vs Unshared"].values), 'Change - AllShared Vs Unshared': np.mean(df["Change - AllShared Vs Unshared"].values)}, ignore_index=True)
    df5.to_csv("Shared-Vs-Unshared-Udsf-Time-Taken.csv", index=False)

    df = pd.DataFrame({"Number-of-Sessions": session_list, "Time-Delete-Create-Api-Enabled": nauad_db_time, "Time-Update-Api-Enabled": fts_db_time, "Change %": [0]*10})
    df['Change %'] = (df["Time-Update-Api-Enabled"] - df["Time-Delete-Create-Api-Enabled"])*(100/(df["Time-Delete-Create-Api-Enabled"]))
    df6 = df.append({"Number-of-Sessions": "Average", "Time-Delete-Create-Api-Enabled": "-", "Time-Update-Api-Enabled": "-", 'Change %': np.mean(df["Change %"].values)}, ignore_index=True)
    df6.to_csv("Update-Vs-Delete-Create-Db-Time-Taken.csv", index=False)


    flatui = [ "#3498db","#34495e", "#2ecc71"]
    sns.set_palette(flatui)
    g = sns.barplot(data=[fs_amf_time, fps_amf_time, fts_amf_time], palette=flatui)

    plt.ylabel('Time (s)')
    plt.xlabel("Simultaneous Requests")
    #g.legend_.set_title(None)
    plt.tight_layout()
    #g.set_ylim(4,16)
    plt.savefig('plot1.pdf', bbox_inches='tight', pad_inches=0.1)
    plt.show()
    plt.close()


if __name__ == "__main__":
    main()

