function [coastline,intermittancy,coast,coastsum] = calculateCoastline(signal,presle)
%calculateCoastline Calculates the coastline and intermittancy of the
%signal.
%   Coastline is the sum of the deviation of the signal minus a baseline
%   taken from before the event.
coastsum = cumsum(abs(diff(signal)));
coast = sort(abs(diff(signal)),'descend');
meandeviation = mean(abs(diff(presle)));
coastline = (sum(coast)/length(signal))./meandeviation;
intermittancy = sum(coast(1:round(length(coast)/5)))/sum(coast);
end

