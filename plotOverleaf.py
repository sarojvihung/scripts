#!/usr/bin/env python3

import os
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib import gridspec
from matplotlib.ticker import PercentFormatter
import seaborn as sns

matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
sns.set_context(context="paper", font_scale=1.6)

dir_path = os.path.dirname(os.path.realpath(__file__))
#print("dir_path", dir_path)
my_file_name = os.path.basename(__file__)
path = Path("{}/{}".format(dir_path, my_file_name)).parent.parent
file_format = "pdf"

CREATE_COMPARISON_CSVS = 0
MIN_MAX_COMPARISON = 0
FIGURE3 = 1
CPU_NF_PLOT = 1
CPU_VPN_PLOT = 1
FIGURE4 = 0
FIGURE4_1 = 0
FIGURE4_2 = 0
FIGURE5 = 0
FIGURE6 = 0
FIGURE7 = 0
FIGURE8 = 0

dict_map = {
    "noistio": {
        "amfTimeTaken": [],
        "smfTimeTaken": [],
        "upfTimeTaken": [],
        "plotname": "Unsecured",
        "valied_800_runs": [2, 5, 7, 8],
        "amfQueueLength": [],
        "smfQueueLength": [],
        "upfQueueLength": [],
        "amfMinTime": [],
        "amfMaxTime": []
    },
    "secure": {
        "amfTimeTaken": [],
        "smfTimeTaken": [],
        "upfTimeTaken": [],
        "plotname": "Core Secure",
        "valied_800_runs": [1, 4, 5, 9],
        "amfQueueLength": [],
        "smfQueueLength": [],
        "upfQueueLength": [],
        "amfMinTime": [],
        "amfMaxTime": []
    },
    "unsecure": {
        "amfTimeTaken": [],
        "smfTimeTaken": [],
        "upfTimeTaken": [],
        "plotname": "Unsecured",
        "valied_800_runs": [2, 4, 5],
        "amfQueueLength": [],
        "smfQueueLength": [],
        "upfQueueLength": [],
        "amfMinTime": [],
        "amfMaxTime": []
    },
    "ranudpvpn": {
        "amfTimeTaken": [],
        "smfTimeTaken": [],
        "upfTimeTaken": [],
        "plotname": "RAN Secure",
        "valied_800_runs": [1, 2, 5],
        "amfQueueLength": [],
        "smfQueueLength": [],
        "upfQueueLength": [],
        "amfMinTime": [],
        "amfMaxTime": []
    },
    "allsecure": {
        "amfTimeTaken": [],
        "smfTimeTaken": [],
        "upfTimeTaken": [],
        "plotname": "RAN + Core Secure",
        "valied_800_runs": [1, 8],
        "amfQueueLength": [],
        "smfQueueLength": [],
        "upfQueueLength": [],
        "amfMinTime": [],
        "amfMaxTime": []
    },
    "secore": {
        "amfTimeTaken": [],
        "smfTimeTaken": [],
        "upfTimeTaken": [],
        "plotname": "Core Secure",
        "valied_800_runs": [2, 3],
        "amfQueueLength": [],
        "smfQueueLength": [],
        "upfQueueLength": [],
        "amfMinTime": [],
        "amfMaxTime": []
    }
}

dict_map_keys = list(dict_map.keys()).copy()
session_list = [i*100 for i in range(1, 10)]

# https://stackoverflow.com/a/22845857/12865444


