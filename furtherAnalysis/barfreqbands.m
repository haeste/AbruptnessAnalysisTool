function barfreqbands(axes,bands)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

bandnames = fieldnames(bands);
bandvalues = zeros(length(bandnames),1);
for i = 1:length(bandnames)
    disp(bandnames{i})
    bandvalues(i) = bands.(bandnames{i});
end
bn = categorical(bandnames);
bn = reordercats(bn,bandnames);
bar(axes,bn,bandvalues);
hold(axes,'off')

end

