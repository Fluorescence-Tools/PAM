%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Slice Bursts in time bins for  PDA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [PDAdata, duration] = Bursts_to_Timebins(MT,CH,duration)
if duration == 0 % burstwise, simply return channel information
    PDAdata = CH;
    duration = cellfun(@(x) x(end)-x(1),MT);
    return;
end
%%% Get the maximum number of bins possible in data set
max_duration = double(ceil(max(cellfun(@(x) x(end)-x(1),MT))./duration));

%convert absolute macrotimes to relative macrotimes
bursts = cellfun(@(x) x-x(1)+1,MT,'UniformOutput',false);
bursts = cellfun(@double,bursts,'UniformOutput',false);
%bin the bursts according to dur, up to max_duration
bins = cellfun(@(x) histc(x,duration.*[0:1:max_duration]),bursts,'UniformOutput',false);

%remove last bin
last_bin = cellfun(@(x) find(x,1,'last'),bins,'UniformOutput',false);
for i = 1:numel(bins)
    bins{i}(last_bin{i}) = 0;
    %remove zero bins
    bins{i}(bins{i} == 0) = [];
end

%total number of bins is:
n_bins = sum(cellfun(@numel,bins));

%construct cumsum of bins
cumsum_bins = cellfun(@(x) [0; cumsum(x)],bins,'UniformOutput',false);

%get channel information --> This is the only relavant information for PDA!
PDAdata = cell(n_bins,1);
index = 1;
for i = 1:numel(CH)
    for j = 2:numel(cumsum_bins{i})
        PDAdata{index,1} = CH{i}(cumsum_bins{i}(j-1)+1:cumsum_bins{i}(j));
        index = index + 1;
    end
end