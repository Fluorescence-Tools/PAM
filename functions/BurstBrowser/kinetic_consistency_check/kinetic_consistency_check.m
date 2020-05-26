function [E,sSelected,sPerBin,mi] = kinetic_consistency_check(type,n_states,rate_matrix,R_states,sigmaR_states,dynamic)
global BurstData BurstTCSPCData UserValues BurstMeta
%h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;
%%% recolor channel photons based on kinetic scheme
R0 = BurstData{file}.Corrections.FoersterRadius;
gamma = BurstData{file}.Corrections.Gamma_GR;
ct = BurstData{file}.Corrections.CrossTalk_GR;
de = BurstData{file}.Corrections.DirectExcitation_GR;
switch type
    case 'BVA'
        %%% Load associated .bps file, containing Macrotime, Microtime and Channel
        if isempty(BurstTCSPCData{file})
            Load_Photons();
        end
        Macrotime = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
        Microtime = BurstTCSPCData{file}.Microtime(BurstData{file}.Selected);
        Channel = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);
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
        %%% for BVA, we need to consider the actual photons, so simulate a
        %%% full trajectory
        freq = 100*max(rate_matrix(:)); % set frequency for kinetic scheme evaluation to 100 times of fastest process
        states = cell(numel(mt),1);
        % convert macrotime to seconds and subtract first time point
        mt_sec = cellfun(@(x) double(x-x(1))*BurstData{file}.ClockPeriod,mt,'UniformOutput',false);
        dur = cell2mat(cellfun(@(x) x(end),mt_sec,'UniformOutput',false)); %duration
        for i = 1:numel(mt) %%% loop over bursts
            %%% evaluate kinetic scheme
            states{i} = simulate_state_trajectory(rate_matrix,dur(i),freq,dynamic);
        end
        % convert macrotime to units of freq
        mt_freq = cellfun(@(x) floor(x*freq)+1,mt_sec,'UniformOutput',false);
        %%% brightness correction
        %
        % Do this either by discarding photons of dimmer species a priori
        %   (Note: This violates the photon statistics, as less photons are
        %   used here.)
        % Or by duplicating/removing photons under the assumption of Poissonian
        % statistics.
        %   (Note: This keeps photons roughly constant.)
        brightness_correction = true;
        discard = true;
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
        n = UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA;
        sPerBurst=zeros(size(channel));
        for i = 1:numel(channel)
            M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
            sPerBurst(i,1) = std(sum(M==1)/n); % FRET channel is 1
        end             
        % STD per Bin
        sSelected = sPerBurst;
        BinEdges = linspace(0,1,UserValues.BurstBrowser.Settings.NumberOfBins_BVA+1);
        [N,~,bin] = histcounts(E,BinEdges);
        %BinCenters = BinEdges(1:end-1)+0.025;
        sPerBin = zeros(numel(BinEdges)-1,1);
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
                if numel(BurstsPerBin)> UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA
                    sPerBin(j,1) = std(EPerBin);
                end
            end
        end 
    case 'Lifetime' % Do both E-tau and phasor
        if UserValues.BurstBrowser.Settings.Dynamic_Analysis_Method == 3
            do_phasor = true;
        else
            do_phasor = false;
        end
        %%% new code without state trajectory starts here
        %%% for lifetime, we only need to know the fraction of time spent
        %%% in each state
%         freq = 100*max(rate_matrix(:)); % set frequency for kinetic scheme evaluation to 100 times of fastest process
        %%% get duration
        dur = BurstData{file}.DataArray(BurstData{file}.Selected,find(strcmp('Duration [ms]',BurstData{file}.NameArray))); % duration in seconds
