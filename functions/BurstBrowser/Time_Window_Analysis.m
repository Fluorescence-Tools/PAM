%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Does Time Window Analysis of selected species %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Time_Window_Analysis(~,~)
global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));

file = BurstMeta.SelectedFile;

%%% query photon threshold
threshold = inputdlg({'Minimum number of photons'},'Set threshold',[1 45],{num2str(UserValues.BurstBrowser.Settings.TimeWindow_PhotonThreshold)},'on');
if isempty(threshold)
    return;
else
    threshold = str2double(threshold{1});
end
UserValues.BurstBrowser.Settings.TimeWindow_PhotonThreshold = threshold;

Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating Histograms...');
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating Histograms...');
%%% find selected bursts
MT = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
CH = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);

xProx = linspace(-0.1,1.1,UserValues.BurstBrowser.Display.NumberOfBinsX+1);
timebin = 1E-3*str2num(UserValues.BurstBrowser.Settings.TimeWindow_TimeBin); %{10E-3,5E-3,2E-3,1E-3,0.5E-3,0.25E-3};
Hist = cell(numel(timebin),1);
for t = 1:numel(timebin)
    %%% 1.) Bin BurstData according to time bin
    
    duration = timebin(t)/BurstData{file}.ClockPeriod;
    %%% Get the maximum number of bins possible in data set
    max_duration = double(ceil(max(cellfun(@(x) x(end)-x(1),MT))./duration));
    %convert absolute macrotimes to relative macrotimes
    bursts = cellfun(@(x) double(x-x(1)+1),MT,'UniformOutput',false);
    %bin the bursts according to dur, up to max_duration
    bins = cellfun(@(x) histc(x,duration.*[0:1:max_duration]),bursts,'UniformOutput',false);
    %remove last bin
    last_bin = cellfun(@(x) find(x,1,'last'),bins,'UniformOutput',false);
    for i = 1:numel(bins)
        bins{i}(last_bin{i}) = 0;
        %remove zero bins
        bins{i}(bins{i} == 0) = [];
    end
    %total number of bins is:
    n_bins = sum(cellfun(@numel,bins));
    %construct cumsum of bins
    cumsum_bins = cellfun(@(x) [0; cumsum(x)],bins,'UniformOutput',false);
    %get channel information --> This is the only relavant information for PDA!
    PDAdata = cell(n_bins,1);
    index = 1;
    for i = 1:numel(CH)
        for j = 2:numel(cumsum_bins{i})
            PDAdata{index,1} = CH{i}(cumsum_bins{i}(j-1)+1:cumsum_bins{i}(j));
            index = index + 1;
        end
    end
    
    %%% 2.) Calculate Proximity Ratio Histogram
    switch BurstData{file}.BAMethod
        case {1,2}
            NGP = cellfun(@(x) sum((x==1)),PDAdata);
            NGS = cellfun(@(x) sum((x==2)),PDAdata);
            NFP = cellfun(@(x) sum((x==3)),PDAdata);
            NFS = cellfun(@(x) sum((x==4)),PDAdata);
            NRP = cellfun(@(x) sum((x==5)),PDAdata);
            NRS = cellfun(@(x) sum((x==6)),PDAdata);
        case {3,4}
            NGP = cellfun(@(x) sum((x==7)),PDAdata);
            NGS = cellfun(@(x) sum((x==8)),PDAdata);
            NFP = cellfun(@(x) sum((x==9)),PDAdata);
            NFS = cellfun(@(x) sum((x==10)),PDAdata);
            NRP = cellfun(@(x) sum((x==11)),PDAdata);
            NRS = cellfun(@(x) sum((x==12)),PDAdata);
        case {5}
            NG = cellfun(@(x) sum((x==1)),PDAdata);
            NF = cellfun(@(x) sum((x==2)),PDAdata);
            NR = cellfun(@(x) sum((x==3)),PDAdata);
    end
    if ~(BurstData{file}.BAMethod == 5)
        NG = NGP + NGS;
        NF = NFP + NFS;
        NR = NRP + NRS;
    end
    valid = (NG+NF) > threshold;%(NG+NF+NR) > threshold;
    NG = NG(valid); NF = NF(valid); NR = NR(valid);
    NG = NG - timebin(t).*(BurstData{file}.Background.Background_GGpar+BurstData{file}.Background.Background_GGperp);
    NF = NF - timebin(t).*(BurstData{file}.Background.Background_GRpar+BurstData{file}.Background.Background_GRperp);
    NR = NR - timebin(t).*(BurstData{file}.Background.Background_RRpar+BurstData{file}.Background.Background_RRperp);
    NF = NF - BurstData{1, 1}.Corrections.CrossTalk_GR.*NG - BurstData{1, 1}.Corrections.DirectExcitation_GR.*NR;
    Prox = NF./(BurstData{1, 1}.Corrections.Gamma_GR.*NG+NF);
    
    Hist{t} = histcounts(Prox,xProx); Hist{t} = Hist{t}./sum(Hist{t});
    Progress(t/numel(timebin),h.Progress_Axes,h.Progress_Text,'Calculating Histograms...');
end


f1 = figure('Color',[1,1,1]);hold on;
a = 3;
for i = 1:numel(timebin)
    ha = stairs(xProx,[Hist{i},Hist{i}(end)]);
    set(ha, 'Linewidth', a)
    a = a-0.33;
end
ax = gca;
ax.Color = [1,1,1];
ax.LineWidth = 1.5;
ax.FontSize = 20;
xlabel('FRET efficiency');
ylabel('occurrence (norm.)');
xlim([-0.1,1.1]);
for i = 1:numel(timebin)
    leg{i} = [num2str(timebin(i)*1000) ' ms'];
end
legend(leg,'Box','off');

%%% also make image plot
Hist = flipud(vertcat(Hist{:}));
f2 = figure('Color',[1,1,1]);
f2.Position(1) = f1.Position(1) +  f1.Position(3);
im = imagesc(xProx,timebin*1000,Hist);
ax = gca;
ax.YDir = 'normal';
ax.FontSize = 20;
xlabel('FRET efficiency');
ylabel('time bin [ms]');
ax.YTick = 1:numel(timebin);
ax.YTickLabel = flipud(cellfun(@(x) num2str(x*1000),num2cell(timebin),'UniformOutput',false)');
Progress(1,h.Progress_Axes,h.Progress_Text);