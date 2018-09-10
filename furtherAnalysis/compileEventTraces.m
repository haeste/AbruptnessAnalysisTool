function [info] = compileEventTraces(data_vec,time_vec,info)
%compileEventTraces Retreives the segments of the trace that correspond to
%the events marked by the time stamps. Also collects some time before the
%seizure.
%   Detailed explanation goes here
%if trace numbers recorded from 0 then add 1
rec_preseizure = 1;
if min(info.trace) == 0
    info.trace = info.trace+1;
end
info.eventtraces = cell(length(info.recordings));

for i = 1:length(info.recordings)

    seizure_ind = time_vec>info.starttime(i) & time_vec<info.endtime(i);
    if rec_preseizure
        if info.starttime(i) > 5
            preseizure_ind = time_vec>(info.starttime(i)-5) & time_vec<info.starttime(i);
            info.preseizure{i} = data_vec{info.trace(i)}(preseizure_ind);
            info.preseizure_timecourse{i} = time_vec(preseizure_ind);
        end
    end
    info.eventtraces{i} = data_vec{info.trace(i)}(seizure_ind);

    info.eventtimecourses{i} = time_vec(seizure_ind);
    info.sf{i} = 1/(info.eventtimecourses{i}(2) - info.eventtimecourses{i}(1));
end
end

