function [dataRate,ErrRate, snrMeasured, dw_threshold] = TransmitRateControl_NDira(CB, Pl, DelProf, Dist, num, jump)
%CB = channel bandwidth ('CBW40')
%Pl = payload (4096)
%DelProf = DelayProfile ('Model-D')
%Dist = distance transmitter receiver (20)
%num = number of packets (100)

%% Waveform Configuration

cfgVHT = wlanVHTConfig;         
cfgVHT.ChannelBandwidth = CB;       %i.e. 'CBW20' %channel bandwidth in MHz
cfgVHT.MCS = 1;                     % Starting MCS (QPSK rate-1/2)
cfgVHT.APEPLength = Pl;             %i.e. 4096, 1024, 2048 % payload in bytes (APEP length in bytes)

% Set random stream for repeatability of results
s = rng(21);

%% Channel Configuration

tgacChannel = wlanTGacChannel;
tgacChannel.DelayProfile = DelProf;             %from 'Model-A' to 'Model-F'
tgacChannel.ChannelBandwidth = cfgVHT.ChannelBandwidth;
tgacChannel.NumTransmitAntennas = 1;
tgacChannel.NumReceiveAntennas = 1;
tgacChannel.TransmitReceiveDistance = Dist;      %20,5 % Distance in meters for NLOS
tgacChannel.RandomStream = 'mt19937ar with seed';
tgacChannel.Seed = 10;

% Set the sampling rate for the channel
sr = wlanSampleRate(cfgVHT);
tgacChannel.SampleRate = sr;


%% Simulation Parameters

numPackets = num; % Number of packets transmitted during the simulation 
walkSNR = true; 

% Select SNR for the simulation
if walkSNR
    meanSNR = 22;                           % Mean SNR
    amplitude = 14;                         % Variation in SNR around the average mean SNR value
    % Generate varying SNR values for each transmitted packet (sinusoidal tendency)
    baseSNR = sin(linspace(1,10,numPackets))*amplitude+meanSNR;
    snrWalk = baseSNR(1);                   % Set the initial SNR value
    
    % The maxJump controls the maximum SNR difference between one
    % packet and the next (when adding the random walk, done for each packet individually)
    maxJump = jump;          %0.5,10;
else
    % Fixed mean SNR value for each transmitted packet. All the variability
    % in SNR comes from a time varying radio channel
    snrWalk = 22; %#ok<UNRCH>
end

% To plot the equalized constellation for each spatial stream set
% displayConstellation to true
displayConstellation = false;
if displayConstellation
    ConstellationDiagram = comm.ConstellationDiagram; %#ok<UNRCH>
    ConstellationDiagram.ShowGrid = true;
    ConstellationDiagram.Name = 'Equalized data symbols';
end

% Define simulation variables
snrMeasured = zeros(1,numPackets);
MCS = zeros(1,numPackets);
ber = zeros(1,numPackets);
packetLength = zeros(1,numPackets);

%% Constructing tresholds tables

%Using the known signal quality tables, set the MCS thresholds

    BW40 = false;
    BW20 = false;
    BW80 = false;
    BW160= false;
    
    BW = length(cfgVHT.ChannelBandwidth);
    
   %NB 20Mhz and 40MHz are not so dissimilar
   if BW==5
       if cfgVHT.ChannelBandwidth == 'CBW20'
       BW20 = true;
       end
   end
   if BW==5
       if cfgVHT.ChannelBandwidth == 'CBW40'
       BW40 = true;
       end
   end
   if BW==5
       if cfgVHT.ChannelBandwidth == 'CBW80'
       BW80 = true;
       end
   end
   if BW==6
       if cfgVHT.ChannelBandwidth == 'CBW160'
       BW160 = true;
       end
   end

   if cfgVHT.APEPLength < 1536
        dw_threshold = [-inf 12 0 18 23 0 29 0 35];
        up_threshold = [11 17 0 22 28 0 35 0 inf inf];
   end
   if cfgVHT.APEPLength > 1536 && cfgVHT.APEPLength < 2560
        dw_threshold = [-inf 12 0 18 24 27 30 0 35 inf];
        up_threshold = [11 17 0 23 26 29 34 0 inf inf];
   end
   if cfgVHT.APEPLength > 2560
        dw_threshold = [-inf 13 0 18 24 27 30 34 35 inf];
        up_threshold = [12 17 0 23 26 29 33 34 inf inf];
   end
  

   %modify the tables using the channel efficiency estimations
   if BW80 == true
       cont = 1;
       while cont <= 9
           if dw_threshold(cont) ~= 0
               dw_threshold(cont) = dw_threshold(cont) -3;
           end
           if up_threshold(cont) ~= 0
               up_threshold(cont) = up_threshold(cont) -3;
           end
           cont = cont + 1;
       end
   end
   if BW160 == true
       cont = 1;
       while cont <= 9
           if dw_threshold(cont) ~= 0
               dw_threshold(cont) = dw_threshold(cont) -4;
           end
           if up_threshold(cont) ~= 0
               up_threshold(cont) = up_threshold(cont) -4;
           end
           cont = cont + 1;
       end
   end



