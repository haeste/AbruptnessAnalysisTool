function  plotCurrentMetric(uiaxes,events,selected_event,selectedTab,parameters)
%plotCurrentMetric Plots the annotation of the metric currently selected as
%a tab.
%   Decides which metric is selected based on which tab is selected then
%   calls the correct function to plot the annotation of this metric.
switch selectedTab.Title
    case 'Troughs'
        plotTroughAnnotation(uiaxes,events,selected_event);
    case 'Abruptness'
        annotateAbruptness(uiaxes,events,selected_event);
    case 'TroughAbruptness'
        annotateAbruptnessTrough(uiaxes,events,selected_event,parameters);
    case 'Coastline'
        plotCoastline(uiaxes,events.Coast{selected_event},events.Coastsum{selected_event});
    case 'Power'
        barfreqbands(uiaxes,events.PowerBands{selected_event});
end

end

