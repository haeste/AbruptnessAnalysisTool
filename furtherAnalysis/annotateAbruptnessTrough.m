function annotateAbruptnessTrough(uiaxes,events,selected_event,parameters)
%annotateAbruptnessTrough Summary of this function goes here
%   Detailed explanation goes here
x = events.Abruptness{selected_event}.trough_x ./ events.sf{selected_event};
troughxtime =  x +  events.eventtimecourses{selected_event}(1);
plotSingleEvent(uiaxes,events,selected_event,parameters);
hold(uiaxes, 'on');
plotTroughAnnotation(uiaxes,events,selected_event);
hold(uiaxes, 'on');

plot(uiaxes,troughxtime,events.Abruptness{selected_event}.trough_fit,'LineWidth',4);
hold(uiaxes, 'off');
end

