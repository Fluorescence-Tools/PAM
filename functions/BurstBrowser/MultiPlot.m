%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Plots the Species in one Plot (not considering GlobalCuts)  %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [HistOut,xbins,ybins,x_boundaries,y_boundaries,datapoints,n_per_species,H_ind] = MultiPlot(obj,~,h,paramX,paramY,limits)
%%% limits is optional global max and min boundaries for x and y
if nargin < 3
    if ishandle(obj)
        h = guidata(obj);
    else
        if isprop(obj,'EventName') %%% actiondata obj
            h = guidata(obj.Source);
        else
            h = guidata(findobj('Tag','BurstBrowser'));
        end
    end 
end
global BurstData UserValues BurstMeta
%%% special case when lifetime_ind tab is selected
if (nargout == 0) && (h.Main_Tab.SelectedTab == h.Main_Tab_Lifetime) && (h.LifetimeTabgroup.SelectedTab == h.LifetimeTabInd)
    PlotLifetimeInd(obj,[],h);
    return;
end
%%% get selection of species list
[file_n,species_n,subspecies_n,sel] = get_multiselection(h);

num_species = numel(file_n);

if ~exist('paramX','var')
    paramX = h.ParameterListX.String{h.ParameterListX.Value};
end
if ~exist('paramY','var')
    paramY = h.ParameterListY.String{h.ParameterListY.Value};
end
for i = 1:num_species %%% read out parameter positions for every species
    x{i} = find(strcmp(BurstData{file_n(i)}.NameArray,paramX));
    y{i} = find(strcmp(BurstData{file_n(i)}.NameArray,paramY));
end
valid = ~(cellfun(@isempty,x) | cellfun(@isempty,y));
x = x(valid); y=y(valid);
file_n = file_n(valid); species_n = species_n(valid); subspecies_n = subspecies_n(valid);
num_species = sum(valid);
%%% Read out the Number of Bins
nbinsX = UserValues.BurstBrowser.Display.NumberOfBinsX;
nbinsY = UserValues.BurstBrowser.Display.NumberOfBinsY;
if obj == h.MultiPlotButton %%% only limit species when multiplot button has been pressed
    if num_species == 1
        return;
    end
    if ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') & num_species > 3
        % more than 3 species only supported for contour plots
        num_species = 3;
    elseif strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') & num_species > 6
        num_species = 6;
    end
end

datatoplot = cell(num_species,1);
for i = 1:num_species
    [~,datatoplot{i}] = UpdateCuts([species_n(i),subspecies_n(i)],file_n(i));
end

%%% logarithmic plot option
if UserValues.BurstBrowser.Display.logX
    for i = 1:num_species
        val = datatoplot{i}(:,x{i}) > 0; % avoid complex numbers
        datatoplot{i}(val,x{i}) = log10(datatoplot{i}(val,x{i}));
        datatoplot{i}(~val,x{i}) = NaN;
    end
end
if UserValues.BurstBrowser.Display.logY
    for i = 1:num_species
        val = datatoplot{i}(:,y{i}) > 0; % avoid complex numbers
        datatoplot{i}(val,y{i}) = log10(datatoplot{i}(val,y{i}));
        datatoplot{i}(~val,y{i}) = NaN;
    end
end

%find data ranges
minx = zeros(num_species,1);
miny = zeros(num_species,1);
maxx = zeros(num_species,1);
maxy = zeros(num_species,1);
for i = 1:num_species
    minx(i) = min(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i}));
    miny(i) = min(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i}));
    maxx(i) = max(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i}));
    maxy(i) = max(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i}));
end
x_boundaries = [min(minx) max(maxx)];
y_boundaries = [min(miny) max(maxy)];

