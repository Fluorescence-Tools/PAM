function [E,sSelected,sPerBin] = kinetic_consistency_check(type,n_states,rate_matrix,R_states,sigmaR_states)
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
            states{i} = simulate_state_trajectory(rate_matrix,dur(i),freq);
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
        %%% plot
        %plot_BVA(E,sSelected,BinCenters,sPerBin)
        if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
            E1 = 1/(1+(R_states(1,1)/R0)^6);
            E2 = 1./(1+(R_states(1,2)/R0)^6);
            hold on
            BVA_dynamic_FRET(E1,E2,n);
        end
    case 'Lifetime' % Do both E-tau and phasor               
        %% new code without state trajectory starts here
        %%% for lifetime, we only need to know the fraction of time spent
        %%% in each state
        freq = 100*max(rate_matrix(:)); % set frequency for kinetic scheme evaluation to 100 times of fastest process
        %%% get duration
        dur = BurstData{file}.DataArray(BurstData{file}.Selected,find(strcmp('Duration [ms]',BurstData{file}.NameArray)))/1000; % duration in seconds
        FracT = zeros(numel(dur),n_states);
        states = cell(numel(dur),1);
        for i = 1:numel(dur) %%% loop over bursts
            %%% evaluate kinetic scheme
            states{i} = simulate_state_trajectory(rate_matrix,dur(i),freq);
            %%% convert states to fraction of time spent in each state
            for s = 1:n_states
                FracT(i,s) = sum(states{i} == s)./numel(states{i});
            end
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
        bin_edges = linspace(0,1,bin_number); bin_centers = bin_edges(1:end-1) + min(diff(bin_edges))/2;
        [~,~,bin] = histcounts(E_cor,bin_edges);
        mean_tau = NaN(1,numel(bin_edges)-1);
        N_phot = N_phot';
        for i = 1:numel(bin_edges)-1
            %%% compute bin-wise intensity-averaged lifetime for donor
            if sum(bin == i) > threshold
                mean_tau(i) = sum(N_phot(bin==i).*tau_average(bin==i))./sum(N_phot(bin==i));
            end
        end
        E = E_cor;
        sSelected = tau_average;
        sPerBin = mean_tau;
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
%         
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
end

%%% Calculate the relative brightness based on FRET value
function Qr = calc_relative_brightness(R,gamma,ct,de,R0)
E = 1/(1+(R/R0).^6);
Qr = (1-de)*(1-E) + (gamma/(1+ct))*(de+E*(1-de));