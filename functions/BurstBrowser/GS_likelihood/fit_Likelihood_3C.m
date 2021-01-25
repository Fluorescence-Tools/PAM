%% load data
global BurstData BurstTCSPCData BurstMeta
burst = true;
if burst
    file = BurstMeta.SelectedFile;
    if isempty(BurstTCSPCData{file})
        Load_Photons();
    end
    mt = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
    ch = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);
    % convert channel to color and discard RR photons
    switch BurstData{file}.BAMethod
        case {3,4}
            RRix = 11;
        case 5 % noMFD
            RRix = 6;
    end
    for i = 1:numel(mt)
        % discard RR
        mt{i} = double(mt{i}(ch{i} < RRix));
        ch{i} = double(ch{i}(ch{i} < RRix));
        % convert channel to color (1->D; 2->A)
        if any(BurstData{file}.BAMethod == [3,4])
            ch{i} = ceil(ch{i}/2);
        end
    end
    mt = cellfun(@(x) x*BurstData{file}.SyncPeriod,mt,'UniformOutput',false);
    
    % extract GG and GR photons
    mt_2C = cellfun(@(x,y) x(y==4 | y==5),mt,ch,'UniformOutput',false);
    ch_2C = cellfun(@(x) x(x==4 | x==5)-3,ch,'UniformOutput',false);
    % extract BB, BG and BR photons
    mt_3C = cellfun(@(x,y) x(y==1 | y==2 | y == 3),mt,ch,'UniformOutput',false);
    ch_3C = cellfun(@(x) x(x==1 | x==2 | x == 3),ch,'UniformOutput',false);
else
    % simulated time trace
    mt = [Sim_Photons_1{1};Sim_Photons_1{2}];
    ch = [ones(size(Sim_Photons_1{1}));2*ones(size(Sim_Photons_1{2}))];
    [mt,ix] = sort(mt);
    ch = ch(ix);
    mt = {mt*1e-6};
    ch = {ch};
end
%% fitting
n_states = 2;
switch n_states
    case 2
        % minimize the negLogL
        fitfun = @(x) (-1)*GP_logL_3C_burst(mt_2C,ch_2C,mt_3C,ch_3C,x(1:2),x(3:4),x(5:8));

        % initial values
        % set rates to 1/100mus
        k0 = [0.1,0.1]*1E3;
        E0 = [0.1,0.5,... % 2color FRET efficiency
              0.1,0.4,... % acceptor fraction 1
              0.1,0.5];   % acceptor fraction 2
        lb = [0,0,0,0,0,0,0,0];
        ub = [1E6,1E6,1,1,1,1,1,1];
        fixE = false;
        if fixE
            lb(end-5:end) = E0;
            ub(end-5:end) = E0;   
        end
%     case 3
%         % minimize the negLogL
%         fitfun = @(x) (-1)*GP_logL_burst(mt,ch,x(1:6),x(7:9));
% 
%         % initial values
%         % set rates to 1/1ms
%         k0 = [1,1,1,1,1,1]*1E3;
%         E0 =  1./(1+([60,50,40]./50).^6);%[0.25,0.525,0.8];
%         
%         lb = zeros(1,numel(k0)+numel(E0));
%         % maximum rate of 1E6 Hz
%         ub = [1E6*ones(1,numel(k0)),ones(1,numel(E0))];
%             
%         fixE = true;
%         if fixE
%             lb(end-2:end) = E0;
%             ub(end-2:end) = E0;   
%         end
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
if trans && n_states == 2
    % compare logL of model with transition time over a range
    % logL of tp = 0
    logL0 = GP_logL_burst(mt,ch,fitres(1:2),fitres(3:4));
    tp = logspace(-6,-3,50); % from 1 to 1000 µs
    kT = 1./(2*tp);
    logL = zeros(1,numel(kT));
    for i = 1:numel(kT)
        logL(i) = GP_logL_burst(mt,ch,fitres(1:2),fitres(3:4),kT(i));
    end
    figure;
    semilogx(tp,logL-logL0);
    ax = gca;
    ax.YLim(1) = -100;
end