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
mt = cellfun(@(x) x*BurstData{file}.SyncPeriod,mt,'UniformOutput',false);

n_states = 2;
switch n_states
    case 2
        % minimize the negLogL
        fitfun = @(x) (-1)*GP_logL_burst(mt,ch,[x(1),x(2)],[x(3),x(4)]);

        % initial values
        % set rates to 1/100mus
        k0 = [1,1]*1E1;
        E0 = [0.2,0.8];
        lb = [0,0,0,0];
        ub = [1E5,1E5,1,1];
        fixE = false;
        if fixE
            lb(end-1:end) = E0;
            ub(end-1:end) = E0;   
        end
    case 3
        % minimize the negLogL
        fitfun = @(x) (-1)*GP_logL_burst(mt,ch,x(1:6),x(7:9));

        % initial values
        % set rates to 1/1ms
        k0 = [1,1,1,1,1,1]*1E2;
        E0 = [0.06,0.36,0.76];
        
        lb = zeros(1,numel(k0)+numel(E0));
        % maximum rate of 1/100µs
        ub = [1E4*ones(1,numel(k0)),ones(1,numel(E0))];
            
        fixE = true;
        if fixE
            lb(end-2:end) = E0;
            ub(end-2:end) = E0;   
        end
end


%opt = optimoptions('fmincon','Display','iter','StepTolerance',1E-6);
%fitres = fmincon(fitfun,[k0,E0],[],[],[],[],lb,ub,[],opt);
opt = optimset('Display','iter','PlotFcn',@optimplotfval);
fitres = fminsearchbnd(fitfun,[k0,E0],lb,ub,opt);
%opt = optimoptions('patternsearch','Display','iter','PlotFcn',@psplotbestf);
%fitres = patternsearch(fitfun,[k0,E0],[],[],[],[],lb,ub,[],opt);

fprintf('Rates: %.2f ms^(-1)\n', fitres(1:n_states*(n_states-1))/1000);
fprintf('FRET efficiencies: %.2f\n',fitres(n_states*(n_states-1)+1:end));

vit = false;
if vit
    i = 1;
    s = viterbi(mt{i},ch{i},fitres(1:n_states*(n_states-1)),fitres(n_states*(n_states-1)+1:end));
end

trans = false;
if trans & n_states == 2
    % compare logL of model with transition time over a range
    % logL of tp = 0
    logL0 = GP_logL_burst(mt,ch,fitres(1:2),fitres(3:4));
    tp = logspace(-6,-2,15); % from 1 to 100 µs
    kT = 1./(2*tp);
    logL = zeros(1,numel(kT));
    for i = 1:numel(kT)
        logL(i) = GP_logL_burst(mt,ch,fitres(1:2),fitres(3:4),kT(i));
    end
    figure;
    semilogx(tp,logL-logL0);
end