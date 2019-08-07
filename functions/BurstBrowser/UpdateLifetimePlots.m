%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Plots in Left Lifetime Tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateLifetimePlots(obj,~,h)
global BurstData BurstMeta UserValues
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end

if isempty(BurstData)
    return;
end

file = BurstMeta.SelectedFile;
NameArray = BurstData{file}.NameArray;
%%% Use the current cut Data (of the selected species) for plots
if ~h.MultiselectOnCheckbox.UserData
    datatoplot = BurstData{file}.DataCut;
else
    %%% get average dye only lifetimes from selected files
    sel_files = get_multiselection(h);
    DonorLifetime = 0;
    AcceptorLifetime = 0;
    for i = 1:numel(sel_files)
        DonorLifetime = max([DonorLifetime, BurstData{sel_files(i)}.Corrections.DonorLifetime]);
        AcceptorLifetime = max([AcceptorLifetime, BurstData{sel_files(i)}.Corrections.AcceptorLifetime]);
    end
    if any(BurstData{file}.BAMethod == [3,4])
        DonorLifetimeBlue = 0;
        for i = 1:numel(sel_files)
            DonorLifetimeBlue = max([DonorLifetimeBlue, BurstData{sel_files(i)}.Corrections.DonorLifetimeBlue]);
        end
    end
end
%%% read out the indices of the parameters to plot
switch BurstData{file}.BAMethod
    case {1,2,5} %2color
        idx_tauGG = strcmp('Lifetime D [ns]',NameArray);
        idx_tauRR = strcmp('Lifetime A [ns]',NameArray);
        idx_rGG = strcmp('Anisotropy D',NameArray);
        idx_rRR = strcmp('Anisotropy A',NameArray);
        switch UserValues.BurstBrowser.Settings.LifetimeMode
            case 1
                idxE = find(strcmp(NameArray,'FRET Efficiency'));
            case 2
                idxE = find(strcmp(NameArray,'log(FD/FA)'));            
            case 3
                idxE = find(strcmp(NameArray,'M1-M2'));
                idx_tauGG = strcmp('FRET Efficiency',NameArray);
        end
    case {3,4}
        idx_tauGG = strcmp('Lifetime GG [ns]',NameArray);
        idx_tauRR = strcmp('Lifetime RR [ns]',NameArray);
        idx_rGG = strcmp('Anisotropy GG',NameArray);
        idx_rRR = strcmp('Anisotropy RR',NameArray);
        
        switch UserValues.BurstBrowser.Settings.LifetimeMode
            case 1
                idxE = find(strcmp(NameArray,'FRET Efficiency GR'));
            case 2
                idxE = find(strcmp(NameArray,'log(FGG/FGR)'));            
            case 3
                idxE = find(strcmp(NameArray,'M1-M2 GR'));
                idx_tauGG = strcmp('FRET Efficiency GR',NameArray);
        end
end
%%% Read out the Number of Bins
nbinsX = UserValues.BurstBrowser.Display.NumberOfBinsX;
nbinsY = UserValues.BurstBrowser.Display.NumberOfBinsY;
%% Plot E vs. tauGG in first plot
switch UserValues.BurstBrowser.Settings.LifetimeMode
    case 1
        YLim = [-0.1 1.1];
    case 2
        if ~h.MultiselectOnCheckbox.UserData
            YLim = [min(datatoplot(:,idxE)) max(datatoplot(:,idxE))];
        else
            YLim = [];
        end
    case 3
        if ~h.MultiselectOnCheckbox.UserData
            YLim = [min(datatoplot(:,idxE)) max(datatoplot(:,idxE))];
        else
            YLim = [];
        end
        maxX = 1;
end
if ~h.MultiselectOnCheckbox.UserData
    if UserValues.BurstBrowser.Settings.LifetimeMode ~= 3
        maxX = min([max(datatoplot(:,idx_tauGG)) BurstData{file}.Corrections.DonorLifetime+1.5]);
    end
    [H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauGG), datatoplot(:,idxE),[nbinsX nbinsY], [0 maxX], YLim);
    datapoints = [datatoplot(:,idx_tauGG), datatoplot(:,idxE)];
