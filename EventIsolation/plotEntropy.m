function plotEntropy( data )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

plot(data.entropy_time_course, data.entropy, 'b');

if isfield(data, 'seizure_times') && ~isempty(data.seizure_times)
    disp('Plotting seizure times')
    curr_seizure_color = [.67 0 1];
    for i = 1:length(data.seizure_times(1,:))
        seizure = data.seizure_times(1,i): data.seizure_times(2,i);
        line(seizure,ones(length(seizure))*max(data.trace), 'Color', curr_seizure_color, 'LineWidth', 3);
    end
end
if isfield(data, 'lrd_times') && ~isempty(data.lrd_times)
   disp('Plotting lrd times')
    curr_seizure_color = [.67 0.5 1];
    for i = 1:length(data.lrd_times(1,:))
        seizure = data.lrd_times(1,i): data.lrd_times(2,i);
        line(seizure,ones(length(seizure))*max(data.trace), 'Color', curr_seizure_color, 'LineWidth', 3);
    end
end
end

