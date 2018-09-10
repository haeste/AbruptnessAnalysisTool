function [decaytime,fitting_error,current_fit] = makeTroughExpFit(troughsds,sd)
%makeTroughExpFit Fit the seizure trough to an exponential function to get
%the rate of transition out of the trough
%   

% bring the whole signal below zero so that the exponential function
% will fit
troughsdsbelowzero = troughsds - max(troughsds);
troughdstime = (1:length(troughsdsbelowzero))./sd;
try
    [curr_fit_params,got] = createFit(troughdstime,troughsdsbelowzero);
catch
    
    decaytime =[];
    fitting_error = [];
    current_fit = [];
end

decaytime = 1/abs(curr_fit_params.b);
fitting_error = got.rsquare;
current_fit = feval(curr_fit_params, troughdstime)';



end


