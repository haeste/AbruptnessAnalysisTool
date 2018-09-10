function barfreqbands(axes,bands)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

bandnames = fieldnames(bands);
bandvalues = zeros(length(bandnames),1);
for i = 1:length(bandnames)
    bandvalues(i) = bands.(bandnames{i});
end
bar(axes,bandnames,bandvalues);

end