def plot_clustered_stacked(dfall, labels=None, title="multiple stacked bar plot",  H="/", **kwargs):
    """Given a list of dataframes, with identical columns and index, create a clustered stacked bar plot. 
labels is a list of the names of the dataframe, used for the legend
title is a string for the title of the plot
H is the hatch used for identification of the different dataframe"""

    n_df = len(dfall)
    n_col = len(dfall[0].columns)
    n_ind = len(dfall[0].index)
    axe = plt.subplot(111)

    for df in dfall:  # for each data frame
        axe = df.plot(kind="bar",
                      linewidth=0,
                      stacked=True,
                      ax=axe,
                      legend=False,
                      grid=False,
                      **kwargs)  # make bar plots

    h, l = axe.get_legend_handles_labels()  # get the handles we want to modify
    for i in range(0, n_df * n_col, n_col):  # len(h) = n_col * n_df
        for j, pa in enumerate(h[i:i+n_col]):
            for barnum, rect in enumerate(pa.patches):  # for each index
                # https://matplotlib.org/stable/api/_as_gen/matplotlib.patches.Patch.html#matplotlib.patches.Patch.set
                # https://matplotlib.org/stable/gallery/shapes_and_collections/hatch_demo.html
                rect.set_x(rect.get_x() + 1.1 /
                           float(n_df + 1.1) * i / float(n_col))
                rect.set_hatch(H * 2 * int(i / n_col))  # edited part
                rect.set_width(1 / float(n_df + 1))
                rect.set_color("#3498db")
                if j == 1:
                    rect.set_color("#ffa500")
                rect.set_edgecolor("black")
                rect.set_linewidth(0.5)
                rect.set_alpha(0.5)
                rect.set_zorder(1)
                #print("barnum, i, j", barnum, i, j)

    axe.set_xticks((np.arange(0, 2 * n_ind, 2) + 1 / float(n_df + 2)) / 2.)
    axe.set_xticklabels(df.index, rotation=0)
    # axe.set_title(title)

    # Add invisible data to add another legend
    n = []
    for i in range(n_df):
        n.append(axe.bar(0, 0, color="xkcd:aqua",
                 hatch=H * 2 * i, edgecolor="black"))

    # l1 = axe.legend(h[:n_col], l[:n_col], loc=[1.01, 0.5])
    l1 = axe.legend(h[:n_col], l[:n_col], loc="upper left")
    if labels is not None:
        # l2 = plt.legend(n, labels, loc=[1.01, 0.1])
        l2 = plt.legend(n, labels, loc="best")
    axe.add_artist(l1)
    axe.set_ylim(0, 85)
    axe.set_ylabel('CPU (%)')
    plt.tight_layout()
    plt.savefig('nf_cpu.{}'.format(file_format),
                bbox_inches='tight', pad_inches=0)
    plt.show()
    plt.close()

    return axe


def calc_min_max(i, j, param="amfTime"):
    if param == "amfTime":
        p1 = "amfMaxTime"
        p2 = "amfMinTime"
    elif param == "dbTime":
        p1 = "dbMaxTime"
        p2 = "dbMinTime"
    a = dict_map[dict_map_keys[j]][p1]
    b = dict_map[dict_map_keys[i]][p2]
    max_diff = np.mean([(a_i - b_i)*(100/b_i) for a_i, b_i in zip(a, b)])
    print("Max time difference between {} and {} is {}".format(
        dict_map_keys[j], dict_map_keys[i], max_diff))

