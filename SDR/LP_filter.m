function y = LP_filter(x, m)

%FIR lowpass having Norder+1 taps
blo = fir1(63, m ,'low');
%maybe put 'low'

%note: output of the fir1 function are the filter coefficients returned as
%a row vector of lenght n+1

%General FIR/IIR filtering using coefficient vectors b & a
%y_out = filter(b, a, x_in);
% x_in = input data
% b -> Numerator coefficients of the rational transfer function
% a -> Denominator coefficients of the rational transfer function
y = filter(blo,1,x);
