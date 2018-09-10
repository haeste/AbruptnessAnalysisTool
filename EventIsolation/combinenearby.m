function [ seizuretimes ] = combinenearby( seizuretimes, mindistance, minseizurelength )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

seizurescombined = false;
while(not(seizurescombined))
    seizurescombined = true; % if we get through the loop with no changes then we can break the loop
    i = 1;
    while i <= length(seizuretimes(1,:))-1
        finish = seizuretimes(2,i);
        start = seizuretimes(1,i+1);
        if start-finish < mindistance
            seizuretimes(2,i) = seizuretimes(2,i+1);
            seizuretimes(:,i+1) = [];
            seizurescombined = false;
            
        end
            i = i + 1;
        
        
    end

i = 1;
while i <= length(seizuretimes(1,:))
    if seizuretimes(2,i) - seizuretimes(1,i) < minseizurelength
        %disp(['Removing seizure at : ' num2str(seizuretimes(1,i)) ' - ' num2str(seizuretimes(2,i))]);
        seizuretimes(:,i) = [];
    elseif seizuretimes(1,i) == 0 || seizuretimes(2,i) == 0 
        %disp(['Removing seizure at : ' num2str(seizuretimes(1,i)) ' - ' num2str(seizuretimes(2,i))]);
        seizuretimes(:,i) = [];
    else
        i = i+1;
    end
end
end
n = 1;
while n <= length(seizuretimes(1,:))
    if int64(round(seizuretimes(1,n))) == 0 || int64(round(seizuretimes(2,n))) == 0 
        seizuretimes(:,n) = [];
    else
        n = n+1;
    end
end


% i = 1;
% while i < length(seizuretimes(1,:))
%     seizuretimes(2,i) -seizuretimes(1,i)
%     if seizuretimes(2,i) -seizuretimes(1,i) < minseizurelength
%         seizuretimes(:,i) = []
%     end
%     i = i + 1;
% end