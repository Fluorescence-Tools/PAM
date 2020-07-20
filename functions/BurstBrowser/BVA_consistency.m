function [E, E_sim,sSelected,sSelected_sim,H_real,x_real,y_real,sPerBin,...
    H_sim,x_sim,y_sim,sPerBin_sim,w_res_dyn,BinCenters] = ...
    BVA_consistency(rate_matrix, R_states, sigmaR_states,...
    rate_matrix_static, R_states_static, sigmaR_states_static)
        
global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;
if isempty(BurstData)
    msgbox('No data selected', 'Error','error');
    return
end
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData{file})
    Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photons...');
    Load_Photons();
end
min_bursts_per_bin = UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA;
Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % BVA Consistency
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        switch BurstData{file}.BAMethod
            case {1,2,5}
            E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio'));
            case 3
                switch UserValues.BurstBrowser.Settings.FRETpair_BVA
                    case 1
                        E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio BG (raw)'));
                    case 2
                        E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio BR (raw)'));
                    case 3
                        E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio BG (raw)'))+ ...
                            BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio BR (raw)'));
                    case 4
                        E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio GR (raw)'));
                end
        end
        photons = BurstTCSPCData{file};
        % Remove ALEX photons &  calculate STD per Burst
        n = UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA;
        switch BurstData{file}.BAMethod
            case {1,2}
                % channel : 1,2 Donor Par Perp
                %           3,4 FRET Par Perp
                %           5,6 ALEX Par Parp
                channel = cellfun(@(x) x(x < 5),photons.Channel,'UniformOutput',false);
                sPerBurst=zeros(size(channel));
                for i = 1:numel(channel)
                    M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
                    sPerBurst(i,1) = std(sum(M==3|M==4)/n); % observed standard deviation of E for each burst
                end

            case 3
                % channel : 1,2   Donor blue Par Perp
                %           3,4   FRET blue/green Par Perp
                %           5,6   FRET blue/red Par Perp
                %           7,8   Donor/ALEX green Par Perp
                %           9,10  FRET green/red Par Perp
                %           11,12 ALEX red Par Perp
                switch UserValues.BurstBrowser.Settings.FRETpair_BVA % observed standard deviation of E for each burst
                    case 1
                        channel = cellfun(@(x) x(x<5),photons.Channel,'UniformOutput',false);
                        sPerBurst=zeros(size(channel));
                        for i = 1:numel(channel)
                            M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
                            sPerBurst(i,1) = std(sum(M==3|M==4)/n);
                        end
                    case 2
                        channel = cellfun(@(x) x(x>0 & x<3 | x>4 & x<7),photons.Channel,'UniformOutput',false);
                        sPerBurst=zeros(size(channel));
                        for i = 1:numel(channel)
                            M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
                            sPerBurst(i,1) = std(sum(M==5|M==6)/n);
                        end
                    case 3
                        channel = cellfun(@(x) x(x<7),photons.Channel,'UniformOutput',false);
                        sPerBurst=zeros(size(channel));
                        for i = 1:numel(channel)
                            M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
                            sPerBurst(i,1) = std(sum(M==3|M==4|M==5|M==6)/n);
                        end
                    case 4
                        channel = cellfun(@(x) x(x>6 & x<9 | x>8 & x<11),photons.Channel,'UniformOutput',false);
                        sPerBurst=zeros(size(channel));
                        for i = 1:numel(channel)
                            M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
                            sPerBurst(i,1) = std(sum(M==9|M==10)/n);
                        end
                end
            case 5
                % channel : 1 Donor
                %           2 FRET
                %           3 ALEX
                channel = cellfun(@(x) x(x < 3),photons.Channel,'UniformOutput',false);
                sPerBurst=zeros(size(channel));
                for i = 1:numel(channel)
                    M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % Create photon windows
                    sPerBurst(i,1) = std(sum(M==2)/n); % observed standard deviation of E for each burst
                end
        end
        Progress(0.25,h.Progress_Axes,h.Progress_Text,'Calculating...');
        sSelected = sPerBurst.*BurstData{file}.Selected;
        sSelected(sSelected == 0) = NaN;
        E = E.*BurstData{file}.Selected;
        E(E == 0) = NaN;
        %% STD per Bin
        BinEdges = linspace(0,1,UserValues.BurstBrowser.Settings.NumberOfBins_BVA+1);
        [N,~,bin] = histcounts(E,BinEdges);
        BinCenters = BinEdges(1:end-1)+min(diff(BinEdges))/2;
        sPerBin = zeros(numel(BinEdges)-1,1);
