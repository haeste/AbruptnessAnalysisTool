function [ high, low,band ] = filter_trace( trace,fs, params )
%filte_trace returns the signal, highpass filtered at highpass frequency
%and lowpass filtered at low pass frequency

order = 5;
if isfield(params, 'lowpass')
    [b,a] = butter(order,params.lowpass/(fs/2),'low');
    low = filtfilt(b,a,trace);
else 
    low = [];
end

order = 7;%order is typically higher for highpass
if isfield(params, 'highpass')
    [b,a] = butter(order,params.highpass/(fs/2),'high');
    high = filtfilt(b,a,trace);
else
    high = [];
end

% if isfield(params, 'bandpasslow') && isfield(params, 'bandpasshigh')
%     [b,a] = butter(order,params.bandpasshigh/(fs/2),params.bandpasslow/(fs/2),'band');
%     band = filtfilt(b,a,trace);
% else
%     band = [];
% end
    band = [];
end

