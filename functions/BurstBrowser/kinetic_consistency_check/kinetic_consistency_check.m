function kinetic_consistency_check(type)
global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;

%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
Macrotime = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
Microtime = BurstTCSPCData{file}.Microtime(BurstData{file}.Selected);
Channel = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);
%%% recolor channel photons based on kinetic scheme
R0 = BurstData{file}.Corrections.FoersterRadius;
n_states = 2;
switch n_states
    case 2
        rate_matrix = 1000*[0, 0.836; 0.932,0]; %%% rates in Hz %1000*[0,0.01;0.01,0];%
        %E_states = [0.2,0.8];
        R_states = [40,60];
        sigmaR_states = [0.1,0.1];
    case 3
        rate_matrix = 1000*[0, .5,0; .5,0,.25;0,.25,0]; %%% rates in Hz
        R_states = [40,55,80];
        sigmaR_states = [0.1,0.1,0.1];
end
%%% read out macrotimes of donor and FRET channels
switch BurstData{file}.BAMethod
    case {1,2}
        % channel : 1,2 Donor Par Perp
        %           3,4 FRET Par Perp
        %           5,6 ALEX Par Parp
        mt = cellfun(@(x,y) x(y < 5),Macrotime,Channel,'UniformOutput',false);                            
    case 5
        % channel : 1 Donor
        %           2 FRET
        %           3 ALEX
        mt = cellfun(@(x,y) x(y < 3),Macrotime,Channel,'UniformOutput',false);
end
%%% simulate kinetics
freq = 100*max(rate_matrix(:)); % set frequency for kinetic scheme evaluation to 100 times of fastest process
states = cell(numel(mt),1);
% convert macrotime to seconds and subtract first time point
mt_sec = cellfun(@(x) double(x-x(1))*BurstData{file}.ClockPeriod,mt,'UniformOutput',false);
dur = cell2mat(cellfun(@(x) x(end),mt_sec,'UniformOutput',false)); %duration
for i = 1:numel(mt) %%% loop over bursts
    %%% evaluate kinetic scheme
    states{i} = simulate_state_trajectory(rate_matrix,dur(i),freq);
end

% convert macrotime to units of freq
mt_freq = cellfun(@(x) floor(x*freq)+1,mt_sec,'UniformOutput',false);

gamma = BurstData{file}.Corrections.Gamma_GR;
ct = BurstData{file}.Corrections.CrossTalk_GR;
de = BurstData{file}.Corrections.DirectExcitation_GR;

%%% brightness correction
%
% Do this either by discarding photons of dimmer species a priori
%   (Note: This violates the photon statistics, as less photons are
%   used here.)
% Or by duplicating/removing photons under the assumption of Poissonian
% statistics.
%   (Note: This keeps photons roughly constant.)
brightness_correction = true;
discard = false;
if brightness_correction
    for i = 1:n_states
        Qr(i) = calc_relative_brightness(R_states(i),gamma,ct,de,R0);
    end
    if discard
        %%% normalize by maximum brightness
        Qr = Qr./max(Qr);
        detected = cellfun(@(x,y) binornd(1,Qr(x(min(y,end)))),states,mt_freq,'UniformOutput',false);
        mt_freq = cellfun(@(x,y) x(y==1),mt_freq,detected,'UniformOutput',false);
    else
        %%% normalize by medium brightness
        Qr = Qr./mean(Qr);
        % draw poisson distrubted random numbers for each photon
        detected = cellfun(@(x,y) poissrnd(Qr(x(min(y,end)))),states,mt_freq,'UniformOutput',false);
        %%% remove invalid 3photon detections from mt_freq, and duplicate those with detected > 1
        for i = 1:numel(mt_freq)
            mt_freq_resampled = mt_freq{i};
            mt_freq_resampled(detected{i} == 0) = [];
            for j = 2:max(detected{i})
                mt_freq_resampled = [mt_freq_resampled; mt_freq{i}(detected{i} == j)];
            end
            mt_freq{i} = sort(mt_freq_resampled);
        end
    end
end

