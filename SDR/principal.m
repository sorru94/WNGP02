% To get a radio 10:
% SDR>rtl_sdr -s 2400000 -f 103800000 -g 25 capture103R1k.bin

x = loadFile('capture97R1k.bin');

%initial sampling frequency
fc = 2.4E6;
%sampling frequency for the filters (Half-Band)
fb = fc/2;
%cut off frequency of the first filter
fs = 100E3;
%First decimation parameter
N1 = 10;

%simpleSA(x,2^14,fc);

xfilt = LP_filter(x, fs/fb);
xfilt_dec = Decim(xfilt,N1);

%intermediate sampling frequency
fc = fc/N1;
%intermediate sampling frequency for the filters (Half-Band)
fb = fc/2;
%cut off frequency for second filter
fs = 15E3;

%simpleSA(xfilt_dec,2^14,fc);

disc_out = discrim(xfilt_dec);

%simpleSA(disc_out,2^14,fc);

disc_out_filt = LP_filter(disc_out, fs/fb);

%simpleSA(disc_out_filt,2^14,fc);

N2 = 5;
%No idea why, but the second decimatiomn has something wrong!!!
disc_out_filt_dec = Decim(disc_out_filt,N2); 

fc = fc/N2;

%normalizing for the sound function
mx = max(abs(disc_out_filt_dec));
disc_out_filt_n = disc_out_filt_dec/mx;
sound(disc_out_filt_n,fc);
