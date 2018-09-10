function [ canvas ] = plottraceandannotation( data,currentaxes,canvas,axesnum,trace)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
hold(currentaxes,'on')
if nargin == 5
    plot(data.time_course, trace);
else
    plot(data.time_course, data.trace);
end

if (isfield(data, 'seizure_times') && ~isempty(data.seizure_times))    
    for i = 1:length(data.seizure_times(1,:))
        curr_seizure_color = canvas.eventcolour;
        eventtimes = [data.seizure_times(1,i), data.seizure_times(2,i)];
        if isfield(data, 'selection') && data.selection == i
            curr_seizure_color = canvas.selectcolour;
        end
        if axesnum ==1
            canvas.lines1{i} = plot(eventtimes,[canvas.height canvas.height], 'Color', curr_seizure_color, 'LineWidth', 3);
        else
            canvas.lines2{i} = plot(eventtimes,[canvas.lowpowheight canvas.lowpowheight], 'Color', curr_seizure_color, 'LineWidth', 3);
        end
    end
    
end
hold(currentaxes,'off')


end

