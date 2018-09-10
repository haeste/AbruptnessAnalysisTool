function canvas = changeeventcolour(eventnumber,eventtimes,canvas,colour,handles)
%deselectevent Changes the colour of event highlight to indicate it is no
%longer selected.
%   Deletes the line for this event and replaces it with one that has the
%   colour of an unselected event.
axes(handles.axes1);
delete(canvas.lines1{eventnumber});
canvas.lines1{eventnumber} = plot(eventtimes(:,eventnumber),[canvas.height canvas.height], 'Color',colour , 'LineWidth', 3);
axes(handles.axes2);
delete(canvas.lines2{eventnumber});
canvas.lines2{eventnumber} = plot(eventtimes(:,eventnumber),[canvas.lowpowheight canvas.lowpowheight], 'Color',colour , 'LineWidth', 3);
end

