global BurstData BurstTCSPCData BurstMeta
file = BurstMeta.SelectedFile;
mt = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
ch = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);

% convert channel to color and discard RR photons
for i = 1:numel(mt)
    % discard RR
    mt{i} = double(mt{i}(ch{i} < 5));
    ch{i} = double(ch{i}(ch{i} < 5));
    % convert channel to color (1->D; 2->A)
    ch{i} = ceil(ch{i}/2);
end

% minimize the negLogL
fitfun = @(x) (-1)*GP_logL_burst(mt,ch,[x(1),x(2)],[x(3),x(4)]);

% initial values
% set rates to 1/100mus
k0 = [1,2]*(BurstData{file}.SyncPeriod/1E-4);
E0 = [0.4,0.6];

opt = optimoptions('fmincon','Display','iter');
fitres = fmincon(fitfun,[k0,E0],[],[],[],[],[0,0,0,0],[Inf,Inf,1,1],[],opt);


fprintf('Rates: %.2f and %.2f ms^(-1)\n', fitres(1:2)./BurstData{file}.SyncPeriod/1000);
fprintf('FRET efficiencies: %.2f and %.2f\n',fitres(3:4));