else
    if UserValues.BurstBrowser.Settings.LifetimeMode ~= 3
        maxX = BurstData{file}.Corrections.DonorLifetime+1.5;
    end
    [H,xbins,ybins,~,~,datapoints,n_per_species,H_ind] = MultiPlot([],[],h,NameArray{idx_tauGG},NameArray{idxE},{[0 maxX], YLim});
    YLim = [ybins(1) ybins(end)];
end
if(get(h.Hist_log10, 'Value'))
    H = log10(H);
    if UserValues.BurstBrowser.Display.KDE
        H = real(H);
    end
end
H = H/max(max(H));
BurstMeta.Plots.EvsTauGG(1).XData = xbins;
BurstMeta.Plots.EvsTauGG(1).YData = ybins;
BurstMeta.Plots.EvsTauGG(1).CData = H;
if ~UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.EvsTauGG(1).AlphaData = H./max(max(H)) > UserValues.BurstBrowser.Display.ImageOffset/100;
elseif UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.EvsTauGG(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
end
BurstMeta.Plots.EvsTauGG(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
BurstMeta.Plots.EvsTauGG(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
% replicate to fix edges
Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
BurstMeta.Plots.EvsTauGG(2).ZData = Hcontour;
BurstMeta.Plots.EvsTauGG(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
    if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1
        color = [];
        for i = 1:numel(n_per_species)
            color = [color; i*ones(n_per_species(i),1)];
        end
        colors = lines(numel(n_per_species));
        colordata = colors(color,:);
        %%% permute data points randomly to avoid hiding populations below another
        perm = randperm(size(colordata,1));
        colordata = colordata(perm,:);
        datapoints = datapoints(perm,:);
    else
        colordata = UserValues.BurstBrowser.Display.MarkerColor;
    end
    BurstMeta.Plots.EvsTauGG(3).XData = datapoints(:,1);
    BurstMeta.Plots.EvsTauGG(3).YData = datapoints(:,2);
    BurstMeta.Plots.EvsTauGG(3).CData = colordata;
end
% clear patches
if numel(h.axes_EvsTauGG.Children) > 8
    delete(h.axes_EvsTauGG.Children(1:end-8));
end
if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') & (numel(get_multiselection(h)) > 1) && UserValues.BurstBrowser.Display.Multiplot_Contour
    BurstMeta.Plots.EvsTauGG(2).Visible = 'off';
    axes(h.axes_EvsTauGG);
    % overlay contour plots
    colors = lines(numel(H));
    ContourPatches = [];
    H = H_ind;
    for i = 1:numel(H)
        %level_list = max(H{i}(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,UserValues.BurstBrowser.Display.PlotCutoff/100,UserValues.BurstBrowser.Display.NumberOfContourLevels);
        [C,contour_plot] = contour(xbins,ybins,H{i},UserValues.BurstBrowser.Display.NumberOfContourLevels,'LineColor','none');
        switch UserValues.BurstBrowser.Display.ContourFill
            case 0
                alpha = 0;
            case 1
                alpha = 2/(UserValues.BurstBrowser.Display.NumberOfContourLevels);
        end
        level = 1;
        while level < size(C,2)
            n_vertices = C(2,level);
            if UserValues.BurstBrowser.Display.PlotContourLines
                ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),colors(i,:),'FaceAlpha',alpha,'EdgeColor',colors(i,:));
            else
                ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),colors(i,:),'FaceAlpha',alpha,'EdgeColor','none');
            end
            level = level + n_vertices +1;
        end
        delete(contour_plot);
    end
elseif strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') & (numel(get_multiselection(h)) == 1)
    BurstMeta.Plots.EvsTauGG(2).Visible = 'on';
end
            
%%% update hex plot if selected
if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
    delete(BurstMeta.HexPlot.EvsTauGG);
    %%% make hexplot
    axes(h.axes_EvsTauGG);
    BurstMeta.HexPlot.EvsTauGG = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',[0 maxX],'ylim',[-0.1 1.1],'res',nbinsX);
end
try h.axes_EvsTauGG.XLim=[0,maxX]; end
if ~isempty(YLim)
    ylim(h.axes_EvsTauGG,YLim);
else
    ylim(h.axes_EvsTauGG,'auto');
end

h.axes_EvsTauGG.CLimMode = 'auto';
h.axes_EvsTauGG.CLim(1) = 0;
try;h.axes_EvsTauGG.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;end;
if strcmp(BurstMeta.Plots.Fits.staticFRET_EvsTauGG.Visible,'on')
    %%% replot the static FRET line
    UpdateLifetimeFits(h.PlotStaticFRETButton,[]);
end
%% Plot E vs. tauRR in second plot
if ~h.MultiselectOnCheckbox.UserData
    maxX = min([max(datatoplot(:,idx_tauRR)) BurstData{file}.Corrections.AcceptorLifetime+2]);
    [H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauRR), datatoplot(:,idxE),[nbinsX nbinsY], [0 maxX], YLim);
    datapoints = [datatoplot(:,idx_tauRR), datatoplot(:,idxE)];