def main():
    df_all = pd.DataFrame()
    df_all["amfTimeTaken"] = [-1]
    df_all["amfQueueLength"] = [-1]
    df_all["smfTimeTaken"] = [-1]
    df_all["smfQueueLength"] = [-1]
    df_all["upfTimeTaken"] = [-1]
    df_all["upfQueueLength"] = [-1]
    df_all["Config"] = [-1]
    df_all["Sessions"] = [-1]
    df_all["Rate"] = [-1]
    for folder_name in dict_map_keys:
        # print("Working on ", folder_name)
        csv_file = "{}-data.csv".format(folder_name)
        df = pd.read_csv(csv_file)
        prev_mean_index = 0
        if folder_name == 'udpvpn' or folder_name == 'unsecure':
            session_list = [i*100 for i in range(1, 10) if i != 6]
        else:
            session_list = [i*100 for i in range(1, 10)]
        for row_section in session_list:
            # print("Working on ", row_section)
            this_mean_index = df.index[df["numSessions"]
                                       == "Mean-{}".format(row_section)].values[0]
            df_new = pd.DataFrame()
            for col in list(df.columns.values)[1:]:
                col_values = list(
                    df[prev_mean_index:this_mean_index][col].values).copy()
                col_mean = np.mean(col_values)
                df[col].values[this_mean_index] = col_mean
                for nf in ["amf", "smf", "upf"]:
                    key1 = nf + "TimeTaken"
                    key2 = nf + "QueueLength"
                    if col == key1:
                        dict_map[folder_name][key1].append(col_mean)
                        df_new[key1] = col_values
                    elif col == key2:
                        dict_map[folder_name][key2].append(col_mean)
                        if nf == "amf":
                            dict_map[folder_name]["amfMinTime"].append(min(col_values))
                            dict_map[folder_name]["amfMaxTime"].append(max(col_values))
                        df_new[key2] = col_values
            df_new["Config"] = folder_name
            df_new["Sessions"] = row_section
            df_new["Rate"] = row_section
            df_new_row = pd.DataFrame(df_new)
            df_all = pd.concat([df_all, df_new_row])
            prev_mean_index = this_mean_index+1
        df.to_csv(csv_file, index=False)
    df_all.to_csv("op.csv", index=False)

    if FIGURE6:
        valid_cpuq_folders = []
        cpu_q_values = []
        for folder_name in dict_map_keys:
            valied_800_runs = dict_map[folder_name]["valied_800_runs"]
            mean_cpus = []
            if valied_800_runs:
                for sub_folder in valied_800_runs:
                    cpu_file_name = "{}/Results2/{}-{}/800/topCpuOp.csv".format(
                        path, folder_name, sub_folder)
                    df_cpu_sub = pd.read_csv(cpu_file_name)
                    mean_cpus.append(
                        df_cpu_sub[df_cpu_sub[" CPU-Usage"] > 0][" CPU-Usage"].mean())
                cpu_q_values.append(dict_map[folder_name]["amfQueueLength"])
                cpu_q_values.append(np.mean(mean_cpus))
                valid_cpuq_folders.append(folder_name)
                valid_cpuq_folders.append(folder_name)
        df_queue_cpu = pd.DataFrame()
        df_queue_cpu["Rate"] = [1000]*8
        df_queue_cpu["Type"] = ["Q Length", "CPU"]*4
        df_queue_cpu["Config"] = valid_cpuq_folders
        df_queue_cpu["Value"] = cpu_q_values

    if CPU_NF_PLOT:
        nfs = ["amfd", "smfd", "ausfd", "pcfd", "udmd", "udrd"]
        noistio_nf_cpus = []
        noistio_envoy_cpus = [0]*6
        secure_nf_cpus = []
        secure_envoy_cpus = []
        for folder_name in ["noistio", "secure"]:
            valied_800_runs = dict_map[folder_name]["valied_800_runs"]
            mean_cpus = []
            mean_cpus_envoy = []
            for nf in nfs:
                for sub_folder in valied_800_runs:
                    if folder_name == "noistio":
                        cpu_file_name = "{}/{}/{}-{}/topCpuOp{}.csv".format(
                            dir_path, folder_name, folder_name, sub_folder, nf)
                    elif folder_name == "secure":
                        cpu_file_name = "{}/{}/{}-{}/topCpuOpEnvoy{}.csv".format(
                            dir_path, folder_name, folder_name, sub_folder, nf)
                    else:
                        cpu_file_name = "{}/{}/topCpuOp{}{}.csv".format(
                            dir_path, folder_name, nf, sub_folder)
                    df_cpu_sub = pd.read_csv(cpu_file_name)
                    mean_cpus.append(
                        df_cpu_sub[df_cpu_sub[" {}-CPU-Usage".format(nf)] > 0][" {}-CPU-Usage".format(nf)].mean())
                    if folder_name == "secure":
                        mean_cpus_envoy.append(
                            df_cpu_sub[df_cpu_sub[" envoy-CPU-Usage"] > 0][" envoy-CPU-Usage"].mean())
                if folder_name == "noistio":
                    noistio_nf_cpus.append(np.mean(mean_cpus))
                elif folder_name == "secure":
                    secure_nf_cpus.append(np.mean(mean_cpus))
                    secure_envoy_cpus.append(np.mean(mean_cpus_envoy))
        print("Unsecure CPUs - ", noistio_nf_cpus)
        print("Secure NF CPUs - ", secure_nf_cpus)
        print("Security Microservice CPUs - ", secure_envoy_cpus)
        envoy_plus_securenf = np.array(secure_nf_cpus) + np.array(secure_envoy_cpus)
        high_percentage = (envoy_plus_securenf - np.array(secure_nf_cpus))/np.array(secure_nf_cpus)
        print("Envoy overhead",np.mean(high_percentage)*100)
        lst = []
        for i, val in enumerate(noistio_nf_cpus):
            a = [val, noistio_envoy_cpus[i]]
            lst.append(a)
        noistio_vals = np.array(lst)
        lst = []
        for i, val in enumerate(secure_nf_cpus):
            a = [val, secure_envoy_cpus[i]]
            lst.append(a)
        secure_vals = np.array(lst)

        x_axis = ["AMF", "SMF", "AUSF", "PCF", "UDM", "UDR"]
        # create fake dataframes
        df_noistio = pd.DataFrame(noistio_vals,
                                  index=x_axis,
                                  columns=["NF Application", "Security Microservice"])
        df_secure = pd.DataFrame(secure_vals,
                                 index=x_axis,
                                 columns=["NF Application", "Security Microservice"])

        # Then, just call :
        plot_clustered_stacked([df_noistio, df_secure], ["Unsecured", "Secure"])

    if CPU_VPN_PLOT:
        nfs = ["gnb", "amfd"]
        noistio_amfd_cpus = []
        noistio_gnb_cpus = []
        ranudp_amfd_cpus = []
        ranudp_amfdvpn_cpus = []
        ranudp_gnb_cpus = []
        ranudp_gnbvpn_cpus = []
        allsecure_amfd_cpus = []
        allsecure_envoy_cpus = []
        allsecure_gnb_cpus = []
        allsecure_amfdvpn_cpus = []
        allsecure_gnbvpn_cpus = []

        for folder_name in ["unsecure", "ranudpvpn", "allsecure"]:
            valied_800_runs = dict_map[folder_name]["valied_800_runs"]
            mean_cpus = []
            mean_cpus_envoy = []
            mean_cpus_vpn = []
            mean_gnb1_cpus_vpn = []
            mean_gnb2_cpus_vpn = []
            gnb1_mean_cpus = []
            gnb2_mean_cpus = []
            mean_cpus_gnb_vpn = []
            nf = "amfd"
            for sub_folder in valied_800_runs:
                if folder_name != "ranudpvpn":
                    cpu_file_name = "{}/{}/topCpuOp{}{}.csv".format(
                                    dir_path, folder_name, nf, sub_folder)
                    df_cpu_sub = pd.read_csv(cpu_file_name)
                    mean_cpus.append(
                        df_cpu_sub[df_cpu_sub[" {}-CPU-Usage".format(nf)] > 0][" {}-CPU-Usage".format(nf)].mean())
                if folder_name == "allsecure":
                    mean_cpus_envoy.append(
                        df_cpu_sub[df_cpu_sub[" envoy-CPU-Usage"] > 0][" envoy-CPU-Usage"].mean())
                if folder_name == "allsecure" or folder_name == "ranudpvpn":
                    cpu_file_name = "{}/{}/topCpuOpVpn{}{}.csv".format(
                        dir_path, folder_name, nf, sub_folder)
                    df_cpu_sub = pd.read_csv(cpu_file_name)
                    if folder_name == "ranudpvpn":
                        mean_cpus.append(
                            df_cpu_sub[df_cpu_sub[" {}-CPU-Usage".format(nf)] > 0][" {}-CPU-Usage".format(nf)].mean())
                    mean_cpus_vpn.append(
                        df_cpu_sub[df_cpu_sub[" vpn-CPU-Usage"] > 0][" vpn-CPU-Usage"].mean())

                for gnb_num in [12, 14]:
                    cpu_file_name = "{}/{}/topCpuOpVpngnb{}_{}.csv".format(
                        dir_path, folder_name, sub_folder, gnb_num)
                    df_cpu_sub = pd.read_csv(cpu_file_name)
                    if gnb_num == 12:
                        gnb1_mean_cpus.append(
                            df_cpu_sub[df_cpu_sub[" gnb-CPU-Usage"] > 0][" gnb-CPU-Usage"].mean())
                        if folder_name == "allsecure" or folder_name == "ranudpvpn":
                            mean_gnb1_cpus_vpn.append(
                                df_cpu_sub[df_cpu_sub[" vpn-CPU-Usage"] > 0][" vpn-CPU-Usage"].mean())
                    else:
                        gnb2_mean_cpus.append(
                            df_cpu_sub[df_cpu_sub[" gnb-CPU-Usage"] > 0][" gnb-CPU-Usage"].mean())
                        if folder_name == "allsecure" or folder_name == "ranudpvpn":
                            mean_gnb2_cpus_vpn.append(
                                df_cpu_sub[df_cpu_sub[" vpn-CPU-Usage"] > 0][" vpn-CPU-Usage"].mean())
            mean_cpus_gnb = [(g + h) / 2 for g,
                             h in zip(gnb1_mean_cpus, gnb2_mean_cpus)]
            if folder_name == "allsecure" or folder_name == "ranudpvpn":
                mean_cpus_gnb_vpn = [
                    (g + h) / 2 for g, h in zip(mean_gnb1_cpus_vpn, mean_gnb2_cpus_vpn)]

            if 0:
                print(" ---- Folder = {} ---- ".format(folder_name))
                print("gnb1_mean_cpus - ", gnb1_mean_cpus)
                print("gnb2_mean_cpus - ", gnb2_mean_cpus)
                print("mean_gnb1_cpus_vpn - ", mean_gnb1_cpus_vpn)
                print("mean_gnb2_cpus_vpn - ", mean_gnb2_cpus_vpn)
                print("mean_cpus_gnb - ", mean_cpus_gnb)
                print("mean_cpus_gnb_vpn - ", mean_cpus_gnb_vpn)

            if folder_name == "unsecure":
                noistio_amfd_cpus.append(np.mean(mean_cpus))
                noistio_gnb_cpus.append(np.mean(mean_cpus_gnb))
            elif folder_name == "ranudpvpn":
                ranudp_amfd_cpus.append(np.mean(mean_cpus))
                ranudp_amfdvpn_cpus.append(np.mean(mean_cpus_vpn))
                ranudp_gnb_cpus.append(np.mean(mean_cpus_gnb))
                ranudp_gnbvpn_cpus.append(np.mean(mean_cpus_gnb_vpn))
            elif folder_name == "allsecure":
                allsecure_amfd_cpus.append(np.mean(mean_cpus))
                allsecure_envoy_cpus.append(np.mean(mean_cpus_envoy))
                allsecure_amfdvpn_cpus.append(np.mean(mean_cpus_vpn))
                allsecure_gnb_cpus.append(np.mean(mean_cpus_gnb))
                allsecure_gnbvpn_cpus.append(np.mean(mean_cpus_gnb_vpn))

        if 0:
            print("---------- Final Result -----------")
            print("noistio_amfd_cpus = ", noistio_amfd_cpus)
            print("noistio_gnb_cpus = ", noistio_gnb_cpus)
            print("ranudp_amfd_cpus = ", ranudp_amfd_cpus)
            print("ranudp_amfdvpn_cpus = ", ranudp_amfdvpn_cpus)
            print("ranudp_gnb_cpus = ", ranudp_gnb_cpus)
            print("ranudp_gnbvpn_cpus = ", ranudp_gnbvpn_cpus)
            print("allsecure_amfd_cpus = ", allsecure_amfd_cpus)
            print("allsecure_envoy_cpus = ", allsecure_envoy_cpus)
            print("allsecure_gnb_cpus = ", allsecure_gnb_cpus)
            print("allsecure_amfdvpn_cpus = ", allsecure_amfdvpn_cpus)
            print("allsecure_gnbvpn_cpus = ", allsecure_gnbvpn_cpus)

        print("Total AMF CPU for unsecure = ", noistio_amfd_cpus[0])
        print("Total gNB CPU for unsecure = ", noistio_gnb_cpus[0])
        print("Total AMF CPU for ranudpvpn = ",
              ranudp_amfd_cpus[0]+ranudp_amfdvpn_cpus[0])
        print("Total gNB CPU for ranudpvpn = ",
              ranudp_gnb_cpus[0]+ranudp_gnbvpn_cpus[0])
        print("Total AMF CPU for allsecure = ",
              allsecure_amfd_cpus[0]+allsecure_envoy_cpus[0]+allsecure_amfdvpn_cpus[0])
        print("Total gNB CPU for allsecure = ",
              allsecure_gnb_cpus[0]+allsecure_gnbvpn_cpus[0])

    if MIN_MAX_COMPARISON:
        calc_min_max(0, 1)
        calc_min_max(0, 2)
        calc_min_max(3, 2)
        calc_min_max(4, 2)
        calc_min_max(5, 2)
        calc_min_max(6, 2)

    df_plot = df_all[(df_all['Rate'] == 200) | (df_all['Rate'] == 400) | (
        df_all['Rate'] == 600) | (df_all['Rate'] == 800)].copy()

    if FIGURE3:
        for nf in ["amf", "smf", "upf"]:
            for param in ["TimeTaken", "QueueLength"]:
                y = nf + param
                config_filter = ['noistio', 'ranudpvpn', 'secure', 'allsecure']
                order_list = [dict_map[x]["plotname"] for x in config_filter]
                flatui = ["#3498db", "#95a5a6", "#34495e", "#2ecc71"]
                sns.set_palette(flatui)
                sb = sns.barplot(data=df_plot, x='Rate', y=y,
                                hue='Config', palette=flatui, hue_order=config_filter)
                h, l = sb.get_legend_handles_labels()
                sb.legend(h, order_list, title=None)
                #sb.set_ylim(2, 27)
                plt.ylabel('Time (s)')
                plt.xlabel("Simultaneous Requests")
                sb.legend_.set_title(None)
                noistio_vals = []
                ranudpvpn_vals = []
                secure_vals = []
                allsecure_vals = []
                for num_slice, slice in enumerate(sb.containers):
                    for num_session in [0,1,2,3]:
                        yval = slice[num_session]._height
                        if num_slice == 0:
                            noistio_vals.append(yval)
                        elif num_slice == 1:
                            ranudpvpn_vals.append(yval)
                        elif num_slice == 2:
                            secure_vals.append(yval)
                        elif num_slice == 3:
                            allsecure_vals.append(yval)
                #print(noistio_vals, ranudpvpn_vals, secure_vals, allsecure_vals)
                ran_overhead = np.array(ranudpvpn_vals) - np.array(noistio_vals)
                core_overhead = np.array(secure_vals) - np.array(noistio_vals)
                core_ran = core_overhead/ran_overhead
                print("Core overhead w.r.t. RAN overhead = ",np.mean(core_ran))
                plt.tight_layout()
                # plt.legend(loc="best")
                plt.savefig(y+"."+file_format, bbox_inches='tight')
                plt.show()
                plt.close()
    
    if FIGURE4:
        config_filter = [dict_map_keys[5], dict_map_keys[6],
                         dict_map_keys[3], dict_map_keys[2]]
        order_list = [dict_map[x]["plotname"] for x in config_filter]
        flatui = ["#3498db", "#95a5a6", "#34495e", "#2ecc71"]
        sns.set_palette(flatui)
        sb = sns.barplot(data=df_plot, x='Rate', y='amfTimeTaken',
                         hue='Config', palette=flatui, hue_order=config_filter)
        h, l = sb.get_legend_handles_labels()
        sb.legend(h, order_list, title=None)
        sb.set_ylim(8, 16)
        plt.ylabel('Time (s)')
        plt.xlabel("Simultaneous Requests")
        sb.legend_.set_title(None)
        plt.tight_layout()
        #plt.legend(loc="best")
        plt.savefig('figure4.{}'.format(file_format), bbox_inches='tight')
        plt.show()
        plt.close()

    if FIGURE4_1:
        config_filter = [dict_map_keys[5], dict_map_keys[6], dict_map_keys[2]]
        order_list = [dict_map[x]["plotname"] for x in config_filter]
        flatui = ["#3498db", "#95a5a6", "#2ecc71"]
        sns.set_palette(flatui)
        sb = sns.barplot(data=df_plot, x='Rate', y='amfTimeTaken',
                         hue='Config', palette=flatui, hue_order=config_filter)
        h, l = sb.get_legend_handles_labels()
        sb.legend(h, order_list, title=None)
        sb.set_ylim(8, 16)
        plt.ylabel('Time (s)')
        plt.xlabel("Simultaneous Requests")
        sb.legend_.set_title(None)
        plt.tight_layout()
        #plt.legend(loc="best")
        plt.savefig('figure4_1.{}'.format(file_format), bbox_inches='tight')
        plt.show()
        plt.close()

    if FIGURE4_2:
        config_filter = [dict_map_keys[3], dict_map_keys[2]]
        order_list = [dict_map[x]["plotname"] for x in config_filter]
        flatui = ["#34495e", "#2ecc71"]
        sns.set_palette(flatui)
        sb = sns.barplot(data=df_plot, x='Rate', y='amfTimeTaken',
                         hue='Config', palette=flatui, hue_order=config_filter)
        sb.set_ylim(8, 16)
        l1 = mpatches.Patch(color=flatui[0], label='Non-Blocking')
        l2 = mpatches.Patch(color=flatui[1], label='Blocking')
        plt.ylabel('Time (s)')
        plt.xlabel("Simultaneous Requests")
        sb.legend_.set_title(None)
        plt.tight_layout()
        plt.legend(loc="best", handles=[l1, l2])
        plt.savefig('figure4_2.{}'.format(file_format), bbox_inches='tight')
        plt.show()
        plt.close()

    if FIGURE5:
        config_filter = [dict_map_keys[4], dict_map_keys[2]]
        order_list = [dict_map[x]["plotname"] for x in config_filter]
        flatui = ["#3498db", "#2ecc71"]
        sns.set_palette(flatui)
        sb = sns.barplot(data=df_plot, x='Rate', y='amfDbTotalTime',
                         hue='Config', palette=flatui, hue_order=config_filter)
        sb.set_ylim(550, 1010)
        l1 = mpatches.Patch(color=flatui[0], label='Delete-Create API')
        l2 = mpatches.Patch(color=flatui[1], label='Update API')
        plt.ylabel('Time (ms)')
        plt.xlabel("Simultaneous Requests")
        sb.legend_.set_title(None)
        plt.tight_layout()
        plt.legend(loc="best", handles=[l1, l2])
        plt.savefig('figure5.{}'.format(file_format),
                    bbox_inches='tight', pad_inches=0)
        plt.show()
        plt.close()

    if FIGURE8:
        config_filter = [dict_map_keys[4], dict_map_keys[2]]
        order_list = [dict_map[x]["plotname"] for x in config_filter]
        order_list[1] = "Update API"
        config_list = [config_filter[0]]*5
        config_list.extend([config_filter[1]]*5)
        df_mongo = pd.DataFrame()
        df_mongo["Config"] = config_list
        amfRdTime = dict_map[config_filter[0]]["amfDbReadTime"][5:].copy()
        amfRdTime.extend(dict_map[config_filter[1]]
                         ["amfDbReadTime"][5:].copy())
        amfWrTime = dict_map[config_filter[0]]["amfDbWriteTime"][5:].copy()
        amfWrTime.extend(dict_map[config_filter[1]]
                         ["amfDbWriteTime"][5:].copy())
        df_mongo["amfDbReadTime"] = amfRdTime
        df_mongo["amfDbWriteTime"] = amfWrTime
        df_mongo["Rate"] = session_list[5:]*2
        # ax = df_mongo.plot(x="Rate", y="amfDbWriteTime", kind="bar")
        # df_mongo.plot(x="Rate", y="amfDbReadTime", kind="bar", ax=ax, color="C2")
        # df_mongo[["Rate", "amfDbWriteTime", "amfDbReadTime"]].plot(x="Rate", kind="bar")
        df_mongo.set_index('Rate').plot(kind='bar', stacked=True, y=[
            "amfDbReadTime", "amfDbWriteTime"], color=['steelblue', 'red'])
        plt.show()

    if FIGURE6:

        def get_plt_name(x):
            if x == 'AMF-SMF Share Database':
                return 'AMF-SMF\nShare DB'

            if x == 'Transactional Stateless':
                return 'Transactional\nStateless'

            return x

        df_queue_cpu['Config'] = df_queue_cpu['Config'].apply(get_plt_name)
        df_queue_cpu['Type'] = df_queue_cpu['Type'].apply(
            lambda x: x.replace('QLEN', 'Q Length'))

        fig, ax1 = plt.subplots()
        flatui = ["#34495e", "#2ecc71"]
        sb = sns.barplot(data=df_queue_cpu, x='Config', y='Value', hue='Type', palette=sns.color_palette(flatui),
                         ax=ax1, hue_order=['CPU', 'Q Length'],
                         order=['Stateful', 'Transactional\nStateless', 'AMF-SMF\nShare DB', 'Non-Blocking'])
        ax1.set_ylabel('CPU', fontsize=14)
        ax2 = ax1.twinx()
        ax2.set_ylim(ax1.get_ylim())
        ax1.yaxis.set_major_formatter(
            PercentFormatter(100))  # percentage using 1 for 100%
        ax1.tick_params(labelsize=13)
        ax2.tick_params(labelsize=13)
        ax2.set_ylabel('Queue Length', fontsize=14)
        ax1.set_xlabel('')
        sb.legend_.set_title(None)
        plt.tight_layout()
        plt.legend(loc="best", fontsize=1)
        plt.savefig('figure6.{}'.format(file_format),
                    bbox_inches='tight', pad_inches=0)
        plt.show()
        plt.close()