if ~exist('limits','var') 
    %%% additionally, look for specified cuts and overwrite auto-bounds
    xlimits = cell(num_species,1); ylimits = cell(num_species,1);
    for i = 1:num_species
        %%% find the bounds
        file =file_n(i);
        species = [species_n(i),subspecies_n(i)];
        NameArray = BurstData{file}.NameArray;

        %%% set limits
        xlimits{i} = [min(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i})) max(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i}))];
        ylimits{i} = [min(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i})) max(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i}))];
        %%% find cuts to parameters to be plotted and change limits if needed
        if all(species == [0,0])
            CutState= {};
        else
            Cut = BurstData{file}.Cut{species(1),species(2)};
            CutState = vertcat(Cut{:});
        end
        if size(CutState,2) > 0
            CutParameters = CutState(:,1);
            if any(strcmp(NameArray{x{i}},CutParameters))
                if CutState{strcmp(NameArray{x{i}},CutParameters),4} == 1 %%% Check if active
                    %%% Set x-axis limits according to cut boundaries of selected parameter
                    xlimits{i} = [CutState{strcmp(NameArray{x{i}},CutParameters),2},...
                        CutState{strcmp(NameArray{x{i}},CutParameters),3}];
                else
                    %%% set to min max
                    xlimits{i} = [min(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i})), max(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i}))];
                end
            else
                %%% set to min max
                xlimits{i} = [min(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i})), max(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i}))];
            end
            %%% fix infinite value
            if ~isfinite(xlimits{i}(2))
                xlimits{i}(2) = max(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i}));
            end   
            if any(strcmp(NameArray{y{i}},CutParameters))
                if CutState{strcmp(NameArray{y{i}},CutParameters),4} == 1 %%% Check if active
                    %%% Set x-axis limits according to cut boundaries of selected parameter
                    ylimits{i} = [CutState{strcmp(NameArray{y{i}},CutParameters),2},...
                        CutState{strcmp(NameArray{y{i}},CutParameters),3}];
                else
                    %%% set to min max
                    ylimits{i} = [min(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i})), max(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i}))];
                end
            else
                %%% set to min max
                ylimits{i} = [min(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i})), max(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i}))];
            end
            %%% fix infinite value
            if ~isfinite(ylimits{i}(2))
                ylimits{i}(2) = max(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i}));
            end  
            if isempty(xlimits{i})
                %selection is empty
                xlimits{i} = [0,1];
            end
            if isempty(ylimits{i})
                %selection is empty
                ylimits{i} = [0,1];
            end
            if sum(xlimits{i} == [0,0]) == 2
                xlimits{i} = [0 1];
            end
            if sum(ylimits{i} == [0,0]) == 2
                ylimits{i} = [0 1];
            end
        end
    end
    %%% find minimum and maximum limits
    xlimits = cell2mat(vertcat(xlimits(:)));
    ylimits = cell2mat(vertcat(ylimits(:)));
    %%% overwrite
    x_boundaries(1) = min([x_boundaries(1) min(xlimits(:,1))]);
    x_boundaries(2) = max([x_boundaries(2) max(xlimits(:,2))]);
    y_boundaries(1) = min([y_boundaries(1) min(ylimits(:,1))]);
    y_boundaries(2) = max([y_boundaries(2) max(ylimits(:,2))]);
elseif exist('limits','var') %%% called with absolute limits
    %%% obey specified limits!
    x_boundaries(1) = limits{1}(1);
    x_boundaries(2) = limits{1}(2);
    y_boundaries(1) = limits{2}(1);
    y_boundaries(2) = limits{2}(2);
%     x_boundaries(1) = max([x_boundaries(1) limits{1}(1)]);
%     x_boundaries(2) = min([x_boundaries(2) limits{1}(2)]);
%     y_boundaries(1) = max([y_boundaries(1) limits{2}(1)]);
%     y_boundaries(2) = min([y_boundaries(2) limits{2}(2)]);
end

if UserValues.BurstBrowser.Display.Restrict_EandS_Range
    %%% hard-code limits of [-0.1,1.1] for any Stoichiometry or FRET
    %%% efficiency parameter if the cut limits fall within that range
    if ~isempty(strfind(paramX,'Stoichiometry')) || ~isempty(strfind(paramX,'Efficiency'))
        x_boundaries = [min(x_boundaries(1),-0.1) max(x_boundaries(2),1.1)];
    end
    if ~isempty(strfind(paramY,'Stoichiometry')) || ~isempty(strfind(paramY,'Efficiency'))
        y_boundaries = [min(y_boundaries(1),-0.1) max(y_boundaries(2),1.1)];
    end
end

H = cell(num_species,1);
for i = 1:num_species
    [H{i}, xbins, ybins] = calc2dhist(datatoplot{i}(:,x{i}), datatoplot{i}(:,y{i}),[nbinsX,nbinsY], x_boundaries, y_boundaries);
end

normalize = UserValues.BurstBrowser.Settings.Normalize_Multiplot && num_species > 1 && ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex') && ~(gcbo == h.Fit_Gaussian_Button);
if normalize
    %%% normalize each histogram to equal proportion
    for i = 1:num_species
        switch UserValues.BurstBrowser.Settings.Normalize_Method
            case 'area'
                H{i} = H{i}./sum(H{i}(:))./num_species; %%% ensure that total data sums up to 1
            case 'max'
                H{i} = H{i}./max(H{i}(:))./num_species;
        end
    end
end

