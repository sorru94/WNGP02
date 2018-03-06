## WNGP02

Simple python script to sniff packets from wlan networks. It requires tshark to be installed and, in the live capture version to be run as root. Furthermore for the live capture the WiFi adaptor should be set in monitor mode.

The required libraries are: 

- pyshark
- xlsxwriter

## Usage

We will assume that tshark is correctly installed, the script has root privileges and he WiFi adaptor is in monitor mode.

In order to execute **Live Capture** the script it's sufficient the following shell command:

```
python3 Live_Capture.py
```

The above command will generate two files.