%% Processing Chain

EMAstore = zeros(1,numPackets);
IndexEMA = 1;
EMA =0;

for numPkt = 1:numPackets 
    if walkSNR
        % Generate SNR value per packet using random walk algorithm biased
        % towards the mean SNR
        % using snrWalk*0.9 because of the walk, maybe remove it in order
        % to have more controllable results
        snrWalk = 0.9*snrWalk+0.1*baseSNR(numPkt)+rand(1)*maxJump*2-maxJump;
    end
    
    % Generate a single packet waveform
    txPSDU = randi([0,1],8*cfgVHT.PSDULength,1,'int8');
    txWave = wlanWaveformGenerator(txPSDU,cfgVHT,'IdleTime',5e-4);
    
    % Receive processing, including SNR estimation
    y = processPacket(txWave,snrWalk,tgacChannel,cfgVHT);
    
    % Plot equalized symbols of data carrying subcarriers
    if displayConstellation && ~isempty(y.EstimatedSNR)
        release(ConstellationDiagram);
        ConstellationDiagram.ReferenceConstellation = helperReferenceSymbols(cfgVHT);
        ConstellationDiagram.Title = ['Packet ' int2str(numPkt)];
        ConstellationDiagram(y.EqDataSym(:));
        drawnow 
    end
    
    % Store estimated SNR value for each packet
    if isempty(y.EstimatedSNR) 
        snrMeasured(1,numPkt) = NaN;
    else
        snrMeasured(1,numPkt) = y.EstimatedSNR;
    end
    
    % Determine the length of the packet in seconds including idle time
    packetLength(numPkt) = y.RxWaveformLength/sr;
    
    
    % Calculate packet error rate (PER)
    if isempty(y.RxPSDU)
        % Set the PER of an undetected packet to NaN
        ber(numPkt) = NaN;
    else
        [~,ber(numPkt)] = biterr(y.RxPSDU,txPSDU);
    end

    %Save the current packet MCS
    currentMCS = cfgVHT.MCS; 
    MCS(numPkt) = cfgVHT.MCS;
   

   currentSNR = snrMeasured(1,numPkt);
   current_dth = dw_threshold(currentMCS+1);
   current_uth = up_threshold(currentMCS+1);

   change = 0;
   
   if(currentSNR >= current_dth && currentSNR <= current_uth)
       cfgVHT.MCS = currentMCS;
   else
       
       if (currentSNR > current_uth)
           %if the next jum leads to a 0
           if and(~BW20,currentMCS ~= 9) || and(BW20,currentMCS ~= 8)
                next_uth = up_threshold(currentMCS+2);
                if next_uth == 0
                    cfgVHT.MCS = currentMCS + 2;
                    change =2;
                else
                    cfgVHT.MCS = currentMCS + 1;
                    change =1;
                end
           end
       else
           if (currentSNR < current_dth)
           %if the next jum leads to a 0
           if currentMCS ~= 0
               prew_dth = dw_threshold(currentMCS);
               if prew_dth == 0
                   cfgVHT.MCS = currentMCS - 2;
                   change = -2;
               else
                   cfgVHT.MCS = currentMCS - 1;
                   change = -1;
               end
           end
           
           end
       end
   end
   
    %compute the EMA of the previous packets up until windows of 20
    
    lambda = 0.75;
    if(numPkt >= 20)
        numEMA = ber(1,numPkt);
        denEMA = 1;
        powerIndex = 1;
       for window = numPkt:-1:numPkt-18
        numEMA = numEMA + power(lambda,powerIndex)*ber(1,window-1); %changed to "window-1"
        denEMA = denEMA + power(lambda, powerIndex); 
        powerIndex = powerIndex + 1;
       end
       
       EMA = numEMA/denEMA;
       EMAstore(IndexEMA) = EMA ;
       IndexEMA = IndexEMA + 1;
    end
    
    if and(EMA > 0.018,cfgVHT.MCS~=0)
        currentMCS = cfgVHT.MCS; 
        cfgVHT.MCS = currentMCS - 1;
    end
 
end

%% Display and Plot Simulation Results

dataRate = 8*cfgVHT.APEPLength*(numPackets-numel(find(ber)))/sum(packetLength)/1e6;
ErrRate = numel(find(ber))/numPackets;

% Display and plot simulation results
disp(['Overall data rate: ' num2str(8*cfgVHT.APEPLength*(numPackets-numel(find(ber)))/sum(packetLength)/1e6) ' Mbps']);
disp(['Overall packet error rate: ' num2str(numel(find(ber))/numPackets)]);

%plotResults(ber,packetLength,snrMeasured,MCS,cfgVHT);

% Restore default stream
rng(s);

displayEndOfDemoMessage(mfilename)

end
%% Local Functions
% The following local functions are used in this example:
%
% * |processPacket|: Add channel impairments and decode receive packet
% * |plotResults|: Plot the simulation results


