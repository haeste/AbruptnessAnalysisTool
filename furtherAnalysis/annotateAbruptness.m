function  annotateAbruptness(axes,events,selected_event)
%annotateAbruptness Plots the MUA and logistic funtion fit to it.
%   Detailed explanation goes here
try
    disp('Plotting abruptness annotation.')
    plot(axes,events.eventtimecourses{selected_event},events.Abruptness{selected_event}.mua);
    hold(axes,'on');
    plot(axes,events.Abruptness{selected_event}.MUA_fit_time+events.eventtimecourses{selected_event}(1),events.Abruptness{selected_event}.mua_y,'LineWidth',0.5);

    plot(axes,events.Abruptness{selected_event}.MUA_fit_time+events.eventtimecourses{selected_event}(1),events.Abruptness{selected_event}.MUA_fit,'LineWidth',2);
    hold(axes,'off');
catch
    disp('Error plotting abruptness annotation.')
end


end

