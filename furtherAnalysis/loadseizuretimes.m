function [ info ] = loadseizuretimes( filename )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%m = csvread([recording '-tr' trace 'seizuretimes.csv'],1);
m = csvread(filename,1);
disp(m(1,:))
%m(:,1)
for i = 1:length(m(:,1))
    info.recordings{i} = filename;

end

info.trace = m(:,1);
if length(unique(info.trace))>1
    warndlg('The event times should be for a single trace. Multiple traces detected in this file.');
end
info.trace_uni = unique(info.trace);
info.number = m(:,2);
info.starttime = m(:,3);
info.endtime = m(:,4);
info.seizuretimes = m(:,3:4);
length(info.recordings)
i = 1;
while i < length(info.starttime)
    if info.starttime(i) < 1 || info.endtime(i) <1 
        disp(['Removing from: ' info.recordings{i}]);
        info.recordings(i) = [];
        info.trace(i) = [];
        info.number(i) = [];
        info.starttime(i) = [];
        info.endtime(i) = [];
        info.seizuretimes(i) = [];
    else 
        i = i+1;
    end
end

length(info.recordings)
length(info.starttime)
        
end

