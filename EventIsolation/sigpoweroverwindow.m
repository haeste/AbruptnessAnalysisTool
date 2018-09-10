function [power,pwtimecourse ] = sigpoweroverwindow( signal,window,sf)
%UNTITLED2 window should be in seconds
%   Detailed explanation goes here
windowinsteps = sf*window;
length(signal)
windowinsteps
numberofwindows = round((length(signal)/windowinsteps)-0.5);
windowpositions = 1:windowinsteps:length(signal);
length(windowpositions);
power = zeros(round(numberofwindows),1);
size(power)

for i = 1:numberofwindows-1
    power(i,1) = mean(signal(windowpositions(i):windowpositions(i+1)).^2);
end

pwtimecourse = window:window:(length(signal)/sf);
% length(pwtimecourse)
% power = resample(power,length(signal),length(power));
% pwtimecourse = (1:length(power))./sf;
% 
% disp(length(power))
% disp(length(pwtimecourse))
end

