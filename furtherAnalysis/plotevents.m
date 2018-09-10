function plotevents(fuid,events)
%plotevents plots all the events onto the figure id given
hold(fuid, 'on');
for i = 1:length(events.eventtraces)
    plot(fuid,events.eventtimecourses{i},events.eventtraces{i},'k');
end
hold(fuid, 'off');

end