if nargout > 0 %%% we requested the histogram, do not plot!
    H_ind = H; %%% assign cell array to last output
    if (gcbo == h.MultiPlotButton) && (h.Main_Tab.SelectedTab == h.Main_Tab_Lifetime) && (h.LifetimeTabgroup.SelectedTab == h.LifetimeTabInd)
        HistOut = H; %%% just return the cell array
    else
        Hcum = H{1};
        for k = 2:numel(H)
            Hcum = Hcum + H{k};
        end
        if UserValues.BurstBrowser.Settings.Normalize_Multiplot && num_species > 1 && ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex') && ~(gcbo == h.Fit_Gaussian_Button)
            HistOut = Hcum./max(Hcum(:));
        else
            HistOut = Hcum;
        end
    end
    
    datapoints = [];
    n_per_species = [];
    if nargout >= 6 %%% return raw data points for scatter/hex plot
        for i = 1:num_species
            n_per_species(end+1) = size(datatoplot{i},1);
            datapoints = [datapoints; [datatoplot{i}(:,x{i}),datatoplot{i}(:,y{i})]];
        end
    end
    return;
end
delete(BurstMeta.HexPlot.MainPlot_hex);

%%% prepare image plot
axes(h.axes_general);

%%% remove old plots
for i = 1:numel(BurstMeta.Plots.MultiScatter.h1dx)
    try;delete(BurstMeta.Plots.MultiScatter.h1dx(i));end;
    try;delete(BurstMeta.Plots.MultiScatter.h1dy(i));end;
end
BurstMeta.Plots.MultiScatter.h1dx = [];
BurstMeta.Plots.MultiScatter.h1dy = [];
for i = 1:numel(BurstMeta.Plots.Multi.ContourPatches)
    try;delete(BurstMeta.Plots.Multi.ContourPatches(i));end;   
end
BurstMeta.Plots.Multi.ContourPatches = [];
%%% additionally, delete all left-over stair plots (those are multi-species
%%% plots, which sometimes are not deleted by the above code...)
delete(h.axes_1d_x.Children(1:end-15));
delete(h.axes_1d_y.Children(1:end-15));
% the same for the axes_general
if numel(h.axes_general.Children) > 10
    delete(h.axes_general.Children(1:end-10));
end
%%% plot
set(BurstMeta.Plots.Main_Plot,'Visible','off');
set(BurstMeta.Plots.Main_histX,'Visible','off');
set(BurstMeta.Plots.Main_histY,'Visible','off');
BurstMeta.Plots.Multi.Main_Plot_multiple.Visible = 'on';
for i = 1:numel(BurstMeta.Plots.Multi.Multi_histX)
    BurstMeta.Plots.Multi.Multi_histX(i).Visible = 'off';
    BurstMeta.Plots.Multi.Multi_histY(i).Visible = 'off';
end
for i = 1:numel(BurstMeta.Plots.MultiScatter.h1dx)
    try;delete(BurstMeta.Plots.MultiScatter.h1dx(i));end;
    try;delete(BurstMeta.Plots.MultiScatter.h1dy(i));end;
end
BurstMeta.Plots.Multi.Main_Plot_multiple.XData = xbins;
BurstMeta.Plots.Multi.Main_Plot_multiple.YData = ybins;

if ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour')
    % overlay images
    %%% mix histograms
    [zz,colors] = overlay_colored(H);
    BurstMeta.Plots.Multi.Main_Plot_multiple.CData = zz;    
    white = 1-UserValues.BurstBrowser.Display.MultiPlotMode;
    if white == 0
        %%% set alpha property
        BurstMeta.Plots.Multi.Main_Plot_multiple.AlphaData = sum(zz,3)>0;
    else
        %%% set alpha property
        BurstMeta.Plots.Multi.Main_Plot_multiple.AlphaData = 1-(sum(zz,3)==3);
        colors = [0,0,1;1,0,0;0,1,0];
    end
else
    %%% hide image plot
    BurstMeta.Plots.Multi.Main_Plot_multiple.Visible = 'off';
    % overlay contour plots
    %colors = lines(numel(H));
    colors = [UserValues.BurstBrowser.Display.ColorLine1;...
            UserValues.BurstBrowser.Display.ColorLine2;...
            UserValues.BurstBrowser.Display.ColorLine3;...
            UserValues.BurstBrowser.Display.ColorLine4;...
            UserValues.BurstBrowser.Display.ColorLine5;...
            UserValues.BurstBrowser.Display.ColorLine6];
    colors = repmat(colors,[10,1]); % replicate in case there are more than 6 species selected
    for i = numel(H):-1:1
        level_list = max(H{i}(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,UserValues.BurstBrowser.Display.PlotCutoff/100,UserValues.BurstBrowser.Display.NumberOfContourLevels);
        [C,contour_plot] = contour(xbins,ybins,H{i},'LevelList',level_list,'LineColor','none'); 
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
                BurstMeta.Plots.Multi.ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),colors(i,:),'FaceAlpha',alpha,'EdgeColor',colors(i,:));
            else
                BurstMeta.Plots.Multi.ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),colors(i,:),'FaceAlpha',alpha,'EdgeColor','none');
            end
            level = level + n_vertices +1;
        end
        delete(contour_plot);
    end
