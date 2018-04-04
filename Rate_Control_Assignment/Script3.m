%% Measurement 1

result1 = zeros(45,9);
ChannelBandwidth = 'CBW40'; %CBW40, CBW20, CBW80, CBW160
payload = 4096; %1024,4096,2048 NB 8192 is too big!!
DelayProfile = 'Model-F';
TransmitReceiveDistance = 20;
numPackets = 100;
l = [];
%NB MCS tested is (M-1)
for M = 1:10
    for SNR = 6:45
        result1(SNR, M) = Helper_efficiency_calc(SNR, M, ChannelBandwidth, payload, DelayProfile, TransmitReceiveDistance,numPackets);
       l(1) = SNR;
        l(2) = M-1;
    end
end

%% Measurement 2
measurement = 2

result2 = zeros(45,9);
ChannelBandwidth = 'CBW40';
payload = 4096; %4096,2048
DelayProfile = 'Model-D';
TransmitReceiveDistance = 10;

l = [];
%NB MCS tested is (M-1)
for M = 1:10
    for SNR = 6:45
        result2(SNR, M) = Helper_efficiency_calc(SNR, M, ChannelBandwidth, payload, DelayProfile, TransmitReceiveDistance,numPackets);
       l(1) = SNR;
        l(2) = M-1;
    end
end


%% Measurement 3
measurement = 3

result3 = zeros(45,9);
ChannelBandwidth = 'CBW40';
payload = 4096; %4096,2048
DelayProfile = 'Model-D';
TransmitReceiveDistance = 30;

l = [];
%NB MCS tested is (M-1)
for M = 1:10
    for SNR = 6:45
        result3(SNR, M) = Helper_efficiency_calc(SNR, M, ChannelBandwidth, payload, DelayProfile, TransmitReceiveDistance,numPackets);
       l(1) = SNR;
        l(2) = M-1;
    end
end

%% Measurement 4
measurement = 4

result4 = zeros(45,9);
ChannelBandwidth = 'CBW40';
payload = 4096; %4096,2048
DelayProfile = 'Model-D';
TransmitReceiveDistance = 50;

l = [];
%NB MCS tested is (M-1)
for M = 1:10
    for SNR = 6:45
        result4(SNR, M) = Helper_efficiency_calc(SNR, M, ChannelBandwidth, payload, DelayProfile, TransmitReceiveDistance,numPackets);
       l(1) = SNR;
        l(2) = M-1;
    end
end

%% Measurement 5
measurement = 5

result5 = zeros(45,9);
ChannelBandwidth = 'CBW40';
payload = 4096; %4096,2048
DelayProfile = 'Model-D';
TransmitReceiveDistance = 5;

l = [];
%NB MCS tested is (M-1)
for M = 1:10
    for SNR = 6:45
        result5(SNR, M) = Helper_efficiency_calc(SNR, M, ChannelBandwidth, payload, DelayProfile, TransmitReceiveDistance,numPackets);
       l(1) = SNR;
        l(2) = M-1;
    end
end