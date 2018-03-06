function [final,disc_out_filt,disc_out_filt_dec,disc_out,xfilt_dec,xfilt] = FM_receiver(x,B1,N1,B2,N2,fs)
%Call with: [x,y,t,r,e,w] = FM_receiver('capture97R1k.bin',100E3,10,15E3,5,2.4E6);

% To get a radio 10:
% SDR>rtl_sdr -s 2400000 -f 103800000 -g 25 capture103R1k.bin

%If needed to print the PSD:
%simpleSA(x,2^14,fc);

x = loadFile(x);



%initial sampling frequency, that is, 2.4E6
fc = fs;
%sampling frequency for the filters (Half-Band)
fb = fc/2;

%cut off frequency for the first low pass filter to avoid aliasing as part of the
%decimation process.
fs = B1;

simpleSA(x,2^14,fc);
%Decimation: Lowpass and downsampling
%b_lp = fir1(Norder, 2*fc/fs)
xfilt = LP_filter(x, fs/fb);
xfilt_dec = downsample(xfilt,N1);


%intermediate sampling frequency
fc = fc/N1;
%intermediate sampling frequency for the filters (Half-Band)
fb = fc/2;
%cut off frequency for second filter
fs = B2;

simpleSA(xfilt_dec,2^14,fc);
%FM -> AM
disc_out = discrim(xfilt_dec);
disc_out_filt = LP_filter(disc_out, fs/fb);
disc_out_filt_dec = downsample(disc_out_filt,N2);

fc = fc/N2;

simpleSA(disc_out_filt_dec,2^14,fc);

%last filter -> De-emphasis filter = decreases the magnitude of higher
%frequencies and optimizes the SNR

%european standard is different from american
t = 50E-6;
f3 = 1/(2*pi*t);
a1 = exp(-2*pi*f3/fc);
b = 1-a1;
a = [1, -a1];
final = filter(b,a,disc_out_filt_dec);

%normalizing for the sound function
mx = max(abs(final));
disc_out_filt_n = disc_out_filt_dec/mx;
sound(disc_out_filt_n,fc);

