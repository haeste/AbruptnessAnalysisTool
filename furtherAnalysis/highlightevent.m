function highlightline = highlightevent(axes, event_times,event_max,highlightline)
%highlightevent Draws a line under the selected event
%   Detailed explanation goes here
hold(axes,'on');
if nargin == 3
    highlightline = plot(axes,event_times,[event_max, event_max],'Color',[0.7 0 0.2],'LineWidth', 4);
elseif nargin == 4
    delete(highlightline);
    highlightline = plot(axes,event_times,[event_max, event_max],'Color',[0.7 0 0.2],'LineWidth', 4);
end
hold(axes,'off');
    

end