%         sampling = UserValues.BurstBrowser.Settings.ConfidenceSampling_BVA;
        %PsdPerBin = zeros(numel(BinEdges)-1,sampling);
        for j = 1:numel(N) % 1 : number of bins
            burst_id = find(bin==j); % find indices of bursts in bin j
            if ~isempty(burst_id)
                BurstsPerBin = cell(size(burst_id'));
                for k = 1:numel(burst_id)
                    BurstsPerBin(k) = channel(burst_id(k)); % find all bursts in bin j
                end
                M = cellfun(@(x) reshape(x(1:fix(numel(x)/n)*n),n,[]),BurstsPerBin,'UniformOutput',false);
                MPerBin = cat(2,M{:});
                switch BurstData{file}.BAMethod
                    case {1,2}
                        EPerBin = sum(MPerBin==3|MPerBin==4)/n;
                    case 3
                        switch UserValues.BurstBrowser.Settings.FRETpair_BVA
                            case 1
                                EPerBin = sum(MPerBin==3|MPerBin==4)/n;
                            case 2
                                EPerBin = sum(MPerBin==5|MPerBin==6)/n;
                            case 3
                                EPerBin = sum(MPerBin==3|MPerBin==4|MPerBin==5|MPerBin==6)/n;
                            case 4
                                EPerBin = sum(MPerBin==9|MPerBin==10)/n;
                        end
                    case 5
                        EPerBin = sum(MPerBin==2)/n;
                end
                if numel(BurstsPerBin)>min_bursts_per_bin
                    sPerBin(j,1) = std(EPerBin);
                end
%                 if sampling ~=0
%                     %% Monte Carlo Simulation P(sigma)
%                     idx = [0 cumsum(cellfun('size',M,2))];
%                     window_id = zeros(size(EPerBin));
%                     %alpha = UserValues.BurstBrowser.Settings.ConfidenceLevelAlpha_BVA/numel(BinCenters)/100;
%                     for l = 1:numel(M)
%                          window_id(idx(l)+1:idx(l+1)) = ones(1,size(M{l},2))*burst_id(l);
%                     end
%                     for m = 1:sampling
%                         EperBin_simu = binornd(n,E(window_id))/n;
%                         PsdPerBin(j,m) = std(EperBin_simu);
%                         Progress(((j-1)*sampling+m)/(numel(N)*sampling),h.Progress_Axes,h.Progress_Text,'Calculating Confidence Interval...');
%                     end
%                 end
            end
        end
        %% Simulate BVA plot based on PDA model
        if UserValues.BurstBrowser.Settings.BVA_ModelComparison
            % simulate dynamic and static models separately
            Progress(0.25,h.Progress_Axes,h.Progress_Text,'Simulating dynamic Model...');
            [E_sim,sSelected_sim,sPerBin_sim] = kinetic_consistency_check('BVA',UserValues.BurstBrowser.Settings.BVA_DynamicStates...
                ,rate_matrix,R_states,sigmaR_states,1);
            
            Progress(0.5,h.Progress_Axes,h.Progress_Text,'Simulating static Model...');
        else
            % simulate dynamic and static species at in one model
            Progress(0.25,h.Progress_Axes,h.Progress_Text,'Simulating all species...');
            [E_sim,sSelected_sim,sPerBin_sim] = ...
                kinetic_consistency_check_2models('BVA',UserValues.BurstBrowser.Settings.BVA_DynamicStates,...
                UserValues.BurstBrowser.Settings.BVA_StaticStates,...
                rate_matrix,R_states,sigmaR_states,...
                rate_matrix_static,R_states_static,sigmaR_states_static);
        end
        %% Generate plots
        sPerBin(sPerBin == 0) = NaN;
        sPerBin_sim(sPerBin_sim == 0) = NaN;
        
        % data for contour patches
        [H_real,x_real,y_real] = histcounts2(E,sSelected,UserValues.BurstBrowser.Display.NumberOfBinsX); 
        [H_sim,x_sim,y_sim] = histcounts2(E_sim,sSelected_sim,UserValues.BurstBrowser.Display.NumberOfBinsX);
        
        %% Calculate sum squared residuals (dynamic)
        w_res_dyn = (sPerBin-sPerBin_sim);
        w_res_dyn(isnan(w_res_dyn)) = 0;