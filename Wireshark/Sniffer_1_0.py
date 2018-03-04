#!/usr/bin/env python3
from scapy.all import *
import time
import pyshark
import xlsxwriter
row = 1;
col = 0;
i = 0;
var = 5;

cap = pyshark.LiveCapture(interface='mon0',
        output_file="/home/simone/Documents/Wireless_Networking/Sniffing/test_file.pcap")
cap.sniff(timeout=15) #Specify the amount of time you want to capture
count = len(cap);
print(cap);

workbook = xlsxwriter.Workbook('hello3.xlsx')
worksheet = workbook.add_worksheet()

worksheet.write('A1', "Frame Type")
worksheet.write('B1', "Frame SubType")
worksheet.write('C1', "Wifi Frame type")
worksheet.write('D1', "Wifi Frame subtype")
worksheet.write('E1', "DurationID")
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
    worksheet.write(row,col+4,cap[i].wlan.duration)
    worksheet.write(row,col+5,cap[i].length)

    row = row + 1
    i = i + 1

col = col+7
row = 1

#Writin total numbers of packets received by type (subtype)
for p in range(0,len(types)):
    worksheet.write(row,col,types[p])
    worksheet.write(row,col+1,typ_n[p])
    row = row + 2
    for m in range(0,len(subtypes1)):
        if subtypes[p][m] != 0 and styp_n[p][m] != 0:
            worksheet.write(row,col,subtypes[p][m])
            worksheet.write(row,col+1,styp_n[p][m])
            row = row +1
    row = row +1


print(cap[1].layers[1].field_names)

#print(cap[1].wlan.field_names) #returns all the names of the fields in that layer
#print(cap[1].wlan.duration)
#print(cap[1].length)

workbook.close()
