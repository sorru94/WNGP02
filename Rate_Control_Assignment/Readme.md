### Transmit rate control Assignment

To run our the simulation with our algorithm:

```matlab
[throughput, bitErrorRate, SNRMeasured] = TransmitRateControlExample('CBW20',1024,'Model-A',5,100);
```

Where the arguments are:

- Channel Bandwidth
- Payload in Bytes
- Delay model
- Distance in meters
- Number of packets

And the returned values are:

- Throughput of the simulation
- Bit error rate of the simulation
- Array containing the SNR measured for each packet

