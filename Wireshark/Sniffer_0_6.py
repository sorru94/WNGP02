import time
import pyshark
import xlsxwriter
row = 1;
col = 0;
i = 0;
var = 5;

cap = pyshark.LiveCapture(interface='mon0',output_file="/home/hiram/Documents/Wireless/test_file.pcap")
cap.sniff(timeout=10) #Specify the amount of time you want to capture
count = len(cap);
print(cap);

workbook = xlsxwriter.Workbook('hello3.xlsx')
worksheet = workbook.add_worksheet()

worksheet.write('A1', "Frame Type")
worksheet.write('B1', "Frame SubType")
worksheet.write('C1', "Wifi Frame type")
worksheet.write('D1', "Wifi Frame subtype")


for i in range(0,count):
    worksheet.write(row,col, cap[i].wlan.fc_type)
    worksheet.write(row,col+1, cap[i].wlan.fc_subtype)

    if cap[i].wlan.fc_type == '0':
        worksheet.write(row,col+2,"Management Frame")
        if cap[i].wlan.fc_subtype == '0':
            worksheet.write(row,col+3,"Association Request")
        if cap[i].wlan.fc_subtype == '1':
            worksheet.write(row,col+3,"Association Response")
        if cap[i].wlan.fc_subtype == '2':
            worksheet.write(row,col+3,"Reassociation Request")
        if cap[i].wlan.fc_subtype == '3':
            worksheet.write(row,col+3,"Reassociation Response")
        if cap[i].wlan.fc_subtype == '4':
            worksheet.write(row,col+3,"Probe Request")
        if cap[i].wlan.fc_subtype == '5':
            worksheet.write(row,col+3,"Probe Response")
        if cap[i].wlan.fc_subtype == '8':
            worksheet.write(row,col+3,"Beacon")
        if cap[i].wlan.fc_subtype == '9':
            worksheet.write(row,col+3,"ATIM")
        if cap[i].wlan.fc_subtype == '10':
            worksheet.write(row,col+3,"Diassociation")
        if cap[i].wlan.fc_subtype == '11':
            worksheet.write(row,col+3,"Authentication")
        if cap[i].wlan.fc_subtype == '12':
            worksheet.write(row,col+3,"Deauthentication")
        if cap[i].wlan.fc_subtype == '13':
            worksheet.write(row,col+3,"Action")
        if cap[i].wlan.fc_subtype == '14':
            worksheet.write(row,col+3,"Action No Ack")

    elif cap[i].wlan.fc_type == '1':
        worksheet.write(row,col+2,"Control Frame")
        if cap[i].wlan.fc_subtype == '7':
            worksheet.write(row,col+3,"Control wrapper")
        if cap[i].wlan.fc_subtype == '8':
            worksheet.write(row,col+3,"BlockAck req")
        if cap[i].wlan.fc_subtype == '9':
            worksheet.write(row,col+3,"BlockAck")
        if cap[i].wlan.fc_subtype == '10':
            worksheet.write(row,col+3,"Power Save Poll")
        if cap[i].wlan.fc_subtype == '11':
            worksheet.write(row,col+3,"RTS")
        if cap[i].wlan.fc_subtype == '12':
            worksheet.write(row,col+3,"CTS")
        if cap[i].wlan.fc_subtype == '13':
            worksheet.write(row,col+3,"ACK")
        if cap[i].wlan.fc_subtype == '14':
            worksheet.write(row,col+3,"CFE")
        if cap[i].wlan.fc_subtype == '15':
            worksheet.write(row,col+3,"CFE + CFE ACK")

    elif cap[i].wlan.fc_type == '2':
        worksheet.write(row,col+2,"Data Frame")
        if cap[i].wlan.fc_subtype == '0':
            worksheet.write(row,col+3,"Data")
        if cap[i].wlan.fc_subtype == '1':
            worksheet.write(row,col+3,"Data + CF ACK [PCF Only]")
        if cap[i].wlan.fc_subtype == '2':
            worksheet.write(row,col+3,"Data + CF Poll [PCF Only]")
        if cap[i].wlan.fc_subtype == '3':
            worksheet.write(row,col+3,"Data + CF ACK + CF Poll [PCF Only]")
        if cap[i].wlan.fc_subtype == '4':
            worksheet.write(row,col+3,"Null")
        if cap[i].wlan.fc_subtype == '5':
            worksheet.write(row,col+3,"CF Ack [PCF Only]")
        if cap[i].wlan.fc_subtype == '6':
            worksheet.write(row,col+3,"CF Poll [PCF Only]")
        if cap[i].wlan.fc_subtype == '7':
            worksheet.write(row,col+3,"Data + CF ACK + CF Poll")
        if cap[i].wlan.fc_subtype == '8':
            worksheet.write(row,col+3,"QoS Data [HCF]")
        if cap[i].wlan.fc_subtype == '9':
            worksheet.write(row,col+3,"QoS Data + CF Ack[HCF]")
        if cap[i].wlan.fc_subtype == '10':
            worksheet.write(row,col+3,"QoS Data + CF Poll[HCF]")
        if cap[i].wlan.fc_subtype == '11':
            worksheet.write(row,col+3,"QoS Data + CF Ack + CF Poll[HCF]")
        if cap[i].wlan.fc_subtype == '12':
            worksheet.write(row,col+3,"QoS Null[HCF]")
        if cap[i].wlan.fc_subtype == '14':
            worksheet.write(row,col+3,"QoS CF-Poll(no data)[HCF]")
        if cap[i].wlan.fc_subtype == '15':
            worksheet.write(row,col+3,"QoS CF-Ack + CF-Poll(no data)[HCF]")

    row = row + 1
    i = i + 1

workbook.close()