%         FracT = zeros(numel(dur),n_states);
%         states = cell(numel(dur),1);
%         for i = 1:numel(dur) %%% loop over bursts
%             %%% evaluate kinetic scheme
%             states{i} = simulate_state_trajectory(rate_matrix,dur(i)/1000,freq,dynamic);
%             %%% convert states to fraction of time spent in each state
%             for s = 1:n_states
%                 FracT(i,s) = sum(states{i} == s)./numel(states{i});
%             end
%         end
        rate_matrix(isnan(rate_matrix)) = 0;
        if n_states == 3
            change_prob = cumsum(rate_matrix);
            change_prob = change_prob ./ repmat(change_prob(end,:),3,1);
        end
        dwell_mean = 1 ./ sum(rate_matrix) * 1E3;
        for i = 1:n_states
                rate_matrix(i,i) = -sum(rate_matrix(:,i));
        end
        rate_matrix(end+1,:) = ones(1,n_states);
        b = zeros(n_states,1); b(end+1) = 1;
        p_eq = rate_matrix\b;
        if n_states == 3
            FracT = Gillespie_inf_states(dur,n_states,dwell_mean,numel(dur),p_eq,change_prob)./dur;
        else
            FracT = Gillespie_2states(dur,dwell_mean,numel(dur),p_eq)./dur;
        end
        %%% correct fractions for brightness differences of the different states
        for i = 1:n_states
            Q(i) = calc_relative_brightness(R_states(i),gamma,ct,de,R0);
        end
        FracInt = zeros(size(FracT));
        %%% calculate total brightness weighted by time spent, i.e.
        %%% Q1*T1+Q2*T2+Q3*T3...
        totalQ = sum(repmat(Q,[size(FracT,1),1]).*FracT,2);
        %%% weigh fraction by brightness
        for i = 1:n_states
            FracInt(:,i) = Q(i)*FracT(:,i)./totalQ;
        end 
        %%% get number of photons per burst after donor excitation
        N_phot = BurstData{file}.DataArray(BurstData{file}.Selected,find(strcmp('Number of Photons (DX)',BurstData{file}.NameArray)));
        %%% roll photons per state
        f_i = mnrnd(N_phot,FracInt);
        
        %%% generate channel and microtime variable based on kinetic scheme
        %%% assign channel based on states
        %%% with conformational broadening
        % roll efficiencies of each state for every burst       
        R_burst = normrnd(repmat(R_states,[numel(N_phot),1]),repmat(sigmaR_states,[numel(N_phot),1])); % center distance for every burst --> use for linker width inclusion    
        %%% for the microtime of the donor, roll linker width at every evaluation
        lw = BurstData{file}.Corrections.LinkerLength; % 5 angstrom linker width
        tauD0 = BurstData{file}.Corrections.DonorLifetime; % donor only lifetime
        %%% for every photon of every state, assign efficiency based on:
        %%% center distance R_burst(states)
        %%% linker width
        R_randomized = cell(numel(N_phot),1);
        E_randomized = cell(1,numel(N_phot));
        for i = 1:numel(N_phot)
            for s = 1:n_states
                R_randomized{i} = [R_randomized{i} normrnd(R_burst(i,s),lw,1,f_i(i,s))];
            end
            E_randomized{i} = 1./(1+(R_randomized{i}./R0).^6);
        end 
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
        % average lifetime in FRET efficiency bins
        %selected = BurstData{file}.Selected;
        %E = E(selected);
        %tauD0 = BurstData{file}.Corrections.DonorLifetime;
        %tauD = tauD(selected)./tauD0;
        threshold = UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA;
        bin_number = UserValues.BurstBrowser.Settings.NumberOfBins_BVA; % bins for range 0-1
        bin_edges = linspace(0,1,bin_number+1);
        [~,~,bin] = histcounts(E_cor,bin_edges);
        mean_tau = NaN(1,numel(bin_edges)-1);
        N_phot = N_phot';
        if do_phasor
            PIE_channel_width = BurstData{file}.TACRange*1E9*BurstData{file}.Phasor.PhasorRange(1)/BurstData{file}.FileInfo.MI_Bins;
            omega = 1/PIE_channel_width; % in ns^(-1)
            g = cell2mat(cellfun(@(x) sum(cos(2*pi*omega.*x))./numel(x),mi,'UniformOutput',false));
            s = cell2mat(cellfun(@(x) sum(sin(2*pi*omega.*x))./numel(x),mi,'UniformOutput',false));
            mean_g = NaN(1,numel(bin_edges)-1);
            mean_s = NaN(1,numel(bin_edges)-1);
        end
        for i = 1:numel(bin_edges)-1 
            %%% compute bin-wise intensity-averaged lifetime for donor
            if sum(bin == i) > threshold
                if do_phasor % calculate average phasor
                    g_bin = g(bin==i);
                    s_bin = s(bin==i);
                    valid = ~isnan(g_bin) & ~isnan(s_bin);
                    N_phot_D_bin = N_phot(bin==i);
                    mean_g(i) = sum(N_phot_D_bin(valid).*g_bin(valid))./sum(N_phot_D_bin(valid));
                    mean_s(i) = sum(N_phot_D_bin(valid).*s_bin(valid))./sum(N_phot_D_bin(valid));
                else
                    mean_tau(i) = sum(N_phot(bin==i).*tau_average(bin==i))./sum(N_phot(bin==i));
                end
            end
        end
        E = E_cor;
        if do_phasor
            sSelected = mean_g;
            sPerBin = mean_s;
        else
            sSelected = tau_average;
            sPerBin = mean_tau;
        end
