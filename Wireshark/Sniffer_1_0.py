#!/usr/bin/env python3
import time
import pyshark
import xlsxwriter
import copy
row = 1
col = 0
i = 0
var = 5

t_start = time.strftime("%H:%M:%S",time.gmtime())

cap = pyshark.LiveCapture(interface='mon0',
        output_file="/home/simone/Documents/Wireless_Networking/Sniffing/test_file2.pcap")
cap.sniff(timeout=30*60) #Specify the amount of time you want to capture
#Capture from file if needed
#cap = pyshark.FileCapture('test_file.pcap', only_summaries=False)
count = len(cap)
print(cap)

t_end = time.strftime("%H:%M:%S",time.gmtime());

workbook = xlsxwriter.Workbook('hello3_extended.xlsx')
worksheet = workbook.add_worksheet()

worksheet.write('A1', "Frame Type")
worksheet.write('B1', "Frame SubType")
worksheet.write('C1', "Wifi Frame type")
worksheet.write('D1', "Wifi Frame subtype")
worksheet.write('E1', "Duration wlan_radio")
worksheet.write('F1', "Length")

types = ["Management Frame","Control Frame","Data Frame"]
subtypes1 = ["Association Request","Association Response","Reassociation Request",
            "Reassociation Response","Probe Request","Probe Response",0,0,"Beacon",
            "ATIM","Diassociation","Authentication","Deauthentication","Action",
            "Action No Ack"]
subtypes2 = [0,0,0,0,0,0,0,"Control wrapper","BlockAck req","BlockAck","Power Save Poll"
            "RTS","CTS","ACK","CFE","CFE + CFE ACK"]
subtypes3 = ["Data","Data + CF ACK [PCF Only]","Data + CF Poll [PCF Only]",
            "Data + CF ACK + CF Poll [PCF Only]","Null","CF Ack [PCF Only]",
            "CF Poll [PCF Only]","Data + CF ACK + CF Poll","QoS Data [HCF]",
            "QoS Data + CF Ack[HCF]","QoS Data + CF Poll[HCF]",
            "QoS Data + CF Ack + CF Poll[HCF]","QoS Null[HCF]",0,
            "QoS CF-Poll(no data)[HCF]","QoS CF-Ack + CF-Poll(no data)[HCF]"]

subtypes = []
subtypes.append(subtypes1)
subtypes.append(subtypes2)
subtypes.append(subtypes3)

typ_n = [0,0,0]
styp1_n = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
styp2_n = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
styp3_n = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

styp_n = []
styp_n.append(styp1_n)
styp_n.append(styp2_n)
styp_n.append(styp3_n)

typ_airt = list(typ_n)
styp_airt = list(styp_n)


for i in range(0,count):
    #Write the type and subtype of the packet i
    worksheet.write(row,col, cap[i].wlan.fc_type)
    worksheet.write(row,col+1, cap[i].wlan.fc_subtype)

    #Store the type and subtype of the packet i
    typ = int(cap[i].wlan.fc_type)
    styp = int(cap[i].wlan.fc_subtype)

    #Write names ot type and subtype
    worksheet.write(row,col+2,types[typ])
    worksheet.write(row,col+3,subtypes[typ][styp])

    #increment counter of packets of a certain type (subtype)
    typ_n[typ] = typ_n[typ] + 1
    styp_n[typ][styp] = styp_n[typ][styp] +1

    #Write the DurationID and length of packet i
    worksheet.write(row,col+4,cap[i].wlan_radio.duration)
    worksheet.write(row,col+5,cap[i].length)

    t =  int(cap[i].wlan_radio.duration)

    typ_airt[typ] = typ_airt[typ] + t
    styp_airt[typ][styp] = styp_airt[typ][styp] + t

    row = row + 1
    i = i + 1

col = col+7
row = 1

worksheet.write(0,col,"Type/Subtype")
worksheet.write(0,col+1,"n Frames")
worksheet.write(0,col+2,"Airtime")


#Writing total numbers of packets received by type (subtype)
for p in range(0,len(types)):
    worksheet.write(row,col,types[p])
    worksheet.write(row,col+1,typ_n[p])
    worksheet.write(row,col+2,typ_airt[p])
    row = row + 2
    for m in range(0,len(subtypes1)):
        if subtypes[p][m] != 0 and styp_n[p][m] != 0:
            worksheet.write(row,col,subtypes[p][m])
            worksheet.write(row,col+1,styp_n[p][m])
            worksheet.write(row,col+2,styp_airt[p][m])
            row = row +1
    row = row +1

#Write time of acquisition

worksheet.write(0,col+4,"Times of greenwich")
worksheet.write(1,col+4,"t start")
worksheet.write(1,col+5,t_start)
worksheet.write(2,col+4,"t end")
worksheet.write(2,col+5,t_end)


workbook.close()
