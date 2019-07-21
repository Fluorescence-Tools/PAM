function [outv] = downsamplebin(invec,newbin)
%%% treat case where mod(numel/newbin) =/= 0
% if mod(numel(invec),newbin) ~= 0
%      %%% Discard the last bin
%     invec = invec(1:(floor(numel(invec)/newbin)*newbin));
% end
while mod(numel(invec),newbin) ~= 0
    invec(end+1) = 0;
end
outv = sum(reshape(invec,newbin,numel(invec)/newbin),1)';