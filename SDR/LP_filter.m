function y = LP_filter(x, m)


blo = fir1(63,m);

y = filter(blo,1,x);
