function Abruptness = getTroughAbruptness(trough_x, trough_y,Abruptness)
%getTroughAbruptness Calculates an abruptness measure based on the trough
%depth. 
%   Does this by fitting a logistic function to a the troughs.
y = abs(trough_y);
y = y - min(y);
y = y./max(y);
[~,maxyind] = max(trough_y);
extension = zeros(1,length(trough_y-maxyind));
y = [extension y];
ISI = mean(diff(trough_x));
xextension = -ISI*length(extension):ISI:-ISI;
trough_x = [xextension trough_x];
[fit_params,got] = createlogisticFit1( trough_x,y);
Abruptness.trough_fit = -((feval(fit_params,trough_x)').*max(abs(trough_y)));
Abruptness.trough_x = trough_x;
Abruptness.trough_y = y;
Abruptness.trough_logk = fit_params.k;
Abruptness.feats.Abruptness_trough = log(fit_params.k);
Abruptness.feats.fit_error_trough = got.rsquare;
end

