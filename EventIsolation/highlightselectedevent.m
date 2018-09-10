function lines = highlightselectedevent(lines,selectedevent,eventtime,data)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

eventtime = eventtimes{selectedevent};
twostdtrace = 2*std(data.trace);

lines{selectedevent} =  plot(eventtime,[height height], 'Color',[0,0,0] , 'LineWidth', 3);
end