switch type
    case 'BVA'
        %%% generate channel variable based on kinetic scheme       
        %%% assign channel based on states
        %%% without conformational broadening
        % channel = cellfun(@(x,y) binornd(1,E_states(x(min(y,end)))),states,mt_freq,'UniformOutput',false);
        %%% with conformational broadening
        % roll efficiencies of each state for every burst
        E_burst = cell(numel(mt_freq),1);
        gamma = BurstData{file}.Corrections.Gamma_GR;
        ct = BurstData{file}.Corrections.CrossTalk_GR;
        de = BurstData{file}.Corrections.DirectExcitation_GR;
        BG_Donor = 1000*dur*(BurstData{file}.Background.Background_GGpar + BurstData{file}.Background.Background_GGperp);
        BG_FRET = 1000*dur*(BurstData{file}.Background.Background_GRpar + BurstData{file}.Background.Background_GRperp);
        for b = 1:numel(mt_freq)
            E_burst{b} = 1./(1+(normrnd(R_states,sigmaR_states)/R0).^6);
            % convert to proximity ratio (see SI of ALEX paper) 
            %E_burst{b} = ((gamma-ct)*E_burst{b}+ct+de)./((gamma-ct-1).*E_burst{b}+ct+de+1);
            E_burst{b} = (gamma*E_burst{b}+ct*(1-E_burst{b})+de)./(gamma*E_burst{b}+ct*(1-E_burst{b})+de + (1-E_burst{b}));
            % with background
            E_burst{b} = ((numel(mt_freq{b})-BG_Donor(b)-BG_FRET(b)).*E_burst{b}+BG_FRET(b))./numel(mt_freq{b});
        end
        channel = cellfun(@(x,y,z) binornd(1,z(x(min(y,end)))),states,mt_freq,E_burst,'UniformOutput',false);

        % visualize
        % figure;area(states{i}-1,'FaceAlpha',0.15,'EdgeColor','none');hold on; scatter(mt_freq{i},0.5*ones(size(mt_freq{i})),20,colors(channel{i}+1,:));

        % compute resampled average FRET efficiencies
        E = cell2mat(cellfun(@(x) sum(x == 1)/numel(x),channel,'UniformOutput',false));
        % do BVA based on resampled channels
        n = 5;
        sPerBurst=zeros(size(channel));
        for i = 1:numel(channel)
            M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
            sPerBurst(i,1) = std(sum(M==1)/n); % FRET channel is 1
        end             
        % STD per Bin
        sSelected = sPerBurst;
        BinEdges = linspace(0,1,UserValues.BurstBrowser.Settings.NumberOfBins_BVA+1);
        [N,~,bin] = histcounts(E,BinEdges);
        BinCenters = BinEdges(1:end-1)+0.025;
        sPerBin = zeros(numel(BinEdges)-1,1);
        sampling = UserValues.BurstBrowser.Settings.ConfidenceSampling_BVA;
        PsdPerBin = zeros(numel(BinEdges)-1,sampling);
        for j = 1:numel(N) % 1 : number of bins
            burst_id = find(bin==j); % find indices of bursts in bin j
            if ~isempty(burst_id)
                BurstsPerBin = cell(size(burst_id'));
                for k = 1:numel(burst_id)
                    BurstsPerBin(k) = channel(burst_id(k)); % find all bursts in bin j
                end
                M = cellfun(@(x) reshape(x(1:fix(numel(x)/n)*n),n,[]),BurstsPerBin,'UniformOutput',false);
                MPerBin = cat(2,M{:});
                EPerBin = sum(MPerBin==1)/n;                        
                if numel(BurstsPerBin)>UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA
                    sPerBin(j,1) = std(EPerBin);
                end
            end
        end 
        %%% plot
        plot_BVA(E,sSelected,BinCenters,sPerBin)
    case 'Lifetime' % Do both E-tau and phasor
        %%% generate channel and microtime variable based on kinetic scheme
        %%% assign channel based on states
        %%% with conformational broadening
        % roll efficiencies of each state for every burst       
        R_burst = cell(numel(mt_freq),1); % center distance for every burst --> use for linker width inclusion
        E_burst = cell(numel(mt_freq),1);        
        %%% generate randomized average distance of each state for every
        %%% burst to account for conformational heterogeneity
        for b = 1:numel(mt_freq)
            R_burst{b} = normrnd(R_states,sigmaR_states);
        end
        %%% for the microtime of the donor, roll linker width at every evaluation
        lw = BurstData{file}.Corrections.LinkerLength; % 5 angstrom linker width
        tauD0 = BurstData{file}.Corrections.DonorLifetime; % donor only lifetime
        %%% generate randomized distance for every photon, accounting for linker width
        R_randomized = cellfun(@(x,y,z) normrnd(x(y(min(z,end))),lw),R_burst,states,mt_freq,'UniformOutput',false);
        %%% calculate randomized efficiency for every photon
        E_randomized = cellfun(@(x) 1./(1+(x/R0).^6),R_randomized,'UniformOutput',false);
        % convert idealized FRET efficiency to proximity ratio based on correction factors (see SI of ALEX paper)  
        E_randomized_PR = cellfun(@(E) (gamma*E+ct*(1-E)+de)./(gamma*E+ct*(1-E)+de + (1-E)), E_randomized,'UniformOutput',false);
        %%% roll photons based on randomized proximity ratio to only have donor photons
        channel = cellfun(@(x) binornd(1,x),E_randomized_PR,'UniformOutput',false);
        %%% discard acceptor photons
        E_randomized = cellfun(@(x,y) x(y==0),E_randomized,channel,'UniformOutput',false);
        %%% roll microtime based on E_randomized (use ideal FRET here!)
        mi = cellfun(@(x) exprnd(tauD0*(1-x)),E_randomized,'UniformOutput',false);
        % compute resampled average FRET efficiencies
        E = cell2mat(cellfun(@(x) sum(x == 1)/numel(x),channel,'UniformOutput',false));
        % convert back to accurate FRET efficiencies
        E_cor = (1-(1+ct+de)*(1-E))./(1-(1+ct-gamma).*(1-E));
        % averaged lifetime (intensity weighting is already considered due
        % to the FRET evaluation, i.e. discarding of photons based on FRET efficiency)
        tau_average = cellfun(@mean,mi)./tauD0;
        plot_E_tau(E_cor,tau_average);
        if isfield(BurstData{file},'Phasor')
            PIE_channel_width = BurstData{file}.TACRange*1E9*BurstData{file}.Phasor.PhasorRange(1)/BurstData{file}.FileInfo.MI_Bins;
            omega = 1/PIE_channel_width; % in ns^(-1)
            g = cell2mat(cellfun(@(x) sum(cos(2*pi*omega.*x))./numel(x),mi,'UniformOutput',false));
            s = cell2mat(cellfun(@(x) sum(sin(2*pi*omega.*x))./numel(x),mi,'UniformOutput',false));
            %%% project values
            neg=find(g<0 & s<0);
            g(neg)=-g(neg);
            s(neg)=-s(neg);
            plot_Phasor(g,s);
        end
end

%%% Calculate the relative brightness based on FRET value
function Qr = calc_relative_brightness(R,gamma,ct,de,R0)
E = 1/(1+(R/R0).^6);
Qr = (1-de)*(1-E) + (gamma/(1+ct))*(de+E*(1-de));