%         plot_E_tau(E_cor,tau_average);
%         scatter(mean_tau,bin_centers,100,'diamond','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2);
%         if isfield(BurstData{file},'Phasor')
%             PIE_channel_width = BurstData{file}.TACRange*1E9*BurstData{file}.Phasor.PhasorRange(1)/BurstData{file}.FileInfo.MI_Bins;
%             omega = 1/PIE_channel_width; % in ns^(-1)
%             g = cell2mat(cellfun(@(x) sum(cos(2*pi*omega.*x))./numel(x),mi,'UniformOutput',false));
%             s = cell2mat(cellfun(@(x) sum(sin(2*pi*omega.*x))./numel(x),mi,'UniformOutput',false));
%             %%% project values
%             neg=find(g<0 & s<0);
%             g(neg)=-g(neg);
%             s(neg)=-s(neg);
%             figure(f2)
%             plot_Phasor(g,s);
%         end
        
        %% old - the following can be replaced by the new code
        old = false;
        if old
            %%% Load associated .bps file, containing Macrotime, Microtime and Channel
            if isempty(BurstTCSPCData{file})
                Load_Photons();
            end
            Macrotime = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
            Microtime = BurstTCSPCData{file}.Microtime(BurstData{file}.Selected);
            Channel = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);
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
            %%% for BVA, we need to consider the actual photons, so simulate a
            %%% full trajectory
            % convert macrotime to seconds and subtract first time point
            mt_sec = cellfun(@(x) double(x-x(1))*BurstData{file}.ClockPeriod,mt,'UniformOutput',false);
            % convert macrotime to units of freq
            mt_freq = cellfun(@(x) floor(x*freq)+1,mt_sec,'UniformOutput',false);
            %%% brightness correction
            %
            % Do this either by discarding photons of dimmer species a priori
            %   (Note: This violates the photon statistics, as less photons are
            %   used here.)
            % Or by duplicating/removing photons under the assumption of Poissonian
            % statistics.
            %   (Note: This keeps photons roughly constant.)
            brightness_correction = true;
            discard = true;
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
            %%% generate channel and microtime variable based on kinetic scheme
            %%% assign channel based on states
            %%% with conformational broadening
            % roll efficiencies of each state for every burst       
            R_burst = cell(numel(mt_freq),1); % center distance for every burst --> use for linker width inclusion    
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
            E_cor_old = (1-(1+ct+de)*(1-E))./(1-(1+ct-gamma).*(1-E));
            % averaged lifetime (intensity weighting is already considered due
            % to the FRET evaluation, i.e. discarding of photons based on FRET efficiency)
            tau_average_old = cellfun(@mean,mi)./tauD0;
        end
    case 'FRET_2CDE'
        selected = BurstData{file}.Selected;
        E = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
        PR = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'Proximity Ratio'));
        FRET_2CDE = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'FRET 2CDE Filter'));
        N_phot_D = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'));
        N_phot_A = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'));
        E_D = BurstData{file}.NirFilter.E_D(selected)';
        E_A = BurstData{file}.NirFilter.E_A(selected)';
        photons_mt = BurstTCSPCData{file}.Macrotime(selected);
        photons_ch = BurstTCSPCData{file}.Channel(selected);
        R0 = BurstData{file}.Corrections.FoersterRadius;
        gamma = BurstData{file}.Corrections.Gamma_GR;
        ct = BurstData{file}.Corrections.CrossTalk_GR;
        de = BurstData{file}.Corrections.DirectExcitation_GR;
%         N_phot_D = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'));
%         N_phot_A = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'));
        
%         switch BurstData{file}.BAMethod
%             case {1,2}
%                 % channel : 1,2 Donor Par Perp
%                 %           3,4 FRET Par Perp
%                 %           5,6 ALEX Par Parp
%                 mt = cellfun(@(x,y) x(y < 5),photons_mt,photons_ch,'UniformOutput',false);                            
%             case 5
%                 % channel : 1 Donor
%                 %           2 FRET
%                 %           3 ALEX
%                 mt = cellfun(@(x,y) x(y < 3),photons_mt,photons_ch,'UniformOutput',false);
%         end
        %%% simulate kinetics
        %%% for BVA, we need to consider the actual photons, so simulate a
        %%% full trajectory
        freq = 100*max(rate_matrix(:)); % set frequency for kinetic scheme evaluation to 100 times of fastest process
        %%% get duration
        % convert macrotime to seconds and subtract first time point
