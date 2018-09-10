function [ bands ] = getnormalisedfrequencybands( signal,time)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

sf = 1/(time(2) - time(1));
[psdx, freq] = createSignalFrequencyDist(signal,sf);
freqdist= psdx;
totalpower = sum(freqdist(freq>1 & freq<500));

bands.delta = mean(freqdist(freq>1 & freq < 4)./totalpower);
bands.theta = mean(freqdist(freq>4 & freq < 8)./totalpower);
bands.alpha =  mean(freqdist(freq>8 & freq < 13)./totalpower);
bands.beta = mean(freqdist(freq>13 & freq < 30)./totalpower);
bands.gamma = mean(freqdist(freq>30 & freq < 80)./totalpower);
bands.hfo = mean(freqdist(freq>100 & freq < 500)./totalpower);




end

