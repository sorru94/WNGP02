## WNGP02

Simple python script to sniff packets from wlan networks. It requires tshark to be installed and, in the live capture version to be run as root. Furthermore for the live capture the WiFi adaptor should be set in monitor mode.

The required libraries are: 

- pyshark
- xlsxwriter
- sys
- time

## Usage

We will assume that tshark is correctly installed, the script has root privileges and he WiFi adaptor is in monitor mode.

In order to execute **Live Capture** the script it's sufficient the following shell command:

```
sudo python3 Live_Capture.py seconds_of_capture
```

The seconds_of_capture argument is optional, in case of omission the capture will last 1 minute.

This command will generate two files, one .xlsx containing information about each packet and a .pcap containing all the packets captured.

In order to execute **File Capture** the script it's sufficient the following shell command:

```
sudo python3 Live_Capture.py file_name number_of_packets
```

The arguments are optional, if they are left out the script will parse 100 packets from the file live_capture.py if it exists.

This command will generate one file .xlsx containing information about each packet and a short summary.

## Remarks

The script Live Capture assumes to capture from the interface 'mon0'.