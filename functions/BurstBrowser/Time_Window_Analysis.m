%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Does Time Window Analysis of selected species %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Time_Window_Analysis(~,~)
global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));

file = BurstMeta.SelectedFile;

%%% query photon threshold
threshold = inputdlg({'Minimum number of photons'},'Set threshold',[1 45],{'50'},'on');
if isempty(threshold)
    return;
else
    threshold = str2double(threshold{1});
end
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

xProx = linspace(-0.1,1.1,61);
timebin = {10E-3,5E-3,2E-3,1E-3,0.5E-3,0.25E-3};
for t = 1:numel(timebin)
    %%% 1.) Bin BurstData according to time bin
    
    duration = timebin{t}/BurstData{file}.ClockPeriod;
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
    valid = (NG+NF) > threshold; NG = NG(valid); NF = NF(valid); NR = NR(valid);
    NG = NG - timebin{t}.*(BurstData{file}.Background.Background_GGpar+BurstData{file}.Background.Background_GGperp);
    NF = NF - timebin{t}.*(BurstData{file}.Background.Background_GRpar+BurstData{file}.Background.Background_GRperp);
    NR = NR - timebin{t}.*(BurstData{file}.Background.Background_RRpar+BurstData{file}.Background.Background_RRperp);
    NF = NF - BurstData{file}.Corrections.CrossTalk_GR.*NG - BurstData{file}.Corrections.DirectExcitation_GR.*NR;
    Prox = NF./(BurstData{file}.Corrections.Gamma_GR.*NG+NF);
    
    Hist{t} = histcounts(Prox,xProx); Hist{t} = Hist{t}./sum(Hist{t});
    
    if any(BurstData{file}.BAMethod == [3,4])
        %%% also calculate E_B->G+R
        NBB = cellfun(@(x) sum((x==1)),PDAdata)+ cellfun(@(x) sum((x==2)),PDAdata);
        NBG = cellfun(@(x) sum((x==3)),PDAdata) + cellfun(@(x) sum((x==4)),PDAdata);
        NBR = cellfun(@(x) sum((x==5)),PDAdata) + cellfun(@(x) sum((x==6)),PDAdata);
        NGG = NGP + NGS; % require the raw photons in GG,GR,RR again
        NGR = NFP + NFS;
        NRR = NRP + NRS;
        valid = (NBB+NBG+NBR) > threshold; 
        NBB= NBB(valid); NBG = NBG(valid); NBR = NBR(valid); NGG = NGG(valid); NGR = NGR(valid); NRR = NRR(valid);
        NBB = NBB - timebin{t}.*(BurstData{file}.Background.Background_BBpar+BurstData{file}.Background.Background_BBperp);
        NBG = NBG - timebin{t}.*(BurstData{file}.Background.Background_BGpar+BurstData{file}.Background.Background_BGperp);
        NBR = NBR - timebin{t}.*(BurstData{file}.Background.Background_BRpar+BurstData{file}.Background.Background_BRperp);
        NBG = NBG - BurstData{file}.Corrections.DirectExcitation_BG.*NGG - BurstData{file}.Corrections.CrossTalk_BG.*NBB;
        NBR = NBR - BurstData{file}.Corrections.DirectExcitation_BR.*NRR - BurstData{file}.Corrections.CrossTalk_BR.*NBB -...
            BurstData{file}.Corrections.CrossTalk_GR.*(NBG-BurstData{file}.Corrections.CrossTalk_BG.*NBB) -...
            BurstData{file}.Corrections.DirectExcitation_BG*(NGR-BurstData{file}.Corrections.DirectExcitation_GR.*NRR-BurstData{file}.Corrections.CrossTalk_GR.*NGG);
        Prox3c = (NBG+NBR)./(NBB+NBG+NBR);
        Hist3c{t} = histcounts(Prox3c,xProx); Hist3c{t} = Hist3c{t}./sum(Hist3c{t});
    end    
    Progress(t/numel(timebin),h.Progress_Axes,h.Progress_Text,'Calculating Histograms...');
end


f1 = figure('Color',[1,1,1]);hold on;
f1.Position(1) = 50;
f1.Position(2) = 50;
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
    leg{i} = [num2str(timebin{i}*1000) ' ms'];
end
legend(leg,'Box','off');

%%% also make image plot
Hist = flipud(vertcat(Hist{1:6}));
f2 = figure('Color',[1,1,1]);
f2.Position(1) = f1.Position(1) +  f1.Position(3);
f2.Position(1) = f1.Position(2);
im = imagesc(xProx,fliplr(horzcat(timebin{1:6}))*1000,Hist);
ax = gca;
ax.YDir = 'normal';
ax.FontSize = 20;
xlabel('FRET efficiency');
ylabel('time bin [ms]');
ax.YTickLabel = flipud(cellfun(@(x) num2str(x*1000),timebin,'UniformOutput',false)');
Progress(1,h.Progress_Axes,h.Progress_Text);

if any(BurstData{file}.BAMethod == [3,4])
    pos = get(f1,'Position'); pos(1) = pos(1)+pos(3);
    f1_3c = figure('Color',[1,1,1],'Position',pos);hold on;
    a = 3;
    for i = 1:numel(timebin)
        ha = stairs(xProx,[Hist3c{i},Hist3c{i}(end)]);
        set(ha, 'Linewidth', a)
        a = a-0.33;
    end
    ax = gca;
    ax.Color = [1,1,1];
    ax.LineWidth = 1.5;
    ax.FontSize = 20;
    xlabel('FRET efficiency B->G+R');
    ylabel('occurrence (norm.)');
    xlim([-0.1,1.1]);
    for i = 1:numel(timebin)
        leg{i} = [num2str(timebin{i}*1000) ' ms'];
    end
    legend(leg,'Box','off');

    %%% also make image plot
    Hist3c = flipud(vertcat(Hist3c{1:6}));
    f2_3c = figure('Color',[1,1,1]);
    f2_3c.Position(1) = f1.Position(1) + f1_3c.Position(3);
    im = imagesc(xProx,fliplr(horzcat(timebin{1:6}))*1000,Hist3c);
    ax = gca;
    ax.YDir = 'normal';
    ax.FontSize = 20;
    xlabel('FRET efficiency B->G+R');
    ylabel('time bin [ms]');
    ax.YTickLabel = flipud(cellfun(@(x) num2str(x*1000),timebin,'UniformOutput',false)');
    Progress(1,h.Progress_Axes,h.Progress_Text);
end