function Y = processPacket(txWave,snrWalk,tgacChannel,cfgVHT)
    % Pass the transmitted waveform through the channel, perform
    % receiver processing, and SNR estimation.
    
    chanBW = cfgVHT.ChannelBandwidth; % Channel bandwidth
    % Set the following parameters to empty for an undetected packet
    estimatedSNR = [];
    eqDataSym = [];
    noiseVarVHT = [];
    rxPSDU = [];
    
    % Get the number of occupied subcarriers in VHT fields
    [vhtData,vhtPilots] = helperSubcarrierIndices(cfgVHT,'VHT');
    Nst_vht = numel(vhtData)+numel(vhtPilots);
    Nfft = helperFFTLength(cfgVHT); % FFT length
    
    % Pass the waveform through the fading channel model
    rxWave = tgacChannel(txWave);

    
    
    % Create an instance of the AWGN channel for each transmitted packet
    awgnChannel = comm.AWGNChannel;
    awgnChannel.NoiseMethod = 'Signal to noise ratio (SNR)';
    % Normalization
    awgnChannel.SignalPower = 1/tgacChannel.NumReceiveAntennas;
    % Account for energy in nulls
    awgnChannel.SNR = snrWalk-10*log10(Nfft/Nst_vht);
    
    % Add noise
    rxWave = awgnChannel(rxWave);
    rxWaveformLength = size(rxWave,1); % Length of the received waveform
    
    % Recover packet
    ind = wlanFieldIndices(cfgVHT); % Get field indices
    pktOffset = wlanPacketDetect(rxWave,chanBW); % Detect packet
    
    if ~isempty(pktOffset) % If packet detected
        % Extract the L-LTF field for fine timing synchronization
        LLTFSearchBuffer = rxWave(pktOffset+(ind.LSTF(1):ind.LSIG(2)),:);
    
        % Start index of L-LTF field
        finePktOffset = wlanSymbolTimingEstimate(LLTFSearchBuffer,chanBW);
     
        % Determine final packet offset
        pktOffset = pktOffset+finePktOffset;
        
        if pktOffset<15 % If synchronization successful
            % Extract L-LTF samples from the waveform, demodulate and
            % perform noise estimation
            LLTF = rxWave(pktOffset+(ind.LLTF(1):ind.LLTF(2)),:);
            demodLLTF = wlanLLTFDemodulate(LLTF,chanBW);

            % Estimate noise power in non-HT fields
            noiseVarVHT = helperNoiseEstimate(demodLLTF,chanBW,cfgVHT.NumSpaceTimeStreams,'Per Antenna');

            % Extract VHT-LTF samples from the waveform, demodulate and
            % perform channel estimation
            VHTLTF = rxWave(pktOffset+(ind.VHTLTF(1):ind.VHTLTF(2)),:);
            demodVHTLTF = wlanVHTLTFDemodulate(VHTLTF,cfgVHT);
            chanEstVHTLTF = wlanVHTLTFChannelEstimate(demodVHTLTF,cfgVHT);

            % Recover equalized symbols at data carrying subcarriers using
            % channel estimates from VHT-LTF
            [rxPSDU,~,eqDataSym] = wlanVHTDataRecover( ...
                rxWave(pktOffset + (ind.VHTData(1):ind.VHTData(2)),:), ...
                chanEstVHTLTF,mean(noiseVarVHT),cfgVHT);
            
            % SNR estimation per receive antenna
            powVHTLTF = mean(VHTLTF.*conj(VHTLTF));
            estSigPower = powVHTLTF-noiseVarVHT;
            estimatedSNR = 10*log10(mean(estSigPower./noiseVarVHT));
        end
    end
    
    % Set output
    Y = struct( ...
        'RxPSDU',           rxPSDU, ...
        'EqDataSym',        eqDataSym, ...
        'RxWaveformLength', rxWaveformLength, ...
        'NoiseVar',         noiseVarVHT, ...
        'EstimatedSNR',     estimatedSNR);
    
end

function plotResults(ber,packetLength,snrMeasured,MCS,cfgVHT)
    % Visualize simulation results

    figure('Outerposition',[50 50 900 700])
    subplot(4,1,1);
    plot(MCS);
    xlabel('Packet Number')
    ylabel('MCS')
    title('MCS selected for transmission')

    subplot(4,1,2);
    plot(snrMeasured);
    xlabel('Packet Number')
    ylabel('SNR')
    title('Estimated SNR')

    subplot(4,1,3);
    plot(find(ber==0),ber(ber==0),'x') 
    hold on; stem(find(ber>0),ber(ber>0),'or') 
    if any(ber)
        legend('Successful decode','Unsuccessful decode') 
    else
        legend('Successful decode') 
    end
    xlabel('Packet Number')
    ylabel('BER')
    title('Instantaneous bit error rate per packet')

    subplot(4,1,4);
    windowLength = 3; % Length of the averaging window
    movDataRate = movsum(8*cfgVHT.APEPLength.*(ber==0),windowLength)./movsum(packetLength,windowLength)/1e6;
    plot(movDataRate)
    xlabel('Packet Number')
    ylabel('Mbps')
    title(sprintf('Throughput over last %d packets',windowLength))
    
end