else
    maxX = BurstData{file}.Corrections.AcceptorLifetime+2;
    [H,xbins,ybins,~,~,datapoints,n_per_species,H_ind] = MultiPlot([],[],h,NameArray{idx_tauRR},NameArray{idxE},{[0 maxX], YLim});
end
if(get(h.Hist_log10, 'Value'))
    H = log10(H);
    if UserValues.BurstBrowser.Display.KDE
        H = real(H);
    end
end
H = H/max(max(H));
BurstMeta.Plots.EvsTauRR(1).XData = xbins;
BurstMeta.Plots.EvsTauRR(1).YData = ybins;
BurstMeta.Plots.EvsTauRR(1).CData = H;
if ~UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.EvsTauRR(1).AlphaData = H./max(max(H)) > UserValues.BurstBrowser.Display.ImageOffset/100;
elseif UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.EvsTauRR(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
end
BurstMeta.Plots.EvsTauRR(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
BurstMeta.Plots.EvsTauRR(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
% replicate to fix edges
Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
BurstMeta.Plots.EvsTauRR(2).ZData = Hcontour;
BurstMeta.Plots.EvsTauRR(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
    if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1
        color = [];
        for i = 1:numel(n_per_species)
            color = [color; i*ones(n_per_species(i),1)];
        end
        colors = lines(numel(n_per_species));
        colordata = colors(color,:);
        %%% permute data points randomly to avoid hiding populations below another
        perm = randperm(size(colordata,1));
        colordata = colordata(perm,:);
        datapoints = datapoints(perm,:);
    else
        colordata = UserValues.BurstBrowser.Display.MarkerColor;
    end
    BurstMeta.Plots.EvsTauRR(3).XData = datapoints(:,1);
    BurstMeta.Plots.EvsTauRR(3).YData = datapoints(:,2);
    BurstMeta.Plots.EvsTauRR(3).CData = colordata;
end
% clear patches
if numel(h.axes_EvsTauRR.Children) > 8
    delete(h.axes_EvsTauRR.Children(1:end-3));
end
if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') & (numel(get_multiselection(h)) > 1) && UserValues.BurstBrowser.Display.Multiplot_Contour
    BurstMeta.Plots.EvsTauRR(2).Visible = 'off';
    axes(h.axes_EvsTauRR);
    % overlay contour plots
    colors = lines(numel(H));
    ContourPatches = [];
    H = H_ind;
    for i = 1:numel(H)
        %level_list = max(H{i}(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,UserValues.BurstBrowser.Display.PlotCutoff/100,UserValues.BurstBrowser.Display.NumberOfContourLevels);
        [C,contour_plot] = contour(xbins,ybins,H{i},UserValues.BurstBrowser.Display.NumberOfContourLevels,'LineColor','none');
        switch UserValues.BurstBrowser.Display.ContourFill
            case 0
                alpha = 0;
            case 1
                alpha = 2/(UserValues.BurstBrowser.Display.NumberOfContourLevels);
        end
        level = 1;
        while level < size(C,2)
            n_vertices = C(2,level);
            if UserValues.BurstBrowser.Display.PlotContourLines
                ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),colors(i,:),'FaceAlpha',alpha,'EdgeColor',colors(i,:));
            else
                ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),colors(i,:),'FaceAlpha',alpha,'EdgeColor','none');
            end
            level = level + n_vertices +1;
        end
        delete(contour_plot);
    end
elseif strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') & (numel(get_multiselection(h)) == 1)
    BurstMeta.Plots.EvsTauRR(2).Visible = 'on';
end
%%% update hex plot if selected
if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
    delete(BurstMeta.HexPlot.EvsTauRR);
    %%% make hexplot
    axes(h.axes_EvsTauRR);
    BurstMeta.HexPlot.EvsTauRR = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',[0 maxX],'ylim',[-0.1 1.1],'res',nbinsX);
end
try h.axes_EvsTauRR.XLim=[0,maxX]; end
if ~isempty(YLim)
    ylim(h.axes_EvsTauRR,YLim);
else
    ylim(h.axes_EvsTauRR,'auto');
end
h.axes_EvsTauRR.CLimMode = 'auto';
h.axes_EvsTauRR.CLim(1) = 0;
try;h.axes_EvsTauRR.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;end;
if BurstData{file}.BAMethod ~= 5 %ensure that polarized detection was used
    %% Plot rGG vs. tauGG in third plot
    if ~h.MultiselectOnCheckbox.UserData
        maxX = min([max(datatoplot(:,idx_tauGG)) BurstData{file}.Corrections.DonorLifetime+1.5]);
        [H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauGG), datatoplot(:,idx_rGG),[nbinsX nbinsY], [0 maxX], [-0.1 0.5]);
        datapoints = [datatoplot(:,idx_tauGG), datatoplot(:,idx_rGG)];
    else
        maxX = BurstData{file}.Corrections.DonorLifetime+1.5;
        [H,xbins,ybins,~,~,datapoints,n_per_species, H_ind] = MultiPlot([],[],h,NameArray{idx_tauGG},NameArray{idx_rGG},{[0 maxX], [-0.1 0.5]});
    end
    if(get(h.Hist_log10, 'Value'))
        H = log10(H);
        if UserValues.BurstBrowser.Display.KDE
            H = real(H);
        end
    end
    H = H/max(max(H));
    BurstMeta.Plots.rGGvsTauGG(1).XData = xbins;
    BurstMeta.Plots.rGGvsTauGG(1).YData = ybins;
    BurstMeta.Plots.rGGvsTauGG(1).CData = H;
    if ~UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rGGvsTauGG(1).AlphaData = H./max(max(H)) > UserValues.BurstBrowser.Display.ImageOffset/100;
    elseif UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rGGvsTauGG(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
    end
    BurstMeta.Plots.rGGvsTauGG(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
    BurstMeta.Plots.rGGvsTauGG(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
    Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
    % replicate to fix edges
    Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
    Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
    BurstMeta.Plots.rGGvsTauGG(2).ZData = Hcontour;
    BurstMeta.Plots.rGGvsTauGG(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
        if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1
            color = [];
            for i = 1:numel(n_per_species)
                color = [color; i*ones(n_per_species(i),1)];
            end
            colors = lines(numel(n_per_species));
            colordata = colors(color,:);
            %%% permute data points randomly to avoid hiding populations below another
            perm = randperm(size(colordata,1));
            colordata = colordata(perm,:);
            datapoints = datapoints(perm,:);
        else
            colordata = UserValues.BurstBrowser.Display.MarkerColor;
        end
        BurstMeta.Plots.rGGvsTauGG(3).XData = datapoints(:,1);
        BurstMeta.Plots.rGGvsTauGG(3).YData = datapoints(:,2);
        BurstMeta.Plots.rGGvsTauGG(3).CData = colordata;
    end
    % clear patches
    if numel(h.axes_rGGvsTauGG.Children) > 8
        delete(h.axes_rGGvsTauGG.Children(1:end-8));
    end
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') && (numel(get_multiselection(h)) > 1) && UserValues.BurstBrowser.Display.Multiplot_Contour
        BurstMeta.Plots.rGGvsTauGG(2).Visible = 'off';
        axes(h.axes_rGGvsTauGG);
        % overlay contour plots
        colors = lines(numel(H));
        ContourPatches = [];
        H = H_ind;
        for i = 1:numel(H)
            %level_list = max(H{i}(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,UserValues.BurstBrowser.Display.PlotCutoff/100,UserValues.BurstBrowser.Display.NumberOfContourLevels);
            [C,contour_plot] = contour(xbins,ybins,H{i},UserValues.BurstBrowser.Display.NumberOfContourLevels,'LineColor','none');
            switch UserValues.BurstBrowser.Display.ContourFill
                case 0
                    alpha = 0;
                case 1
                    alpha = 2/(UserValues.BurstBrowser.Display.NumberOfContourLevels);
            end
            level = 1;
            while level < size(C,2)
                n_vertices = C(2,level);
                if UserValues.BurstBrowser.Display.PlotContourLines
                    ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),colors(i,:),'FaceAlpha',alpha,'EdgeColor',colors(i,:));
                else
                    ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),colors(i,:),'FaceAlpha',alpha,'EdgeColor','none');
                end
                level = level + n_vertices +1;
            end
            delete(contour_plot);
        end
    elseif strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') & (numel(get_multiselection(h)) == 1)
        BurstMeta.Plots.rGGvsTauGG(2).Visible = 'on';
    end
    %%% update hex plot if selected
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
        delete(BurstMeta.HexPlot.rGGvsTauGG);
        %%% make hexplot
        axes(h.axes_rGGvsTauGG);
        BurstMeta.HexPlot.rGGvsTauGG = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',[0 maxX],'ylim',[-0.1 0.5],'res',nbinsX);
    end
    try h.axes_rGGvsTauGG.XLim=[0,maxX]; end
    ylim(h.axes_rGGvsTauGG,[-0.1 0.5]);
    h.axes_rGGvsTauGG.CLimMode = 'auto';h.axes_rGGvsTauGG.CLim(1) = 0;
    try;h.axes_rGGvsTauGG.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;end;
    %% Plot rRR vs. tauRR in fourth plot
    if ~h.MultiselectOnCheckbox.UserData
        maxX = min([max(datatoplot(:,idx_tauRR)) BurstData{file}.Corrections.AcceptorLifetime+2]);
        [H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauRR), datatoplot(:,idx_rRR),[nbinsX nbinsY], [0 maxX], [-0.1 0.5]);
        datapoints = [datatoplot(:,idx_tauRR), datatoplot(:,idx_rRR)];
    else
        maxX = BurstData{file}.Corrections.AcceptorLifetime+2;
        [H,xbins,ybins,~,~,datapoints,n_per_species,H_ind] = MultiPlot([],[],h,NameArray{idx_tauRR},NameArray{idx_rRR},{[0 maxX], [-0.1 0.5]});
    end
    if(get(h.Hist_log10, 'Value'))
        H = log10(H);
        if UserValues.BurstBrowser.Display.KDE
            H = real(H);
        end
    end
    H = H/max(max(H));
    BurstMeta.Plots.rRRvsTauRR(1).XData = xbins;
    BurstMeta.Plots.rRRvsTauRR(1).YData = ybins;
    BurstMeta.Plots.rRRvsTauRR(1).CData = H;
    if ~UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rRRvsTauRR(1).AlphaData = H./max(max(H)) > UserValues.BurstBrowser.Display.ImageOffset/100;
    elseif UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rRRvsTauRR(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
    end
    BurstMeta.Plots.rRRvsTauRR(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
    BurstMeta.Plots.rRRvsTauRR(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
    Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
    % replicate to fix edges
    Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
    Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
    BurstMeta.Plots.rRRvsTauRR(2).ZData = Hcontour;
    BurstMeta.Plots.rRRvsTauRR(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
        if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1
            color = [];
            for i = 1:numel(n_per_species)
                color = [color; i*ones(n_per_species(i),1)];
            end
            colors = lines(numel(n_per_species));
            colordata = colors(color,:);
            %%% permute data points randomly to avoid hiding populations below another
            perm = randperm(size(colordata,1));
            colordata = colordata(perm,:);
            datapoints = datapoints(perm,:);
        else
            colordata = UserValues.BurstBrowser.Display.MarkerColor;
        end
        BurstMeta.Plots.rRRvsTauRR(3).XData = datapoints(:,1);
        BurstMeta.Plots.rRRvsTauRR(3).YData = datapoints(:,2);
        BurstMeta.Plots.rRRvsTauRR(3).CData = colordata;
    end
    % clear patches
    if numel(h.axes_rRRvsTauRR.Children) > 8
        delete(h.axes_rRRvsTauRR.Children(1:end-8));
    end
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') & (numel(get_multiselection(h)) > 1) && UserValues.BurstBrowser.Display.Multiplot_Contour
        BurstMeta.Plots.rRRvsTauRR(2).Visible = 'off';
        axes(h.axes_rRRvsTauRR);
        % overlay contour plots
        colors = lines(numel(H));
        ContourPatches = [];
        H = H_ind;
        for i = 1:numel(H)
            %level_list = max(H{i}(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,UserValues.BurstBrowser.Display.PlotCutoff/100,UserValues.BurstBrowser.Display.NumberOfContourLevels);
            [C,contour_plot] = contour(xbins,ybins,H{i},UserValues.BurstBrowser.Display.NumberOfContourLevels,'LineColor','none');
            switch UserValues.BurstBrowser.Display.ContourFill
                case 0
                    alpha = 0;
                case 1
                    alpha = 2/(UserValues.BurstBrowser.Display.NumberOfContourLevels);
            end
            level = 1;
            while level < size(C,2)
                n_vertices = C(2,level);
                if UserValues.BurstBrowser.Display.PlotContourLines
                    ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),colors(i,:),'FaceAlpha',alpha,'EdgeColor',colors(i,:));
                else
                    ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),colors(i,:),'FaceAlpha',alpha,'EdgeColor','none');
                end
                level = level + n_vertices +1;
            end
            delete(contour_plot);
        end
    elseif strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') & (numel(get_multiselection(h)) == 1)
        BurstMeta.Plots.rRRvsTauRR(2).Visible = 'on';
    end
    %%% update hex plot if selected
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
        delete(BurstMeta.HexPlot.rRRvsTauRR);
        %%% make hexplot
        axes(h.axes_rRRvsTauRR);
        BurstMeta.HexPlot.rRRvsTauRR = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',[0 maxX],'ylim',[-0.1 0.5],'res',nbinsX);
    end
    try h.axes_rRRvsTauRR.XLim=[0,maxX]; end
    ylim(h.axes_rRRvsTauRR,[-0.1 0.5]);
    h.axes_rRRvsTauRR.CLimMode = 'auto';h.axes_rRRvsTauRR.CLim(1) = 0;
    try;h.axes_rRRvsTauRR.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;end;
end
%% 3cMFD
if any(BurstData{file}.BAMethod == [3,4])
    idx_tauBB = strcmp('Lifetime BB [ns]',NameArray);
    idx_rBB = strcmp('Anisotropy BB',NameArray);
    idxE1A = strcmp('FRET Efficiency B->G+R',NameArray);
    %% Plot E1A vs. tauBB
    if ~h.MultiselectOnCheckbox.UserData
        valid = (datatoplot(:,idx_tauBB) > 0.01);
        maxX = min([max(datatoplot(:,idx_tauBB)) BurstData{file}.Corrections.DonorLifetimeBlue+1.5]);
        [H, xbins, ybins] = calc2dhist(datatoplot(valid,idx_tauBB), datatoplot(valid,idxE1A),[nbinsX nbinsY], [0 maxX], [-0.1 1.1]);
        datapoints = [datatoplot(valid,idx_tauBB), datatoplot(valid,idxE1A)];
    else
        maxX = BurstData{file}.Corrections.DonorLifetimeBlue+1.5;
        [H,xbins,ybins,~,~,datapoints,n_per_species] = MultiPlot([],[],h,NameArray{idx_tauBB},NameArray{idxE1A},{[0 maxX], [-0.1 1.1]});
    end
    if(get(h.Hist_log10, 'Value'))
        H = log10(H);
        if UserValues.BurstBrowser.Display.KDE
            H = real(H);
        end
    end
    H = H/max(max(H));
    BurstMeta.Plots.E_BtoGRvsTauBB(1).XData = xbins;
    BurstMeta.Plots.E_BtoGRvsTauBB(1).YData = ybins;
    BurstMeta.Plots.E_BtoGRvsTauBB(1).CData = H;
    if ~UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.E_BtoGRvsTauBB(1).AlphaData = H./max(max(H)) > UserValues.BurstBrowser.Display.ImageOffset/100;
    elseif UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.E_BtoGRvsTauBB(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
    end
    BurstMeta.Plots.E_BtoGRvsTauBB(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
    BurstMeta.Plots.E_BtoGRvsTauBB(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
    Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
    % replicate to fix edges
    Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
    Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
    BurstMeta.Plots.E_BtoGRvsTauBB(2).ZData = Hcontour;
    BurstMeta.Plots.E_BtoGRvsTauBB(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
        if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1
            color = [];
            for i = 1:numel(n_per_species)
                color = [color; i*ones(n_per_species(i),1)];
            end
            colors = lines(numel(n_per_species));
            colordata = colors(color,:);
            %%% permute data points randomly to avoid hiding populations below another
            perm = randperm(size(colordata,1));
            colordata = colordata(perm,:);
            datapoints = datapoints(perm,:);
        else
            colordata = UserValues.BurstBrowser.Display.MarkerColor;
        end
        BurstMeta.Plots.E_BtoGRvsTauBB(3).XData = datapoints(:,1);
        BurstMeta.Plots.E_BtoGRvsTauBB(3).YData = datapoints(:,2);
        BurstMeta.Plots.E_BtoGRvsTauBB(3).CData = colordata;
    end
    %%% update hex plot if selected
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
        delete(BurstMeta.HexPlot.E_BtoGRvsTauBB);
        %%% make hexplot
        axes(h.axes_E_BtoGRvsTauBB);
        BurstMeta.HexPlot.E_BtoGRvsTauBB = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',[0 maxX],'ylim',[-0.1 1.1],'res',nbinsX);
    end
    try h.axes_E_BtoGRvsTauBB.XLim=[0,maxX]; end
    ylim(h.axes_E_BtoGRvsTauBB,[-0.1 1.1]);
    h.axes_E_BtoGRvsTauBB.CLimMode = 'auto';h.axes_E_BtoGRvsTauBB.CLim(1) = 0;
    try;h.axes_E_BtoGRvsTauBB.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;end;
    %% Plot rBB vs tauBB
    if ~h.MultiselectOnCheckbox.UserData
        maxX = min([max(datatoplot(:,idx_tauBB)) BurstData{file}.Corrections.DonorLifetimeBlue+1.5]);
        [H, xbins, ybins] = calc2dhist(datatoplot(valid,idx_tauBB), datatoplot(valid,idx_rBB),[nbinsX nbinsY], [0 maxX], [-0.1 0.5]);
        datapoints = [datatoplot(valid,idx_tauBB), datatoplot(valid,idx_rBB)];
    else
        maxX = BurstData{file}.Corrections.DonorLifetimeBlue+1.5;
        [H,xbins,ybins,~,~,datapoints,n_per_species] = MultiPlot([],[],h,NameArray{idx_tauBB},NameArray{idx_rBB},{[0 maxX], [-0.1 0.5]});
    end
    if(get(h.Hist_log10, 'Value'))
        H = log10(H);
        if UserValues.BurstBrowser.Display.KDE
            H = real(H);
        end
    end
    H = H/max(max(H));
    BurstMeta.Plots.rBBvsTauBB(1).XData = xbins;
    BurstMeta.Plots.rBBvsTauBB(1).YData = ybins;
    BurstMeta.Plots.rBBvsTauBB(1).CData = H;
    if ~UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rBBvsTauBB(1).AlphaData = H./max(max(H)) > UserValues.BurstBrowser.Display.ImageOffset/100;
    elseif UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rBBvsTauBB(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
    end
    BurstMeta.Plots.rBBvsTauBB(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
    BurstMeta.Plots.rBBvsTauBB(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
    Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
    % replicate to fix edges
    Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
    Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
    BurstMeta.Plots.rBBvsTauBB(2).ZData = Hcontour;
    BurstMeta.Plots.rBBvsTauBB(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
        if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1
            color = [];
            for i = 1:numel(n_per_species)
                color = [color; i*ones(n_per_species(i),1)];
            end
            colors = lines(numel(n_per_species));
            colordata = colors(color,:);
            %%% permute data points randomly to avoid hiding populations below another
            perm = randperm(size(colordata,1));
            colordata = colordata(perm,:);
            datapoints = datapoints(perm,:);
        else
            colordata = UserValues.BurstBrowser.Display.MarkerColor;
        end
        BurstMeta.Plots.rBBvsTauBB(3).XData = datapoints(:,1);
        BurstMeta.Plots.rBBvsTauBB(3).YData = datapoints(:,2);
        BurstMeta.Plots.rBBvsTauBB(3).CData = colordata;
    end
    %%% update hex plot if selected
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
        delete(BurstMeta.HexPlot.rBBvsTauBB);
        %%% make hexplot
        axes(h.axes_rBBvsTauBB);
        BurstMeta.HexPlot.rBBvsTauBB = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',[0 maxX],'ylim',[-0.1 0.5],'res',nbinsX);
    end
    try h.axes_rBBvsTauBB.XLim=[0,maxX]; end
    ylim(h.axes_rBBvsTauBB,[-0.1 0.5]);
    h.axes_rBBvsTauBB.CLimMode = 'auto';h.axes_rBBvsTauBB.CLim(1) = 0;
    try;h.axes_rBBvsTauBB.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;end;
end