def plot_amf_gnb_cpu():
    cpu_usage = [[28.72, 'untrusted', 'gNB'], [33.14, 'untrusted', 'AMF'],
            [41.29, 'ranudpvpn', 'gNB'], [47.85, 'ranudpvpn', 'AMF'],
            [40.26, 'allsecure', 'gNB'], [68.30, 'allsecure', 'AMF']]
    d = pd.DataFrame(cpu_usage, columns=['cpu', 'config', 'nf'])
    config_filter = ['untrusted', 'ranudpvpn', 'allsecure']
    flatui = ["#3498db", "#2ecc71", "#34495e"]
    sns.set_palette(flatui)
    sb = sns.barplot(data=d,
                     x='nf',
                     y='cpu',
                     hue='config',
                     palette=flatui,
                     hue_order=config_filter)
    #sb.set_ylim(0, 70)
    #sb.set_ylim(3, 4.75, 0.1)
    plt.xlabel('NFs')
    plt.ylabel("CPU (%)")
    sb.legend_.set_title(None)
    l1 = mpatches.Patch(color=flatui[0], label='Unsecured')
    l2 = mpatches.Patch(color=flatui[1], label='RAN Secure')
    l3 = mpatches.Patch(color=flatui[2], label='RAN + Core Secure')
    plt.tight_layout()
    plt.legend(loc="best", handles=[l1, l2, l3])
    plt.savefig('udp_cpu.{}'.format(file_format), bbox_inches='tight')
    plt.show()
    plt.close()


if __name__ == "__main__":
    main()
    #plot_amf_gnb_cpu()