end

xlabel(h.axes_general,paramX,'Color',UserValues.Look.Fore);
ylabel(h.axes_general,paramY,'Color',UserValues.Look.Fore);

% Update axis labels if log option is used
%%% logarithmic plot option
if UserValues.BurstBrowser.Display.logX
    h.axes_general.XLabel.String = [h.axes_general.XLabel.String ' log'];
    h.axes_1d_x.XLabel.String = [h.axes_1d_x.XLabel.String ' log'];
end
if UserValues.BurstBrowser.Display.logY
    h.axes_general.YLabel.String = [h.axes_general.YLabel.String ' log'];
end

%plot first histogram
hx = sum(H{1},1);
%normalize
if normalize
    switch UserValues.BurstBrowser.Settings.Normalize_Method
        case 'max'
            hx = hx./max(hx);
        case 'area'
            hx = hx./sum(hx);
    end 
end
hx = hx'; hx = [hx; hx(end)];
xbins = [xbins, xbins(end)+min(diff(xbins))]-min(diff(xbins))/2;
BurstMeta.Plots.Multi.Multi_histX(1).Visible = 'on';
BurstMeta.Plots.Multi.Multi_histX(1).XData = xbins;
BurstMeta.Plots.Multi.Multi_histX(1).YData = hx;
%plot rest of histograms
for i = 2:num_species
    BurstMeta.Plots.Multi.Multi_histX(i).Visible = 'on';
    hx = sum(H{i},1);
    %normalize
    if normalize
        switch UserValues.BurstBrowser.Settings.Normalize_Method
            case 'max'
                hx = hx./max(hx);
            case 'area'
                hx = hx./sum(hx);
        end
    end
    hx = hx'; hx = [hx; hx(end)];
    BurstMeta.Plots.Multi.Multi_histX(i).XData = xbins;
    BurstMeta.Plots.Multi.Multi_histX(i).YData = hx;
end
h.axes_1d_x.YTickMode = 'auto';
yticks = get(h.axes_1d_x,'YTick');
set(h.axes_1d_x,'YTick',yticks(2:end));

%plot first histogram
hy = sum(H{1},2);
%normalize
if normalize
    switch UserValues.BurstBrowser.Settings.Normalize_Method
        case 'area'
            hy = hy./sum(hy);
        case 'max'
            hy = hy./max(hy);
    end
end
hy = hy'; hy = [hy, hy(end)];
ybins = [ybins, ybins(end)+min(diff(ybins))]-min(diff(ybins))/2;
BurstMeta.Plots.Multi.Multi_histY(1).Visible = 'on';
BurstMeta.Plots.Multi.Multi_histY(1).XData = ybins;
BurstMeta.Plots.Multi.Multi_histY(1).YData = hy;
%plot rest of histograms
for i = 2:num_species
    BurstMeta.Plots.Multi.Multi_histY(i).Visible = 'on';
    hy = sum(H{i},2);
    %normalize
    if normalize
        switch UserValues.BurstBrowser.Settings.Normalize_Method
            case 'area'
                hy = hy./sum(hy);
            case 'max'
                hy = hy./max(hy);
        end
    end
    hy = hy'; hy = [hy, hy(end)];
    BurstMeta.Plots.Multi.Multi_histY(i).XData = ybins;
    BurstMeta.Plots.Multi.Multi_histY(i).YData = hy;
end
h.axes_1d_y.YTickMode = 'auto';
yticks = get(h.axes_1d_y,'YTick');
set(h.axes_1d_y,'YTick',yticks(2:end));

%% change color of 1d hists
for i = 1:num_species
    BurstMeta.Plots.Multi.Multi_histX(i).Color = colors(i,:);
    BurstMeta.Plots.Multi.Multi_histY(i).Color = colors(i,:);
end

%%% add legend
str = cell(num_species,1);
for i = 1:num_species
    %%% extract name
    name = BurstData{file_n(i)}.FileName;
    if (species_n(i) ~= 0)
        if (subspecies_n(i) ~= 1) %%% we have a subspecies selected
            name = [name,'/', char(sel(i).getParent.getName),'/',char(sel(i).getName)];
        else %%% we have a species selected 
            name = [name,'/', char(sel(i).getName)];
        end
    end
    str{i} = strrep(name,'_',' ');  
end
legend(BurstMeta.Plots.Multi.Multi_histX(1:num_species),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
%legend(h.axes_1d_x.Children(8:-1:8-num_species+1),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
h.colorbar.Visible = 'off';
h.axes_ZScale.Visible = 'off';
set(h.axes_ZScale.Children,'Visible','off');