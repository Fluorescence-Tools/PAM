function FRET_2CDE_confidence_intervals(number_of_bins,minimum_burst_per_bin,sampling)
%%% Prepares a plot of FRET-2CDE filter vs. FRET efficiency,
%%% including bin-wise averaging with respect to the FRET efficiency.
%%% (Similar to the procedure outlined in the Burst Variance Analysis
%%% paper).
%%% Additionally, confidence intervals for the static FRET-2CDE line are
%%% estimated.
%%% Requires the raw photon time stamps to re-evaluate the static FRET-2CDE
%%% filter values.
%% get data
global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
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
threshold = minimum_burst_per_bin;
%% average lifetime in FRET efficiency bins
bin_number = number_of_bins; % bins for range 0-1
bin_edges = linspace(0,1,bin_number); bin_centers = bin_edges(1:end-1) + min(diff(bin_edges))/2;
[~,~,bin] = histcounts(E,bin_edges);
mean_FRET_2CDE = NaN(1,numel(bin_edges)-1);
mean_FRET_2CDE_naive = NaN(1,numel(bin_edges)-1);
for i = 1:numel(bin_edges)-1
    %%% compute bin-wise intensity-averaged FRET 2CDE
    if sum(bin == i) > threshold
        mean_FRET_2CDE(i) = 110 - 100*(sum(N_phot_D(bin==i).*E_D(bin==i))./sum(N_phot_D(bin==i)) +...
            sum(N_phot_A(bin==i).*E_A(bin==i))./sum(N_phot_A(bin==i)));        
        mean_FRET_2CDE_naive(i) = mean(FRET_2CDE(bin == i));
    end
end

%% confidence intervals
%  recolor photons based on average FRET efficiency of bursts and
%  re-calculate the FRET-2CDE filter
Progress(0,h.Progress_Axes,h.Progress_Text,'Estimating Confidence Intervals...');
% get KDE function from PAM
NirFilter_calculation = PAM('KDE');
FRET_2CDE_static = NaN(sampling,numel(bin_edges)-1);
number_of_bursts = numel(bin);
bursts_done = 0;
for i = 1:numel(bin_edges)-1
    if sum(bin == i) > threshold
        for s = 1:sampling
             E_bin = E(bin == i);
             mt_bin = photons_mt(bin == i);
             ch_bin = photons_ch(bin == i);
             N_phot_D_bin = N_phot_D(bin == i);
             N_phot_A_bin = N_phot_A(bin == i);
             E_D_static = NaN(numel(E_bin),1);
             E_A_static = NaN(numel(E_bin),1);
             for j = 1:numel(E_bin);
                 % read out number of photons after donor excitation Dx
                 switch BurstData{file}.BAMethod
                     case {1,2}
                         DX_photons = ch_bin{j} < 5;
                         N_DX = sum(DX_photons);
                         % randomize colors
                         chan_randomized = 1+2*binornd(1,PR(j),N_DX,1); % 1 = donor, 3 = acceptor (ignore polarization by making everything parrallel)
                         ch_bin{j}(DX_photons) = chan_randomized;
                     case {5}
                         DX_photons = ch_bin{j} < 3;
                         N_DX = sum(DX_photons);
                         % randomize colors
                         chan_randomized = 1+binornd(1,PR(j),N_DX,1); % 1 = donor, 2 = acceptor
                         ch_bin{j}(DX_photons) = chan_randomized;
                 end
                 %%% recalculate FRET_2CDE
                 [~,~,E_D_static(j),E_A_static(j)] = NirFilter_calculation(mt_bin{j}',ch_bin{j}',BurstData{file}.nir_filter_parameter*1E-6/BurstData{file}.ClockPeriod,BurstData{file}.BAMethod);
             end
             %%% average FRET-2CDE
             valid =  ~isnan(E_D_static) & ~isnan(E_A_static);
             FRET_2CDE_static(s,i) = 110 - 100*(sum(N_phot_D_bin(valid).*E_D_static(valid))./sum(N_phot_D_bin(valid)) +...
            sum(N_phot_A_bin(valid).*E_A_static(valid))./sum(N_phot_A_bin(valid)));        
        end
    end
    bursts_done = bursts_done + sum(bin==i);
    Progress(bursts_done/number_of_bursts,h.Progress_Axes,h.Progress_Text,'Estimating Confidence Intervals...');
end
static_line = nanmean(FRET_2CDE_static,1);
% get percentiles
alpha = 0.001;
upper_bound = mean(FRET_2CDE_static,1) + std(FRET_2CDE_static,0,1)*norminv(1-alpha/(numel(bin_edges)-1)/100);
%% plot smoothed dynamic FRET line
[H,x,y] = histcounts2(FRET_2CDE,E,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[0,75],'YBinLimits',[-0.1,1.1]);
H = H./max(H(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;
hfig = figure('Color',[1,1,1],'Position',[100,100,600,600]); hold on;
contourf(y(1:end-1),x(1:end-1),H,'LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'EdgeColor','none','HandleVisibility','off');
colormap(hfig,colormap(h.BurstBrowser));
ax = gca;
ax.CLimMode = 'auto';
ax.CLim(1) = 0;
ax.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;
ax.XLim = [-0.1,1.1];
ax.YLim = [0,75];

% plot patch to phase contour plot out
xlim = ax.XLim;
ylim = ax.YLim;
patch([xlim(1),xlim(2),xlim(2),xlim(1)],[ylim(1),ylim(1),ylim(2),ylim(2)],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none','HandleVisibility','off');

xlabel('FRET Efficiency');
ylabel('FRET 2CDE');
set(gca,'Color',[1,1,1],'FontSize',24,'LineWidth',2,'Box','on','XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');

%%% plot averaged FRET-2CDE
plot([-0.1,1.1]',[10,10]','Color',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'HandleVisibility','off');
plot(bin_centers,mean_FRET_2CDE,'-d','MarkerSize',10,'MarkerEdgeColor','none',...
    'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
if sampling ~= 0
    patch([min(bin_centers(isfinite(upper_bound))),bin_centers(isfinite(upper_bound)),max(bin_centers(isfinite(upper_bound)))],[0,upper_bound(isfinite(upper_bound)),0],0.25*[1,1,1],'FaceAlpha',0.25,'LineStyle','none');
end
scatter(bin_centers,static_line,100,'d','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2);
%scatter(bin_centers,mean_FRET_2CDE_naive,100,'^','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3);

switch UserValues.BurstBrowser.Display.PlotType
            case {'Contour','Scatter'}
                if sampling ~= 0
                    [~,icons] = legend('Binned FRET 2CDE','CI','Binned CI','Location','northeast');
                    icons(6).FaceAlpha = 0.25;
                    icons(7).Children.MarkerSize = 10;
                else
                    legend('Binned FRET 2CDE','Location','northeast')
                end
            case {'Image','Hex'}
                if sampling ~= 0
                    [~,icons] = legend('Binned FRET 2CDE','CI','Binned CI','Location','northeast');
                    icons(6).FaceAlpha = 0.25;
                    icons(7).Children.MarkerSize = 10;
                else
                    legend('Binned FRET 2CDE','Location','northeast')
                end
end
ax.Units = 'pixel';
ax.Position(4) = ax.Position(3);

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
FigureName = [FileName SpeciesName '_FRET-2CDE'];
%%% remove spaces
FigureName = strrep(strrep(FigureName,' ','_'),'/','-');
hfig.CloseRequestFcn = {@ExportGraph_CloseFunction,1,FigureName};
