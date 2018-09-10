function data= getTroughs( slesignal,time,presle,parameters)
%% Smooth signal and combined with the preseizure trace and bring it back to baseline by subtracting the mean.
sf = 1/(time(2) - time(1));

maxtroughwidth = parameters.maxtroughwidth;
if parameters.smooth
    slesignalsmoothed = smooth(slesignal,parameters.smoothwidth)';
else
    slesignalsmoothed = slesignal;
end

threshold = max(diff(slesignal)).*(parameters.threshold/100);
MinDist = 0.2*sf;
%% Find the major troughs in the signal
CV = parameters.cv;
sharppeakwidth = 8e4;
curr_seizure_max_env =  (mean(slesignalsmoothed)- ...
                                    min(slesignalsmoothed)).*(parameters.minpeakprominance/100);
[trough_y, trough_x, widths] = findpeaks(-slesignalsmoothed, 'MinPeakDistance',MinDist, 'MINPEAKPROMINENCE', curr_seizure_max_env,'Threshold',threshold);
width_dev = widths - mean(widths);
width_dev(width_dev<0) = 0;
spreading = width_dev ./ mean(widths) > CV;
data.spreading_y = -trough_y(spreading);
data.spreading_x = trough_x(spreading);
width_std = std(widths(~spreading));
if sum(spreading) > 0
    [~, ~, widths] = findpeaks(-slesignalsmoothed, 'MinPeakDistance',MinDist, 'MINPEAKPROMINENCE', curr_seizure_max_env,'Threshold',threshold,'MaxPeakWidth',mean(widths(~spreading))+width_std);
end
width_dev = widths - mean(widths);
width_dev(width_dev<0) = 0;
spreading = width_dev ./ mean(widths) > CV;
data.spreading_y = [data.spreading_y -trough_y(spreading)];
data.spreading_x = [data.spreading_x trough_x(spreading)];
 width_std = std(widths);
[fine_trough_y, fine_trough_x, data.fine_widths] = findpeaks(-slesignalsmoothed, 'MinPeakDistance',MinDist, 'MINPEAKPROMINENCE', curr_seizure_max_env/2,'Threshold',threshold,'MaxPeakWidth',mean(widths)+width_std/2);
[data.wide_trough_y, data.wide_trough_x, data.wide_widths] = findpeaks(-slesignalsmoothed, 'MinPeakDistance',MinDist, 'MINPEAKPROMINENCE', curr_seizure_max_env/2,'Threshold',threshold,'MinPeakWidth',mean(widths)+width_std/2);
data.wide_trough_y= - data.wide_trough_y;
trough_y = fine_trough_y;
trough_x = fine_trough_x;


% 
% if length(trough_x) > 1
%     trough_x_d = trough_x;
% % details the mean distance between troughs
% 
%     delta_t_curr_seiz   = [mean((diff(trough_x_d)/sf)/3) (diff(trough_x_d)/sf)/3];
% 
% 
%     curr_seiz_mean  = arrayfun(@(n) nanmean(slesignal([-round(delta_t_curr_seiz*sf): round(-.1*sf)]+trough_x_d(n))),1:size(trough_x_d,1));
%     curr_seiz_std   = arrayfun(@(n) nanstd(slesignal([-round(delta_t_curr_seiz*sf): round(-.1*sf)]+trough_x_d(n))),1:size(trough_x_d,1));
% 
% 
%     fine_peak_prom_threshold = mean(abs(curr_seiz_mean(~isnan(curr_seiz_mean))))+(abs(curr_seiz_std(~isnan(curr_seiz_std))));
% 
% 
%      [trough_y, trough_x] = findpeaks(-slesignalsmoothed, 'MINPEAKPROMINENCE',  fine_peak_prom_threshold);
% end

trough_y = -trough_y;
trough_width = [];
troughsds= [];
troughdstime= [];
isspreadingdep = [];
%% Get the signal during the troughs identified above
% We want to look at the frequency components of this signal and fit an
% expoenetial function to it to provide an approximation of its rise time.

trough_times = time(trough_x);
troughpositions = [];
signalmean = mean(slesignalsmoothed);
% Look at the time identified as the minimum of each trough - take this as
% our starting point.
 
for i = 1:length(trough_times)
    
    % start of trough is the minimum identified above
    troughpositions(i,1) = trough_x(i);
    x = trough_x(i);
    % from here we move along the signal until we get back to the baseline
    while slesignalsmoothed(x) < signalmean 
        x = x+1;
        if x > length(slesignal)
            x = x -1;
            break;
        end
    end
    z = trough_x(i);
    while slesignalsmoothed(z) < signalmean
        z = z - 1;
        if z < 1
            z = z +1;
            break;
        end
        
    end
    %we need at least 25 data points of trough
    if x <= trough_x(i)+25
        continue;
    end
    
    
        
    
    % trough ends when it returns to baseline
    troughpositions(i,2) = x;
    %trough starts when it returns to baseline
    troughpositions(i,3) = z;
    %if trough is less than 2 seconds 


    troughsindds = troughpositions(i,3):troughpositions(i,2);
    
    troughssmooth = slesignalsmoothed(troughsindds);
    
    % Find the local minima of the trough

    
    

    trough_width(i) = (troughpositions(i,1)-troughpositions(i,3) ).*sf;
    
    if i > length(trough_times)/2 && trough_width(i)>maxtroughwidth
        isspreadingdep(i) = 1;
    else
        isspreadingdep(i) = 0;
    end
    

    % get the trough signal sampled at 1000 hz
    
    troughdstime{i} = time(troughsindds);
    troughsds{i} = slesignalsmoothed(troughsindds);
    


    
    
end

data.trough_y = trough_y;
data.trough_amp = trough_y;
data.trough_x = trough_x;
data.trough_widths = trough_width;
data.troughsds =  troughsds;
data.troughdstime = troughdstime;
data.isspreadingdep = isspreadingdep;
    

end

