function canvas = addannotation(data,currentaxes,canvas,axisnum)
%addannotation Adds lines above the events to show where has been
%designated an event.

if axisnum == 2
    canvas.lines2 = [];
else
    canvas.lines1 = [];
end
hold(currentaxes,'on');
if (isfield(data, 'seizure_times') && ~isempty(data.seizure_times))    
    for i = 1:length(data.seizure_times(1,:))
        curr_seizure_color = canvas.eventcolour;
        eventtimes = [data.seizure_times(1,i), data.seizure_times(2,i)];
        if isfield(data, 'selection') && data.selection == i
            curr_seizure_color = canvas.selectcolour;
        end
        if axisnum == 2
            canvas.lines2{i} = plot(eventtimes,[canvas.lowpowheight canvas.lowpowheight], 'Color', curr_seizure_color, 'LineWidth', 3);
        else
            canvas.lines1{i} = plot(eventtimes,[canvas.height canvas.height], 'Color', curr_seizure_color, 'LineWidth', 3);
        end
    end
    
end
hold(currentaxes,'off');
end

