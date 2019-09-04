%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Does Burst Variance Analysis of Selected species %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Dynamic_Analysis(~,~)
global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;

Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating...');
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
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
Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating...');
switch UserValues.BurstBrowser.Settings.DynamicAnalysisMethod
    case 1 % BVA
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
        sSelected = sPerBurst.*BurstData{file}.Selected;
        sSelected(sSelected == 0) = NaN;
        E = E.*BurstData{file}.Selected;
        E(E == 0) = NaN;
        % STD per Bin
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
                if numel(BurstsPerBin)>UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA
                    sPerBin(j,1) = std(EPerBin);
                end
                if sampling ~=0
                    % simulate P(sigma)
                    idx = [0 cumsum(cellfun('size',M,2))];
                    window_id = zeros(size(EPerBin));
                    for l = 1:numel(M)
                         window_id(idx(l)+1:idx(l+1)) = ones(1,size(M{l},2))*burst_id(l);
                    end
                    for m = 1:sampling
                        EperBin_simu = binornd(n,E(window_id))/n;
                        PsdPerBin(j,m) = std(EperBin_simu);
                        Progress(((j-1)*sampling+m)/(numel(N)*sampling),h.Progress_Axes,h.Progress_Text,'Calculating Confidence Interval...');
                    end
                end
            end
        end
        Progress(100,h.Progress_Axes,h.Progress_Text,'Plotting...');
        % Plots
        hfig = figure('color',[1 1 1]);a=gca;a.FontSize=24;a.LineWidth=2;a.Color =[1 1 1];a.Box='on';
        hold on;
        X_expectedSD = linspace(0,1,1000);
        sigm = sqrt(X_expectedSD.*(1-X_expectedSD)./UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA);
        switch UserValues.BurstBrowser.Settings.BVA_X_axis
            case 1
                xlabel('Proximity Ratio, E*'); 
                ylabel('SD of E*, s');
                BinCenters = BinCenters';
                [H,x,y] = histcounts2(E,sSelected,UserValues.BurstBrowser.Display.NumberOfBinsX);
            case 2
                xlabel('FRET Efficiency'); 
                ylabel('SD of FRET, s');
                %%% conversion betweeen PR and E
                PRtoFRET = @(PR) (1-(1+BurstData{file}.Corrections.CrossTalk_GR+BurstData{file}.Corrections.DirectExcitation_GR).*(1-PR))./ ...
                   (1-(1+BurstData{file}.Corrections.CrossTalk_GR-BurstData{file}.Corrections.Gamma_GR).*(1-PR));

                BinCenters = PRtoFRET(BinCenters);
                X_expectedSD = PRtoFRET(X_expectedSD);
                E = PRtoFRET(E);
                [H,x,y] = histcounts2(E,sSelected,UserValues.BurstBrowser.Display.NumberOfBinsX); %H(H==0) = NaN;
        end
        
        switch UserValues.BurstBrowser.Display.PlotType
            case 'Contour'
            % contourplot of per-burst STD
                contourf(x(1:end-1),y(1:end-1),H','LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'EdgeColor','none');
                axis('xy')
                caxis([0 max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100]);
            case 'Image'       
                Alpha = H./max(max(H)) > UserValues.BurstBrowser.Display.ImageOffset/100;
                imagesc(x(1:end-1),y(1:end-1),H','AlphaData',Alpha');axis('xy');     
                %imagesc(x(1:end-1),y(1:end-1),H','AlphaData',isfinite(H));axis('xy');
                caxis([UserValues.BurstBrowser.Display.ImageOffset/100 max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100]);
            case 'Scatter'
                scatter(E,sSelected,'.','CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
            case 'Hex'
                hexscatter(E,sSelected,'xlim',[-0.1 1.1],'ylim',[0 max(sSelected)],'res',UserValues.BurstBrowser.Display.NumberOfBinsX);
        end        
        patch([min(E) max(E) max(E) min(E)],[0 0 max(sSelected) max(sSelected)],'w','FaceAlpha',0.5,'edgecolor','none','HandleVisibility','off');
        
        % Plot STD per Bin
        sPerBin(sPerBin == 0) = NaN;
        plot(BinCenters,sPerBin,'-d','MarkerSize',10,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            
        % plot of expected STD
        plot(X_expectedSD,sigm,'k','LineWidth',2);
        
        if sampling ~=0
            % Plot confidence intervals
            alpha = UserValues.BurstBrowser.Settings.ConfidenceLevelAlpha_BVA/numel(BinCenters)/100;
            confint = mean(PsdPerBin,2) + std(PsdPerBin,0,2)*norminv(1-alpha);
            % confint2 = prctile(PsdPerBin,100-UserValues.BurstBrowser.Settings.ConfidenceLevelAlpha_BVA/numel(BinCenters),2);
            p2 = area(BinCenters,confint);
            p2.FaceColor = [0.25 0.25 0.25];
            p2.FaceAlpha = 0.25;
            p2.LineStyle = 'none';
        end
       
        switch UserValues.BurstBrowser.Display.PlotType
            case {'Contour','Scatter'}
                if sampling ~= 0
                    legend('Burst SD','Binned SD','Expected SD','CI','Location','northeast')
                else
                    legend('Burst SD','Binned SD','Expected SD','Location','northeast')
                end
            case {'Image','Hex'}
                if sampling ~= 0
                    legend('Binned SD','Expected SD','CI','Location','northeast')
                else
                    legend('Binned SD','Expected SD','Location','northeast')
                end
                BVA_cbar = colorbar; ylabel(BVA_cbar,'Number of Bursts')
        end
        
        
        %%% Update ColorMap
        if ischar(UserValues.BurstBrowser.Display.ColorMap)
            if ~UserValues.BurstBrowser.Display.ColorMapFromWhite
                colormap(hfig,UserValues.BurstBrowser.Display.ColorMap);
            else
                if ~strcmp(UserValues.BurstBrowser.Display.ColorMap,'jet')
                    colormap(hfig,colormap_from_white(UserValues.BurstBrowser.Display.ColorMap));
                else %%% jet is a special case, use jetvar colormap
                    colormap(hfig,jetvar);
                end
            end
        else
            colormap(hfig,UserValues.BurstBrowser.Display.ColorMap);
        end
        
        %%% Combine the Original FileName and the parameter names
        if isfield(BurstData{file},'FileNameSPC')
            if strcmp(BurstData{file}.FileNameSPC,'_m1')
                FileName = BurstData{file}.FileNameSPC(1:end-3);
            else
                FileName = BurstData{file}.FileNameSPC;
            end
        else
            FileName = BurstData{file}.FileName(1:end-4);
        end
        
        if BurstData{file}.SelectedSpecies(1) ~= 0
            SpeciesName = ['_' BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),1}];
            if BurstData{file}.SelectedSpecies(2) > 1 %%% subspecies selected, append
                SpeciesName = [SpeciesName '_' BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)}];
            end
        else
            SpeciesName = '';
        end
        FigureName = [FileName SpeciesName '_BVA'];
        %%% remove spaces
        FigureName = strrep(strrep(FigureName,' ','_'),'/','-');
        hfig.CloseRequestFcn = {@ExportGraph_CloseFunction,1,FigureName};
        
        %%% add burst-wise standard deviation as additional parameter
        if ~isfield(BurstData{file},'AdditionalParameters')
            BurstData{file}.AdditionalParameters = [];
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVAStandardDeviation')
            BurstData{file}.AdditionalParameters.BVAStandardDeviation = NaN(size(BurstData{file}.DataArray,1),1);
            
        end
        BurstData{file}.AdditionalParameters.BVAStandardDeviation = sSelected;
        %%% Add parameters to list
        AddDerivedParameters([],[],h);
        set(h.ParameterListX, 'String', BurstData{file}.NameArray);
        set(h.ParameterListY, 'String', BurstData{file}.NameArray);
        UpdateCuts();
        UpdatePlot([],[],h);
    case {3} % FRET-2CDE vs E with conf int
        FRET_2CDE_confidence_intervals(UserValues.BurstBrowser.Settings.NumberOfBins_BVA,...
            UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA,...
            UserValues.BurstBrowser.Settings.ConfidenceSampling_BVA);
    case {2} % E vs Tau with conf int
        E_tau_confidence_intervals(UserValues.BurstBrowser.Settings.NumberOfBins_BVA,...
            UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA,...
            UserValues.BurstBrowser.Settings.ConfidenceSampling_BVA);
end
Progress(100,h.Progress_Axes,h.Progress_Text,'Done');