%% Code for calculating the burst correlation function from BurstData
global BurstTCSPCData BurstData BurstMeta
file = BurstMeta.SelectedFile;
Start = cellfun(@(x) x(1),BurstTCSPCData{file}.Macrotime);
Stop = cellfun(@(x) x(end),BurstTCSPCData{file}.Macrotime);
Start = round(Start.*BurstData{file}.SyncPeriod./1E-3);
Stop = round(Stop.*BurstData{file}.SyncPeriod./1E-3);
[Cor,Time] = CrossCorrelation({Start},{Stop},max(Stop));
figure;
subplot(2,1,1);
semilogx(Time*BurstData{file}.ClockPeriod,Cor);

%%% Calculate Same-Molecule Probability
p = 1-1./(Cor+1);
subplot(2,1,2);
semilogx(Time*BurstData{file}.ClockPeriod,p);

%% Find Bursts in Time Interval with respect to Initial FRET range
x = linspace(0,1,101);
E_ini = 0.3;
dE = 0.05;
val = (BurstData{file}.DataCut(:,1) > E_ini-dE) & (BurstData{file}.DataCut(:,1) < E_ini+dE);
hE_ini = histc(BurstData{file}.DataCut(val,1),x);

start = Start(BurstData{file}.Selected);
stop = Stop(BurstData{file}.Selected);
T = [0,10];
stp = stop(val);
val_idx = find(val);
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
hE_T = hE_T./sum(hE_T);
figure;plot(x,hE_ini);hold on;plot(x,hE_T);

%% Construct Recurrence Contour plot
T = [0, 10];

Eanf = 0; Eend= 1; dE = 0.02;
E = Eanf:dE:Eend;
contE = [];
for i = 1:numel(E)
    contE(:,i) = recurrence_hist(T,E(i),dE/2,Start,Stop);
end
    
figure;imagesc(E,E,flipud(contE));

%% Do a time series
Tanf = 0; Tend = 100; dT = 10;
T = Tanf:dT:Tend;
E_ini = 0.3; dE = 0.1;
% set an E threshold, i.e. E = 0.3, which is here bin 17
E_thr = 0.5;
[~,E_thr_bin] = min(abs(linspace(0,1,51)-E_thr));
contE = [];
fraction_low = [];
for i = 1:numel(T)
    rhE = recurrence_hist([T(i) T(i)+dT],E_ini,dE/2,Start,Stop);
    fraction_low(i) = sum(rhE(1:E_thr_bin))./sum(rhE);
    contE(:,i) = rhE;
end

% Correct p
eq_fraction_low = sum(BurstData{file}.DataCut(:,1) < E_thr)./numel(BurstData{file}.DataCut(:,1));
pA_same = p*1+ (1-p)*(1-eq_fraction_low); %Assume that pA(tau=0) = 1;
figure;plot(Time(1:find(Time>Tend,1,'first')),pA_same(1:find(Time>Tend,1,'first')));hold on;plot(T+dT/2,fraction_low)