%         mt_sec = cellfun(@(x) double(x-x(1))*BurstData{file}.ClockPeriod,mt,'UniformOutput',false);
%         dur = cell2mat(cellfun(@(x) x(end),mt_sec,'UniformOutput',false)); %duration    
        dur = BurstData{file}.DataArray(BurstData{file}.Selected,find(strcmp('Duration [ms]',BurstData{file}.NameArray)))/1000; % duration in seconds
        FracT = zeros(numel(dur),n_states);
        states = cell(numel(dur),1);
        rate_matrix(isnan(rate_matrix)) = 0;
        for i = 1:numel(dur) %%% loop over bursts
            %%% evaluate kinetic scheme
            states{i} = simulate_state_trajectory(rate_matrix,dur(i),freq,dynamic);
            %%% convert states to fraction of time spent in each state
            for s = 1:n_states
                FracT(i,s) = sum(states{i} == s)./numel(states{i});
            end
        end
%         mt_freq = cellfun(@(x) floor(x*freq)+1,mt_sec,'UniformOutput',false);
        %%% correct fractions for brightness differences of the different states
        for i = 1:n_states
            Q(i) = calc_relative_brightness(R_states(i),gamma,ct,de,R0);
        end
        FracInt = zeros(size(FracT));
        %%% calculate total brightness weighted by time spent, i.e.
        %%% Q1*T1+Q2*T2+Q3*T3...
        totalQ = sum(repmat(Q,[size(FracT,1),1]).*FracT,2);
        %%% weigh fraction by brightness
        for i = 1:n_states
            FracInt(:,i) = Q(i)*FracT(:,i)./totalQ;
        end 
        %%% get number of photons per burst after donor excitation
        N_phot = BurstData{file}.DataArray(BurstData{file}.Selected,find(strcmp('Number of Photons (DX)',BurstData{file}.NameArray)));
        %%% roll photons per state
        f_i = mnrnd(N_phot,FracInt);
        %%% generate channel and microtime variable based on kinetic scheme
        %%% assign channel based on states
        %%% with conformational broadening
        % roll efficiencies of each state for every burst       
        R_burst = normrnd(repmat(R_states,[numel(N_phot),1]),repmat(sigmaR_states,[numel(N_phot),1])); % center distance for every burst --> use for linker width inclusion    
        %%% for the microtime of the donor, roll linker width at every evaluation
        lw = BurstData{file}.Corrections.LinkerLength; % 5 angstrom linker width
        %%% for every photon of every state, assign efficiency based on:
        %%% center distance R_burst(states)
        %%% linker width
        R_randomized = cell(numel(N_phot),1);
        E_randomized = cell(1,numel(N_phot));
        for i = 1:numel(N_phot)
            for s = 1:n_states
                R_randomized{i} = [R_randomized{i} normrnd(R_burst(i,s),lw,1,f_i(i,s))];
            end
            E_randomized{i} = 1./(1+(R_randomized{i}./R0).^6);
        end 
        % convert idealized FRET efficiency to proximity ratio based on correction factors (see SI of ALEX paper)  
        E_randomized_PR = cellfun(@(E) (gamma*E+ct*(1-E)+de)./(gamma*E+ct*(1-E)+de + (1-E)), E_randomized,'UniformOutput',false);
        %%% roll photons based on randomized proximity ratio to only have donor photons
        channel = cellfun(@(x) 1+2*binornd(1,x),E_randomized_PR,'UniformOutput',false);
