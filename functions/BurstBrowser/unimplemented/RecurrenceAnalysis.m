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
plot(Time,Cor);
xlim([0,50]);
%%% Calculate Same-Molecule Probability
p = 1-1./(Cor+1);
subplot(2,1,2);
plot(Time,p);
xlim([0,50]);
ylim([0,1]);
%% Find Bursts in Time Interval with respect to Initial FRET range
x = linspace(0,1,51);
E_ini = 0.4;
dE = 0.1;
val = (BurstData{file}.DataCut(:,1) > E_ini-dE) & (BurstData{file}.DataCut(:,1) < E_ini+dE);
hE_ini = histc(BurstData{file}.DataCut(val,1),x);
T = [10,50];

hE = recurrence_hist(T,E_ini,dE/2,Start,Stop);

figure;plot(x,hE_ini./sum(hE_ini));hold on;plot(x,hE./sum(hE));

%% Construct Recurrence Contour plot
T = [5, 15];

Eanf = 0; Eend= 1; dE = 0.05;
E = Eanf:dE:Eend;
contE = [];
for i = 1:numel(E)
    contE(:,i) = recurrence_hist(T,E(i),dE/2,Start,Stop);
end
    
figure;imagesc(E,linspace(0,1,51),flipud(contE));

%% Do a time series
Tanf = 0; Tend = 100; dT = 10;
T = Tanf:dT:Tend;
E_ini = 0.4; dE = 0.1;
% set an E threshold, i.e. E = 0.3, which is here bin 17
E_thr = 0.65;
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