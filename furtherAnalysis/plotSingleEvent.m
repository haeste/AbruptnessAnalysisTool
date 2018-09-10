function plotSingleEvent(axes,events,event_index,parameters)
%plotSingleEvent Plots the selected event to the main axes
%   Detailed explanation goes here
if parameters.smooth
    plot(axes,events.eventtimecourses{event_index},smooth(events.eventtraces{event_index},parameters.smoothwidth));
else
    plot(axes,events.eventtimecourses{event_index},events.eventtraces{event_index});
end
end