%         DX_photons = cellfun(@(x) x<5,photons_ch,'UniformOutput',false);
        % compute resampled average FRET efficiencies
        E = cell2mat(cellfun(@(x) sum(x == 3)/numel(x),channel,'UniformOutput',false));
        
        % convert back to accurate FRET efficiencies
        E = (1-(1+ct+de)*(1-E))./(1-(1+ct-gamma).*(1-E));
        
        FRET_2CDE_sim = zeros(numel(channel),1);
        E_D_sim = zeros(numel(channel),1);
        E_A_sim = zeros(numel(channel),1);
        NirFilter_calculation = PAM('KDE');
        switch BurstData{file}.BAMethod
            case {1,2}
                for i = 1:numel(channel)
                    DX_photons = photons_ch{i} < 5;
                    chan_sim = 1+2*binornd(1,E_randomized_PR{i});
                    photons_ch{i}(DX_photons) = chan_sim;
                    [FRET_2CDE_sim(i),~,E_D_sim(i),E_A_sim(i)] = NirFilter_calculation(photons_mt{i}',photons_ch{i}',BurstData{file}.nir_filter_parameter*1E-6/BurstData{file}.ClockPeriod,BurstData{file}.BAMethod);
                end
            case 5
                for i = 1:numel(channel)
                    DX_photons = photons_ch{i} < 3;
                    chan_sim = 1+binornd(1,E_randomized_PR{i});
                    photons_ch{i}(DX_photons) = chan_sim;
                    [FRET_2CDE_sim(i),~,E_D_sim(i),E_A_sim(i)] = NirFilter_calculation(photons_mt{i}',photons_ch{i}',BurstData{file}.nir_filter_parameter*1E-6/BurstData{file}.ClockPeriod,BurstData{file}.BAMethod);
                end
        end
        bin_edges = linspace(0,1,UserValues.BurstBrowser.Settings.NumberOfBins_BVA+1);
        [~,~,bin] = histcounts(E,bin_edges);
%         bin_centers = bin_edges(1:end-1)+min(diff(bin_edges))/2;
%         bin_number = UserValues.BurstBrowser.Settings.NumberOfBins_BVA; % bins for range 0-1
%         bin_edges = linspace(0,1,bin_number);
%         [~,~,bin] = histcounts(E,bin_edges);
        FRET_2CDE_simbin = NaN(1,numel(bin_edges)-1);
%         number_of_bursts = numel(bin);
        bursts_done = 0;
        mean_FRET_2CDE_naive = NaN(1,numel(bin_edges)-1);
        for i = 1:numel(bin_edges)-1
            if sum(bin == i) > UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA
%                  E_bin = E(bin == i);
%                  mt_bin = photons_mt(bin == i);
%                  ch_bin = photons_ch(bin == i);
%                  N_phot_D_bin = N_phot_D(bin == i);
%                  N_phot_A_bin = N_phot_A(bin == i);
%                  E_D_simbin = E_D_sim(bin == i);
%                  E_A_simbin = E_A_sim(bin == i);
%                  for j = 1:numel(E_bin)
%                      % read out number of photons after donor excitation Dx
%                      switch BurstData{file}.BAMethod
%                          case {1,2}
%                              DX_photons = ch_bin{j} < 5;
%                              % randomize colors
%                              chan_randomized = 1+2*binornd(1,E_randomized_PR{i}); % 1 = donor, 3 = acceptor (ignore polarization by making everything parrallel)
%                              ch_bin{j}(DX_photons) = chan_randomized;
%                          case {5}
%                              DX_photons = ch_bin{j} < 3;
%                              % randomize colors
%                              chan_randomized = 1+binornd(1,E_randomized_PR{i}); % 1 = donor, 2 = acceptor
%                              ch_bin{j}(DX_photons) = chan_randomized;
%                      end
%                      %% recalculate FRET_2CDE
%                      [~,~,E_D_simbin(i),E_A_simbin(i)] = NirFilter_calculation(mt_bin{i}',ch_bin{i}',BurstData{file}.nir_filter_parameter*1E-6/BurstData{file}.ClockPeriod,BurstData{file}.BAMethod);
%                  end
%                  %% average FRET-2CDE
%                  valid =  ~isnan(E_D_simbin) & ~isnan(E_A_simbin);
%                  FRET_2CDE_simbin(i) = 110 - 100*(sum(N_phot_D_bin(valid).*E_D_simbin(valid))./sum(N_phot_D_bin(valid)) +...
%                  sum(N_phot_A_bin(valid).*E_A_simbin(valid))./sum(N_phot_A_bin(valid)));     
%              
%               FRET_2CDE_simbin(i) = 110 - 100*(sum(N_phot_D_bin.*E_D_simbin)./sum(N_phot_D_bin) +...
%                  sum(N_phot_A_bin.*E_A_simbin)./sum(N_phot_A_bin));
             
                mean_FRET_2CDE_naive(i) = nanmean(FRET_2CDE_sim(bin == i));
            end
            bursts_done = bursts_done + sum(bin==i);
        end
        sSelected = FRET_2CDE_sim;
        sPerBin = mean_FRET_2CDE_naive;
%         sPerBin = FRET_2CDE_simbin;
end


%%% Calculate the relative brightness based on FRET value
function Qr = calc_relative_brightness(R,gamma,ct,de,R0)
E = 1/(1+(R/R0).^6);
Qr = (1-de)*(1-E) + (gamma/(1+ct))*(de+E*(1-de));