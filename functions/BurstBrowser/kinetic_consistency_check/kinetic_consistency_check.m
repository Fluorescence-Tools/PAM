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
n_states = 3;
switch n_states
    case 2
        rate_matrix = 1000*[0, 0.836; 0.932,0]; %%% rates in Hz
        %E_states = [0.2,0.8];
        R_states = [40,62];
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
            
switch type
    case 'BVA'
        %%% generate channel variable based on kinetic scheme
        % convert macrotime to units of freq
        mt_freq = cellfun(@(x) floor(x*freq)+1,mt_sec,'UniformOutput',false);
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
        % convert macrotime to units of freq
        mt_freq = cellfun(@(x) floor(x*freq)+1,mt_sec,'UniformOutput',false);
        %%% assign channel based on states
        %%% with conformational broadening
        % roll efficiencies of each state for every burst       
        R_burst = cell(numel(mt_freq),1); % center distance for every burst --> use for linker width inclusion
        E_burst = cell(numel(mt_freq),1);
        gamma = BurstData{file}.Corrections.Gamma_GR;
        ct = BurstData{file}.Corrections.CrossTalk_GR;
        de = BurstData{file}.Corrections.DirectExcitation_GR;
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
        % convert idealized to proximity ratio based on correction factors (see SI of ALEX paper)  
        E_randomized = cellfun(@(E) (gamma*E+ct*(1-E)+de)./(gamma*E+ct*(1-E)+de + (1-E)), E_randomized,'UniformOutput',false);
        %%% discard photons based on E_randomized to only have donor photons
        channel = cellfun(@(x) binornd(1,x),E_randomized,'UniformOutput',false);
        E_randomized = cellfun(@(x,y) x(y==0),E_randomized,channel,'UniformOutput',false);
        %%% roll microtime based on E_randomized
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

function plot_BVA(E,sSelected,BinCenters,sPerBin)
global UserValues
%%% create BVA plot
hfig = figure('color',[1 1 1]);a=gca;a.FontSize=14;a.LineWidth=1.0;a.Color =[1 1 1];
hold on;
X_expectedSD = linspace(0,1,1000);          
xlabel('Proximity Ratio, E*'); 
ylabel('SD of E*, s');
BinCenters = BinCenters';
sigm = sqrt(X_expectedSD.*(1-X_expectedSD)./UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA);

[H,x,y] = histcounts2(E,sSelected,UserValues.BurstBrowser.Display.NumberOfBinsX);

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
patch([-0.1 1.1 1.1 -0.1],[0 0 max(sSelected) max(sSelected)],'w','FaceAlpha',0.2,'edgecolor','none','HandleVisibility','off');

% plot of expected STD
plot(X_expectedSD,sigm,'k','LineWidth',1);

% Plot STD per Bin
sPerBin(sPerBin == 0) = NaN;
scatter(BinCenters,sPerBin,70,UserValues.BurstBrowser.Display.ColorLine1,'d','filled');

function plot_E_tau(E,tauD)
global UserValues BurstMeta BurstData
file = BurstMeta.SelectedFile;
h = guidata(findobj('Tag','BurstBrowser'));
%%% plot smoothed dynamic FRET line
[H,x,y] = histcounts2(E,tauD,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[0,1.2]);
H = H./max(H(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;
f = figure('Color',[1,1,1],'Position',[100,100,600,600]); hold on;
contourf(y(1:end-1),x(1:end-1),H,'LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'EdgeColor','none');
colormap(f,colormap(h.BurstBrowser));
ax = gca;
ax.CLimMode = 'auto';
ax.CLim(1) = 0;
ax.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;
% plot patch to phase contour plot out
%patch([0,1.2,1.2,0],[-0.1,-0.1,1.1,1.1],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none');
%%% add static FRET line
%plot(linspace(0,1,1000),1-linspace(0,1,1000),'-','LineWidth',2,'Color',[0,0,0]);
plot(BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData,'-','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
%plot(BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData,'--','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
ax.XLim = [0,1.2];
ax.YLim = [0,1];

xlabel('\tau_{D,A}/\tau_{D,0}');
ylabel('FRET Efficiency');
set(gca,'FontSize',24,'LineWidth',2,'Box','on','DataAspectRatio',[1,1,1],'XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');

function plot_Phasor(g,s)
global UserValues
h = guidata(findobj('Tag','BurstBrowser'));
%%% plot phasors
[H,x,y] = histcounts2(g,s,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[0,0.75]);
H = H./max(H(:));
f = figure('Color',[1,1,1],'Position',[100,100,600,600]); hold on;
contourf(x(1:end-1),y(1:end-1),H','LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'EdgeColor','none');
ax = gca;
ax.CLimMode = 'auto';
ax.CLim(1) = 0;
ax.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;
colormap(f,colormap(h.BurstBrowser));
%%% plot circle
g_circle = linspace(0,1,1000);
s_circle = sqrt(0.25-(g_circle-0.5).^2);
plot(g_circle,s_circle,'-','LineWidth',2,'Color',[0,0,0]);

ax.XLim = [-0.1,1.1];
ax.YLim = [0,0.75];
xlabel('g');
ylabel('s');
set(gca,'FontSize',24,'LineWidth',2,'Box','on','XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');
