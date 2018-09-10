function [ psdx, freq] = createSignalFrequencyDist( x, Fs )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
N = length(x);
xdft = fft(x);
xdft = xdft(1:round(N/2)+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
psdx = psdx(1:end-1);
plogfreq = 10*log10(psdx);


freq = 0:Fs/length(x):Fs/2;

end

