function saveAnnotations(times,conditions,parameters,filename)
%saveAnnotations Saves the annotations, parameters, event times and conditions to a
%csv file for later analysis.
%   Detailed explanation goes here
for i_event = 1:length(times.trace)
    feats.starttime(i_event) = times.starttime(i_event);
    feats.endtime(i_event) = times.endtime(i_event);
    feats.condition{i_event} = conditions{i_event};
    feats.numtroughs(i_event) = length(times.troughsData{i_event}.trough_x);
    feats.trough_isi(i_event) = mean(diff(times.troughsData{i_event}.trough_x))*times.sf{i_event};
    
    trough_feats = {'trough_widths', 'trough_amp'};
    for i_f = 1:length(trough_feats)
          f = genvarname(['mean_' trough_feats{i_f}]);
          feats.(f)(i_event) = mean(times.troughsData{i_event}.(trough_feats{i_f}));
          f = genvarname(['max_' trough_feats{i_f}]);
          feats.(f)(i_event) = max(times.troughsData{i_event}.(trough_feats{i_f}));
          f = genvarname(['min_' trough_feats{i_f}]);
          feats.(f)(i_event) = min(times.troughsData{i_event}.(trough_feats{i_f}));
          f = genvarname(['std_' trough_feats{i_f}]);
          feats.(f)(i_event) = std(times.troughsData{i_event}.(trough_feats{i_f}));
          f = genvarname(['first_' trough_feats{i_f}]);
          feats.(f)(i_event) = times.troughsData{i_event}.(trough_feats{i_f})(1);
          f = genvarname(['final_' trough_feats{i_f}]);
          feats.(f)(i_event) = times.troughsData{i_event}.(trough_feats{i_f})(end);
          if length(times.troughsData{i_event}.(trough_feats{i_f})) > 1
              
              f = genvarname(['second_' trough_feats{i_f}]);
              feats.(f)(i_event) = times.troughsData{i_event}.(trough_feats{i_f})(2);
              
          else
              f = genvarname(['second_' trough_feats{i_f}]);
              feats.(f)(i_event) = NaN;
          end
          
    end
    
    abruptnessfeats = fieldnames(times.Abruptness{i_event}.feats);
    for i_f = 1:length(abruptnessfeats)
        f_name = abruptnessfeats{i_f};
        feats.(f_name)(i_event) = times.Abruptness{i_event}.feats.(f_name);
    end
    parameterfeats = fieldnames(parameters);
    for i_f = 1:length(parameterfeats)
        f_name = parameterfeats{i_f};
        feats.(f_name){i_event} = parameters.(f_name);
    end
    feats.coastline(i_event) = times.Coastline{i_event};
    feats.intermittancy(i_event) = times.Intermittancy{i_event};
    bandnames = fieldnames(times.PowerBands{i_event});
    for i = 1:length(bandnames)
        feats.(bandnames{i})(i_event) = times.PowerBands{i_event}.(bandnames{i});
    end
end
featnames = fieldnames(feats);
for fts = 1:numel(featnames)
    feats.(featnames{fts}) = feats.(featnames{fts})';
end
feature_table = struct2table(feats);

writetable(feature_table,filename, 'QuoteStrings',true)
    
end

