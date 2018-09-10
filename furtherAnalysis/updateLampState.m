function updateLampState(lamp,lamplabel,state)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
lamplabel.Text = state;
if strcmp(state, 'loading') 
    lamp.Color = 'red';
else
    lamp.Color = 'green';
end
end

