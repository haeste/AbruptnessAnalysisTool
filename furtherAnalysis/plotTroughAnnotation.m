function plotTroughAnnotation(uiaxes,events,selected_event)
%plotTroughAnnotation Plots the annotation of the troughs detected.
%   Circles the trough peaks detected and plots the exponential fit on top
%   of them. Plots only the event selected.
hold(uiaxes,'on');
troughxtime = events.eventtimecourses{selected_event}(events.troughsData{selected_event}.trough_x);
widetroughxtime = events.eventtimecourses{selected_event}(events.troughsData{selected_event}.wide_trough_x);
sdtroughxtime = events.eventtimecourses{selected_event}(events.troughsData{selected_event}.spreading_x);

plot(uiaxes,troughxtime,events.troughsData{selected_event}.trough_y,'o');
plot(uiaxes,widetroughxtime,events.troughsData{selected_event}.wide_trough_y,'o');
plot(uiaxes,sdtroughxtime,events.troughsData{selected_event}.spreading_y,'o');

hold(uiaxes,'off');
end

