function [ seizuretimes ] = seizuretimesfromlogindices( indices,times )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
seizureon = 0;
seizuretimes = [];
for i = 2:length(indices)-1
    if indices(i) && not(seizureon) 
        
        seizureon = 1;
        seizuretimes = [seizuretimes [times(i-1);0]];
    end
    if seizureon && not(indices(i))
        seizureon = 0;
        seizuretimes(2,end) = times(i-1);
    end
    
end

