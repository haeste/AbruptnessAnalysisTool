function [Abruptness] = getAbruptness(signal,sf,parameters,Abruptness)
%getAbruptness Calculates the abruptness measure for the specified event.
%   Detailed explanation goes here

    fshigh = sf;
    order = 7;%order is typically higher for highpass
    disp(['Hihg pass: ' num2str(parameters.hpfreq)]);
    [b,a] = butter(order,parameters.hpfreq/(fshigh/2),'high');
    highpasssig = filtfilt(b,a,signal);
    windowsize = round(parameters.window * fshigh);
    averagedhp = zeros(round(length(highpasssig)/windowsize),1);
    index = 1;
    for i = 1+windowsize:windowsize:length(highpasssig)
        averagedhp(index) = mean(abs(highpasssig(i-windowsize:i)));
        index = index +1;
    end
    
    MUA = cummax(averagedhp);
    extendlength = sum(MUA==max(MUA));
    MUA = MUA';
    mua_y = [ones(1,extendlength).*min(MUA) MUA];
    mua_x = (1:length(mua_y));
    miny = min(mua_y);
    y = mua_y - miny;
    maxzeroedy = max(y);
    y = y./maxzeroedy;
    [mua_fit_params,got] = createlogisticFit1( mua_x,y);
    muaamptime = (-extendlength:length(MUA)-1).*parameters.window;
    Abruptness.MUA_fit = ((feval(mua_fit_params,mua_x)').*max(highpasssig));
    Abruptness.MUA_fit_time = muaamptime;
    Abruptness.MUA_logk = mua_fit_params.k;
    Abruptness.feats.Abruptness = log(mua_fit_params.k);
    Abruptness.feats.fit_error = got.rsquare;
    Abruptness.feats.maxMUA = max(averagedhp);
    Abruptness.feats.meanMUA = mean(averagedhp);
    Abruptness.mua = highpasssig;
    Abruptness.mua_y = mua_y;

end

