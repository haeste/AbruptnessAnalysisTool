function events = calculateMetrics(events,metrics,parameters,selected_event)
%calculateMetrics Calculates all of the main metrics for each event
%   Detailed explanation goes here
if nargin < 4 
    selected_event = 1:length(events.eventtraces);
end
if strcmp(metrics,'Troughs') || strcmp(metrics,'all')
    for i_event = selected_event
        events.troughsData{i_event} = getTroughs(events.eventtraces{i_event},...
            events.eventtimecourses{i_event},events.preseizure{i_event},parameters);

    end
end
% if strcmp(metrics,'troughs_fit')
%     for i_event = 1:length(events.eventtraces)
%         for i_trough = 1:length(events.troughsData{i_event}.trough_x)
%             [events.troughsData{i_event}.decay{i_trough}, ...
%                 events.troughsData{i_event}.fit_error{i_trough},... 
%                 events.troughsData{i_event}.fit{i_trough}] = ...
%                 makeTroughExpFit(events.troughsData{i_event}.troughsds{i_trough},events{i_event}.sd);
%                 
%         end
%     end
% end
if strcmp(metrics,'Abruptness') || strcmp(metrics,'all')
    for i_event = selected_event
        try
            events.Abruptness{i_event} = getAbruptness(events.eventtraces{i_event},...
                events.sf{i_event},parameters,events.Abruptness{i_event});
        catch
            disp('Error calculating abruptness with these parameters.')
        end
    end
end
if strcmp(metrics,'TroughAbruptness') || strcmp(metrics,'all')
    for i_event = selected_event
        %try
            events.Abruptness{i_event} = getTroughAbruptness(events.troughsData{i_event}.trough_x,events.troughsData{i_event}.trough_y,...
                events.Abruptness{i_event});
        %catch
           % disp('Error calculating abruptness with these parameters.')
        %end
    end
end
if strcmp(metrics,'Coastline') || strcmp(metrics,'all')
    for i_event = selected_event
        [events.Coastline{i_event},events.Intermittancy{i_event}, events.Coast{i_event},events.Coastsum{i_event}]  = calculateCoastline(events.eventtraces{i_event},...
            events.sf{i_event});
    end
    
    
end
if strcmp(metrics,'Power') || strcmp(metrics,'all')
    for i_event = selected_event
        events.PowerBands{i_event} = getnormalisedfrequencybands(events.eventtraces{i_event},...
            events.eventtimecourses{i_event});
    end
    
    
end
end

