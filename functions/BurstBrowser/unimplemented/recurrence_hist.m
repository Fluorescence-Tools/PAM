function [hE] = recurrence_hist(T,E_ini,dE,Start,Stop)
global BurstData BurstMeta
file = BurstMeta.SelectedFile;
x = linspace(0,1,51);
val = (BurstData{file}.DataCut(:,1) > E_ini-dE) & (BurstData{file}.DataCut(:,1) < E_ini+dE);
hE_ini = histc(BurstData{file}.DataCut(val,1),x);

start = Start(BurstData{file}.Selected);
stop = Stop(BurstData{file}.Selected);

stp = stop(val);
val_idx = find(val);
if isempty(val_idx)
    hE = zeros(numel(x),1);
    return;
end
rec = zeros(numel(Stop),1);
n = zeros(numel(stp),1);
if val_idx(end) == numel(start) %% Catch case where burst is last of measurement
    stp(end) = [];
    val_idx(end) = [];
end

for i = 1:numel(stp)
    while (start(val_idx(i)+1)-stp(i) >= T(1)) && (stop(val_idx(i)+1)-stp(i) <= T(2))
        rec(val_idx(i)+1) = 1;
        val_idx(i) = val_idx(i) + 1;
        n(i) = n(i)+1;
        if val_idx(i) + 1 > numel(start)
            break;
        end
    end
end
rec = logical(rec);
%dT1 = repmat(Start,1,numel(stp)) - repmat(stp',numel(Start),1);
%dT2 = repmat(Stop,1,numel(stp)) - repmat(stp',numel(Stop),1);
%rec = sum((dT1 > T(1)) & (dT2 < T(2)),2) > 0;

hE_T = histc(BurstData{file}.DataCut(rec,1),x);

hE_ini = hE_ini./sum(hE_ini);
hE = hE_T;

hE(isnan(hE)) = 0;