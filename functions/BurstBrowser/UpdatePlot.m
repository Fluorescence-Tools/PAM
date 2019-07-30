%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Plot in the Main Axis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdatePlot(obj,~,h)
%% Preparation
global BurstData UserValues BurstMeta
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end

%%% If a display option was changed, update the UserValues!
UpdateGUIOptions(obj,[],h);

if isempty(BurstData)
    return;
end
if ~verLessThan('matlab','8.5')
    drawnow nocallbacks
end
%% Update Main Plot
if strcmp(h.axes_general.YDir,'reverse')
    set(h.axes_general,'YDir','normal');
end
x = get(h.ParameterListX,'Value');
y = get(h.ParameterListY,'Value');
x_name = h.ParameterListX.String{x};
y_name = h.ParameterListY.String{y};
%%% Read out the Number of Bins
nbinsX = UserValues.BurstBrowser.Display.NumberOfBinsX;
nbinsY = UserValues.BurstBrowser.Display.NumberOfBinsY;

%%% Update ColorMap
if ischar(UserValues.BurstBrowser.Display.ColorMap)
    if ~UserValues.BurstBrowser.Display.ColorMapFromWhite
        colormap(h.BurstBrowser,UserValues.BurstBrowser.Display.ColorMap);
    else
        if ~strcmp(UserValues.BurstBrowser.Display.ColorMap,'jet')
            colormap(h.BurstBrowser,colormap_from_white(UserValues.BurstBrowser.Display.ColorMap));
        else %%% jet is a special case, use jetvar colormap
            colormap(h.BurstBrowser,jetvar);
        end
    end
else
    colormap(h.BurstBrowser,UserValues.BurstBrowser.Display.ColorMap);
end
if UserValues.BurstBrowser.Display.ColorMapInvert
    colormap(flipud(colormap));
end
h.colorbar.Visible = 'on';
%%% Disable/Enable respective plots
switch UserValues.BurstBrowser.Display.PlotType
    case 'Image'
        BurstMeta.Plots.Main_Plot(1).Visible = 'on';
    case 'Contour'
        BurstMeta.Plots.Main_Plot(2).Visible = 'on';
    case 'Scatter'
        BurstMeta.Plots.Main_Plot(3).Visible = 'on';
end
set(BurstMeta.Plots.Main_histX,'Visible','on');
set(BurstMeta.Plots.Main_histY,'Visible','on');
BurstMeta.Plots.Multi.Main_Plot_multiple.Visible = 'off';
set(BurstMeta.Plots.Multi.Multi_histX,'Visible','off');
set(BurstMeta.Plots.Multi.Multi_histY,'Visible','off');
switch UserValues.BurstBrowser.Display.ContourFill
    case 0
        BurstMeta.Plots.Main_Plot(2).Fill = 'off';
    case 1
        BurstMeta.Plots.Main_Plot(2).Fill = 'on';
end
for i = 1:numel(BurstMeta.Plots.MultiScatter.h1dx)
    try;delete(BurstMeta.Plots.MultiScatter.h1dx(i));end
    try;delete(BurstMeta.Plots.MultiScatter.h1dy(i));end
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
if numel(h.axes_general.Children) > 10
    delete(h.axes_general.Children(1:end-10));
end

legend(h.axes_1d_x,'off');
%%% only hide fit plots if selection of parameter or species has changed,
%%% or if we switched on KDE
obj = gcbo;
if any(obj == [h.SmoothKDE,h.NumberOfBinsXEdit,h.NumberOfBinsYEdit])
    set(BurstMeta.Plots.Mixture.Main_Plot,'Visible','off');
    set(BurstMeta.Plots.Mixture.plotX,'Visible','off');
    set(BurstMeta.Plots.Mixture.plotY,'Visible','off');
elseif obj == h.SpeciesList.Tree
    set(BurstMeta.Plots.Mixture.Main_Plot,'Visible','off');
    set(BurstMeta.Plots.Mixture.plotX,'Visible','off');
    set(BurstMeta.Plots.Mixture.plotY,'Visible','off');
else
    try %%% try for java handle with property name
        if any(strcmp(obj.Name,{'ParameterListX','ParameterListY'}))
            set(BurstMeta.Plots.Mixture.Main_Plot,'Visible','off');
            set(BurstMeta.Plots.Mixture.plotX,'Visible','off');
            set(BurstMeta.Plots.Mixture.plotY,'Visible','off');
        end
    end
end

file = BurstMeta.SelectedFile;
datatoplot = BurstData{file}.DataCut;
species = BurstData{file}.SelectedSpecies;
NameArray = BurstData{file}.NameArray;
%%% logarithmic plot option
if UserValues.BurstBrowser.Display.logX
    val = datatoplot(:,x) > 0; % avoid complex numbers
    datatoplot(val,x) = log10(datatoplot(val,x));
    datatoplot(~val,x) = NaN;
end
if UserValues.BurstBrowser.Display.logY
    val = datatoplot(:,y) > 0; % avoid complex numbers
    datatoplot(val,y) = log10(datatoplot(val,y));
    datatoplot(~val,y) = NaN;
end
%% histogram generation and plotting
%%% set limits
xlimits = [min(datatoplot(isfinite(datatoplot(:,x)),x)) max(datatoplot(isfinite(datatoplot(:,x)),x))];
ylimits = [min(datatoplot(isfinite(datatoplot(:,y)),y)) max(datatoplot(isfinite(datatoplot(:,y)),y))];
%%% find cuts to parameters to be plotted and change limits if needed
if all(species == [0,0])
    CutState= {};
else
    Cut = BurstData{file}.Cut{species(1),species(2)};
    CutState = vertcat(Cut{:});
end
if size(CutState,2) > 0
    CutParameters = CutState(:,1);
    if any(strcmp(NameArray{x},CutParameters))
        if CutState{strcmp(NameArray{x},CutParameters),4} == 1 %%% Check if active
            %%% Set x-axis limits according to cut boundaries of selected parameter
            xlimits = [CutState{strcmp(NameArray{x},CutParameters),2},...
                CutState{strcmp(NameArray{x},CutParameters),3}];
            if UserValues.BurstBrowser.Display.logX
                xlimits(xlimits <= 0) = 1e-2;
                xlimits = log10(xlimits);
            end
        else
            %%% set to min max
            xlimits = [min(datatoplot(isfinite(datatoplot(:,x)),x)), max(datatoplot(isfinite(datatoplot(:,x)),x))];
        end
    else
        %%% set to min max
        xlimits = [min(datatoplot(isfinite(datatoplot(:,x)),x)), max(datatoplot(isfinite(datatoplot(:,x)),x))];
    end

    if any(strcmp(NameArray{y},CutParameters))
        if CutState{strcmp(NameArray{y},CutParameters),4} == 1 %%% Check if active
            %%% Set x-axis limits according to cut boundaries of selected parameter
            ylimits = [CutState{strcmp(NameArray{y},CutParameters),2},...
                CutState{strcmp(NameArray{y},CutParameters),3}];
            if UserValues.BurstBrowser.Display.logY
                ylimits(ylimits <= 0) = 1e-2;
                ylimits = log10(ylimits);
            end
        else
            %%% set to min max
            ylimits = [min(datatoplot(isfinite(datatoplot(:,y)),y)), max(datatoplot(isfinite(datatoplot(:,y)),y))];
        end
    else
        %%% set to min max
        ylimits = [min(datatoplot(isfinite(datatoplot(:,y)),y)), max(datatoplot(isfinite(datatoplot(:,y)),y))];
    end
    if isempty(xlimits)
        %selection is empty
        xlimits = [0,1];
    end
    if isempty(ylimits)
        %selection is empty
        ylimits = [0,1];
    end
    if sum(xlimits == [0,0]) == 2
        xlimits = [0 1];
    end
    if sum(ylimits == [0,0]) == 2
        ylimits = [0 1];
    end
    if UserValues.BurstBrowser.Display.Restrict_EandS_Range
        %%% hard-code limits of [-0.1,1.1] for any Stoichiometry or FRET
        %%% efficiency parameter if the cut limits fall within that range
        if ~isempty(strfind(NameArray{x},'Stoichiometry')) || ~isempty(strfind(NameArray{x},'Efficiency'))
            xlimits = [max(xlimits(1),-0.1) min(xlimits(2),1.1)];
            if UserValues.BurstBrowser.Display.logX
                if xlimits(1) <= 0
                    xlimits(1) = 1E-2;
                end
                xlimits = log10(xlimits);
            end
        end
        if ~isempty(strfind(NameArray{y},'Stoichiometry')) || ~isempty(strfind(NameArray{y},'Efficiency'))
            ylimits = [max(ylimits(1),-0.1) min(ylimits(2),1.1)];
            if UserValues.BurstBrowser.Display.logY
                if ylimits(1) <= 0
                    ylimits(1) = 1E-2;
                end
                ylimits = log10(ylimits);
            end
        end
    end
end

%%% check what plot type to use
advanced = any(cell2mat(h.CutTable.Data(:,6))) && ~(h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1) && ~h.SmoothKDE.Value;
if ~advanced
    if ~h.MultiselectOnCheckbox.UserData
        [H, xbins,ybins,~,~,bin] = calc2dhist(datatoplot(:,x),datatoplot(:,y),[nbinsX nbinsY],xlimits,ylimits);
    else
        %%% call MultiPlot for superposition of all histograms
        [H,xbins,ybins,xlimits,ylimits,datapoints,n_per_species,H_ind] = MultiPlot([],[],h);
    end
    if(get(h.Hist_log10, 'Value'))
        HH = log10(H);
        if UserValues.BurstBrowser.Display.KDE
            HH = real(HH);
        end
    else
        HH = H;
    end
    %%% Update Image Plot and Contour Plot
    BurstMeta.Plots.Main_Plot(1).XData = xbins;
    BurstMeta.Plots.Main_Plot(1).YData = ybins;
    BurstMeta.Plots.Main_Plot(1).CData = HH;
    if ~UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.Main_Plot(1).AlphaData = HH./max(max(HH)) > UserValues.BurstBrowser.Display.ImageOffset/100;
    elseif UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.Main_Plot(1).AlphaData = HH./max(max(HH)) > UserValues.BurstBrowser.Display.ImageOffset/100;%(HH./max(max(HH)) > 0.01);
    end
    BurstMeta.Plots.Main_Plot(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
    BurstMeta.Plots.Main_Plot(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
    HHcontour =zeros(size(HH)+2); HHcontour(2:end-1,2:end-1) = HH; 
    % replicate to fix edges
    HHcontour(2:end-1,1) = HH(:,1);HHcontour(2:end-1,end) = HH(:,end);HHcontour(1,2:end-1) = HH(1,:);HHcontour(end,2:end-1) = HH(end,:);
    HHcontour(1,1) = HH(1,1);HHcontour(end,1) = HH(end,1);HHcontour(1,end) = HH(1,end);HHcontour(end,end) = HH(end,end);
    BurstMeta.Plots.Main_Plot(2).ZData = HHcontour;
    BurstMeta.Plots.Main_Plot(2).LevelList = max(HH(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    h.axes_general.CLimMode = 'auto';
    h.axes_general.CLim(1) = 0;
    h.axes_general.CLim(2) = max(HH(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;
    %%% Disable ZScale Axis
    h.axes_ZScale.Visible = 'off';
    set(BurstMeta.Plots.ZScale_hist,'Visible','off');
    %%% Update Colorbar
    h.colorbar.Label.String = 'Occurrence';
    h.colorbar.Ticks = [];
    h.colorbar.TickLabels = [];
    h.colorbar.TickLabelsMode = 'auto';
    pause(0.1)
    h.colorbar.TicksMode = 'auto';
    %%% update hex plot if selected
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
        delete(BurstMeta.HexPlot.MainPlot_hex);
        %%% hide all other plots
        set(BurstMeta.Plots.Main_Plot,'Visible','off');
        %%% we need to choose one binning, choose x binning
        nbins = nbinsX;
        UserValues.BurstBrowser.Display.NumberOfBinsX = nbins;
        UserValues.BurstBrowser.Display.NumberOfBinsY = nbins;
        h.NumberOfBinsXEdit.String = num2str(nbins);
        h.NumberOfBinsYEdit.String = num2str(nbins);
        %%% get data
        if ~h.MultiselectOnCheckbox.UserData
            datapoints = [datatoplot(:,x),datatoplot(:,y)];
        end
        %%% make hexplot
        axes(h.axes_general);
        BurstMeta.HexPlot.MainPlot_hex = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',xlimits,'ylim',ylimits,'res',nbins);
        set(BurstMeta.HexPlot.MainPlot_hex,'UIContextMenu',h.ExportGraph_Menu);
    end
    if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1 %%% multiple species selected, plot individual hists
        normalize = UserValues.BurstBrowser.Settings.Normalize_Multiplot && ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex') && ~(gcbo == h.Fit_Gaussian_Button);
        %%% prepare 1d hists
        binsx = linspace(xlimits(1),xlimits(2),nbinsX+1);
        binsy = linspace(ylimits(1),ylimits(2),nbinsY+1);
        n_per_species_cum = cumsum([1,(n_per_species-1)]);
        for i = 1:numel(n_per_species_cum)-1
            hx{i} = histcounts(datapoints(n_per_species_cum(i):n_per_species_cum(i+1),1),binsx);
            hy{i} = histcounts(datapoints(n_per_species_cum(i):n_per_species_cum(i+1),2),binsy); 
            if normalize %obj ~= h.Fit_Gaussian_Button
                switch UserValues.BurstBrowser.Settings.Normalize_Method
                    case 'area'
                        hx{i} = hx{i}./sum(hx{i});
                        hy{i} = hy{i}./sum(hy{i});
                    case 'max'
                        hx{i} = hx{i}./max(hx{i});
                        hy{i} = hy{i}./max(hy{i});
                end
            end
        end
        color = lines(numel(n_per_species));
        for i = 1:numel(hx)
            BurstMeta.Plots.MultiScatter.h1dx(i) = handle(stairs(binsx,[hx{i},hx{i}(end)],'Color',color(i,:),'LineWidth',2,'Parent',h.axes_1d_x));
            BurstMeta.Plots.MultiScatter.h1dy(i) = handle(stairs(binsy,[hy{i},hy{i}(end)],'Color',color(i,:),'LineWidth',2,'Parent',h.axes_1d_y));
        end
        if UserValues.BurstBrowser.Settings.Display_Total_Multiplot
            hx_total = sum(vertcat(hx{:}),1);hy_total = sum(vertcat(hy{:}),1);
            BurstMeta.Plots.MultiScatter.h1dx(end+1) = handle(stairs(binsx,[hx_total,hx_total(end)],'Color',[0,0,0],'LineWidth',2,'Parent',h.axes_1d_x));
            BurstMeta.Plots.MultiScatter.h1dy(end+1) = handle(stairs(binsy,[hy_total,hy_total(end)],'Color',[0,0,0],'LineWidth',2,'Parent',h.axes_1d_y));
        end
        %%% hide normal 1d plots
        set(BurstMeta.Plots.Main_histX,'Visible','off');
        set(BurstMeta.Plots.Main_histY,'Visible','off');
        %%% add legend
        [file_n,species_n,subspecies_n,sel] = get_multiselection(h);
        num_species = numel(file_n);
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
        if UserValues.BurstBrowser.Settings.Display_Total_Multiplot
            legend(h.axes_1d_x.Children(num_species+1:-1:2),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
        else
            legend(h.axes_1d_x.Children(num_species:-1:1),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
        end
    end
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter') %%% update scatter plots
        if  h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1 %%% multiple species selected, color automatically
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
            datapoints = [datatoplot(:,x),datatoplot(:,y)];
            colordata = UserValues.BurstBrowser.Display.MarkerColor;
        end
        BurstMeta.Plots.Main_Plot(3).XData = datapoints(:,1);
        BurstMeta.Plots.Main_Plot(3).YData = datapoints(:,2);
        BurstMeta.Plots.Main_Plot(3).CData = colordata;
        h.colorbar.Visible = 'off';
    end
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') %%% update contour plots for multiselection
        if  h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1 && UserValues.BurstBrowser.Display.Multiplot_Contour
            %%% multiple species selected, color automatically
            %%% hide contour plot
            BurstMeta.Plots.Main_Plot(2).Visible = 'off';
            %%% plot contours
             MultiPlot(h.MultiPlotButton,[]);
        else
            BurstMeta.Plots.Main_Plot(2).Visible = 'on';
        end
    end
else
    % histogram X vs Y parameter
    [H, xbins,ybins,~,~,bin] = calc2dhist(datatoplot(:,x),datatoplot(:,y),[nbinsX nbinsY],xlimits,ylimits);
    % create Mask of size H
    Mask = zeros(size(H,1),size(H,2));
    counter = zeros(size(H,1),size(H,2));
    % which parameter in the list defines the Mask
    param = h.CutTable.Data{cell2mat(h.CutTable.Data(:,6)),1};
    %%% remove html formatting
    param = param(23:end-18);
    z = find(strcmp(param,BurstData{file}.NameArray)); 
    z = datatoplot(:,z);

    % sort all selected bursts into the Mask
    for i = 1:size(bin,1) %bin in a list of X and Y bins of all selected bursts
        if ~isnan(z(i)) && ~isnan(bin(i,1)) && ~isnan(bin(i,2))
            Mask(bin(i,1),bin(i,2)) = Mask(bin(i,1),bin(i,2)) + z(i);
            counter(bin(i,1),bin(i,2)) = counter(bin(i,1),bin(i,2)) + 1;
        end
    end
    % make the average of all entries in Mask depending on the number of bursts in the pixel
    Mask(counter > 0) = Mask(counter > 0)./counter(counter > 0); 
    zParam = Mask(:);
    % go in between the limits defined in the cut table 
    zlim = [h.CutTable.Data{cell2mat(h.CutTable.Data(:,6)),2} h.CutTable.Data{cell2mat(h.CutTable.Data(:,6)),3}];
    Mask(Mask < zlim(1)) = zlim(1);
    Mask(Mask > zlim(2)) = zlim(2);   
    % get the colormap user wants
    if ischar(UserValues.BurstBrowser.Display.ColorMap)
        eval(['cmap =' UserValues.BurstBrowser.Display.ColorMap '(64);']);
    else
        cmap=UserValues.BurstBrowser.Display.ColorMap;
    end
    % invert colormap
    if UserValues.BurstBrowser.Display.ColorMapInvert
        cmap=flipud(cmap);
    end
    %%% bin according to the size of the colormap
    Mask = floor((size(cmap,1)-1)*(Mask-zlim(1))./(zlim(2)-zlim(1)))+1;
    
    %   converts a back to the size of Mask, but now the color in the 3rd dimension
    Color = reshape(cmap(Mask,:),size(Mask,1),size(Mask,2),3);

    if UserValues.BurstBrowser.Display.ZScale_Intensity
        %%% rescale intensity
        ImageColor=gray(128);
        %%% brighten image color map by beta = 25%
        beta = UserValues.BurstBrowser.Display.BrightenColorMap;
        if beta > 0
            ImageColor = ImageColor.^(1-beta);
        elseif beta <= 0
            ImageColor = ImageColor.^(1/(1+beta));
        end
        offset = 0;
        Image=round((127-offset)*(H-min(min(H)))/(max(max(H))-min(min(H))))+1+offset;
        Image=reshape(ImageColor(Image(:),:),size(Image,1),size(Image,2),3);
        Image = Image.*Color;
    else
        Image = Color;
    end
    BurstMeta.Plots.Main_Plot(1).XData = xbins;
    BurstMeta.Plots.Main_Plot(1).YData = ybins;
    BurstMeta.Plots.Main_Plot(1).CData = Image;
    BurstMeta.Plots.Main_Plot(1).AlphaData = (H./max(max(H)) > offset);
    
    %%% Enable ZScale Axis
    h.axes_ZScale.Visible = 'on';
    set(BurstMeta.Plots.ZScale_hist,'Visible','on');
    %%% Plot histogram of average Z paramter
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
        %%% use non-averaged parameter
        zData = z;
    else
        %%% image plot, show histogram of pixel wise average
        zData = zParam(zParam>0);
    end
    [Z,xZ] = histcounts(zData,linspace(zlim(1),zlim(2),26));
    xZ = xZ(1:end-1)+min(diff(xZ))/2;
    BurstMeta.Plots.ZScale_hist(1).XData = xZ;
    BurstMeta.Plots.ZScale_hist(1).YData = Z;
    BurstMeta.Plots.ZScale_hist(2).XData = [xZ,xZ(end)+min(diff(xZ))]-min(diff(xZ))/2;
    BurstMeta.Plots.ZScale_hist(2).YData = [Z, Z(end)];
    xlim(h.axes_ZScale,zlim);
    h.axes_ZScale.XTick = linspace(zlim(1),zlim(2),5);
    h.axes_ZScale.XTickLabel = [];
    h.axes_ZScale.YTick = linspace(h.axes_ZScale.YLim(1),h.axes_ZScale.YLim(2),5);
    h.axes_ZScale.YTickLabel = [];
    %%% Update Colorbar
    h.colorbar.Label.String = param;%h.CutTable.RowName(cell2mat(h.CutTable.Data(:,5)));
    h.colorbar.Ticks = [h.colorbar.Limits(1),h.colorbar.Limits(1)+(h.colorbar.Limits(2)-h.colorbar.Limits(1))/2,h.colorbar.Limits(2)];%[0,1/2,1];
    h.colorbar.TickLabels = {sprintf('%.2f',(zlim(1)));sprintf('%.2f',zlim(1)+(zlim(2)-zlim(1))/2);sprintf('%.2f',zlim(2))};
    h.colorbar.AxisLocation='out';
    
    if any(strcmp(UserValues.BurstBrowser.Display.PlotType,{'Contour','Hex'}))
        %%% Change plot type to image
        h.PlotTypePopumenu.Value = 1;
        UserValues.BurstBrowser.Display.PlotType = 'Image';
        ChangePlotType(h.PlotTypePopumenu,[]);
    end
    
    if strcmp(UserValues.BurstBrowser.Display.PlotType,{'Scatter'})
        %%% simply use z-paramter as color
        BurstMeta.Plots.Main_Plot(3).XData = datatoplot(:,x);
        BurstMeta.Plots.Main_Plot(3).YData = datatoplot(:,y);
        %%% map z value to colormap
        cmap = colormap;
        z(z<zlim(1)) = zlim(1); z(z>zlim(2)) = zlim(2);
        z_to_color = ceil((z-min(z))./(max(z)-min(z)).*size(cmap,1));
        z_to_color(z_to_color == 0) = 1;
        z_to_color(isnan(z_to_color)) = size(cmap,1);
        z_color = cmap(z_to_color,:);
        BurstMeta.Plots.Main_Plot(3).CData = z_color;
    end

    HH = H;
end

%% plotting of 1d hists

%%% set limits of axes
if ~(xlimits(1) == xlimits(2))
    h.axes_general.XLim = xlimits;
    h.axes_1d_x.XLim = xlimits;
end
if ~(ylimits(1) == ylimits(2))
    h.axes_general.YLim = ylimits;
    h.axes_1d_y.XLim = ylimits;
end
%%% Update Labels
xlabel(h.axes_general,h.ParameterListX.String{x},'Color',UserValues.Look.Fore);
ylabel(h.axes_general,h.ParameterListY.String{y},'Color',UserValues.Look.Fore);
xlabel(h.axes_1d_x,h.ParameterListX.String{x},'Color',UserValues.Look.Fore);
%xlabel(h.axes_1d_y,h.ParameterListX.String{y},'Color',UserValues.Look.Fore,'Rotation',270,'Units','normalized','Position',[1.35,0.5]);

%plot 1D hists
h.axes_1d_x.XTickLabelMode = 'auto';
BurstMeta.Plots.Main_histX(1).XData = xbins;
BurstMeta.Plots.Main_histX(1).YData = sum(H,1);
BurstMeta.Plots.Main_histX(2).XData = [xbins,xbins(end)+min(diff(xbins))]-min(diff(xbins))/2;
BurstMeta.Plots.Main_histX(2).YData = [BurstMeta.Plots.Main_histX(1).YData, BurstMeta.Plots.Main_histX(1).YData(end)];
h.axes_1d_x.YTickMode = 'auto';
yticks= get(h.axes_1d_x,'YTick');
set(h.axes_1d_x,'YTick',yticks(2:end));

BurstMeta.Plots.Main_histY(1).XData = ybins;
BurstMeta.Plots.Main_histY(1).YData = sum(H,2);
BurstMeta.Plots.Main_histY(2).XData = [ybins,ybins(end)+min(diff(ybins))]-min(diff(ybins))/2;
BurstMeta.Plots.Main_histY(2).YData = [BurstMeta.Plots.Main_histY(1).YData, BurstMeta.Plots.Main_histY(1).YData(end)];
h.axes_1d_y.YTickMode = 'auto';
yticks = get(h.axes_1d_y,'YTick');
set(h.axes_1d_y,'YTick',yticks(2:end));

if (h.axes_1d_x.XLim(2) - h.axes_1d_x.XTick(end))/(h.axes_1d_x.XLim(2)-h.axes_1d_x.XLim(1)) < 0.02
    %%% Last XTick Label is at the end of the axis and thus overlaps with colorbar
    h.axes_1d_x.XTickLabel{end} = '';
else
    h.axes_1d_x.XTickLabel = h.axes_general.XTickLabel;
end

% Update no. bursts
set(h.text_nobursts, 'String', [num2str(sum(BurstData{file}.Selected)) ' bursts ('...
                                num2str(round(sum(BurstData{file}.Selected/numel(BurstData{file}.Selected)*1000))/10) '% of total)']);
                            
if sum(strcmp('Mean Macrotime [s]',BurstData{file}.NameArray)) == 1
    h.text_nobursts.TooltipString = sprintf('%.1f events per second',size(BurstData{file}.DataArray,1)./BurstData{file}.DataArray(end,strcmp('Mean Macrotime [s]',BurstData{file}.NameArray)));
end

if h.DisplayAverage.Value == 1
    h.axes_1d_x_text.Visible = 'on';
    h.axes_1d_y_text.Visible = 'on';

    set(h.axes_1d_x_text, 'String', sprintf('avg = %.3f%c%.3f',mean(datatoplot(:,x),'omitnan'),char(177),std(datatoplot(:,x),'omitnan')));
    set(h.axes_1d_y_text, 'String', sprintf('avg = %.3f%c%.3f',mean(datatoplot(:,y),'omitnan'),char(177),std(datatoplot(:,y),'omitnan')));
else
    h.axes_1d_x_text.Visible = 'off';
    h.axes_1d_y_text.Visible = 'off';
end

% Update axis labels if log option is used
%%% logarithmic plot option
if UserValues.BurstBrowser.Display.logX
    h.axes_general.XLabel.String = [h.axes_general.XLabel.String ' log'];
    h.axes_1d_x.XLabel.String = [h.axes_1d_x.XLabel.String ' log'];
end
if UserValues.BurstBrowser.Display.logY
    h.axes_general.YLabel.String = [h.axes_general.YLabel.String ' log'];
end
%% Gaussian fitting
if obj == h.Fit_Gaussian_Button
    %%% reset plots
    set(BurstMeta.Plots.Mixture.Main_Plot,'Visible','off');
    set(BurstMeta.Plots.Mixture.plotX,'Visible','off');
    set(BurstMeta.Plots.Mixture.plotY,'Visible','off');
    if isfield(BurstMeta,'Fitting')
        %%% remove field in BurstMeta
        BurstMeta = rmfield(BurstMeta,'Fitting');
    end
    paramx = x; paramy = y;
    %%% Perform fitting of Gausian Mixture model to currently plotted data
    h.Progress_Text.String = 'Fitting Gaussian Mixture...';drawnow;
    nG = h.Fit_NGaussian_Popupmenu.Value;
    %%% update datatoplot if multiselection is enabled
    if h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1
        data_x = get_multiselection_data(h,x_name);
        data_y = get_multiselection_data(h,y_name);
        %%% logarithmic plot option
        if UserValues.BurstBrowser.Display.logX
            val = data_x > 0; % avoid complex numbers
            data_x(val) = log10(data_x(val));
            data_x(~val) = NaN;
        end
        if UserValues.BurstBrowser.Display.logY
            val = data_y > 0; % avoid complex numbers
            data_y(val) = log10(data_y(val));
            data_y(~val) = NaN;
        end
    else
        data_x = datatoplot(:,x);
        data_y = datatoplot(:,y);
    end
    %%% we need to adjust the number of xbins/ybins of KDE has been used
    if UserValues.BurstBrowser.Display.KDE
        nbinsX = numel(xbins);
        nbinsY = numel(ybins);
    end
    % Fit mixture to data
    switch UserValues.BurstBrowser.Settings.GaussianFitMethod
        case 'MLE'
            if x == y %%% same data selected, 1D fitting
                BurstMeta.Fitting.FitType = '1D';
                
                GModel = fitgmdist(data_x,nG,'Options',statset('MaxIter',1000));
                xbins_fit = linspace(xbins(1)-min(diff(xbins)),xbins(end)+min(diff(xbins)),1000);
                p = pdf(GModel,xbins_fit');
                Res = zeros(1,3*nG);
                Res(1:3:end) = GModel.ComponentProportion;
                Res(2:3:end) = GModel.mu;
                Res(3:3:end) = sqrt(GModel.Sigma);
                Res(end+1) = GModel.NegativeLogLikelihood;
                Res(end+1) = GModel.BIC;
                BurstMeta.Fitting.FitResult = Res;
                
                BurstMeta.Plots.Mixture.plotX(1).Visible = 'on';
                BurstMeta.Plots.Mixture.plotX(1).XData = xbins_fit;
                BurstMeta.Plots.Mixture.plotX(1).YData = p./sum(p).*sum(sum(HH))*1000/nbinsX;
                if nG > 1
                    for i = 1:nG
                        p_ind = normpdf(xbins_fit,GModel.mu(i),sqrt(GModel.Sigma(:,:,i)));
                        p_ind = p_ind./sum(p_ind).*sum(sum(HH)).*GModel.ComponentProportion(i);
                        BurstMeta.Plots.Mixture.plotX(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.plotX(i+1).XData = xbins_fit;
                        BurstMeta.Plots.Mixture.plotX(i+1).YData = p_ind*1000/nbinsX;
                    end
                end
                h.Fit_Gaussian_Text.Data(1,1:3) = {double(GModel.Converged),GModel.NegativeLogLikelihood,GModel.BIC};
                for i = 1:nG
                    h.Fit_Gaussian_Text.Data(3+i,:) = {GModel.ComponentProportion(i),GModel.mu(i,1),'-',sqrt(GModel.Sigma(1,1,i)),'-','-'};
                end
                if nG < 5
                    h.Fit_Gaussian_Text.Data(3+nG+1:end,:) = cell(5-nG,6);
                end
            else
                BurstMeta.Fitting.FitType = '2D';
                
                valid = isfinite(data_x) & isfinite(data_y);
                if h.Fit_Gaussian_Pick.Value
                    cov = [std(data_x),0; 0,std(data_y)];
                    if verLessThan('MATLAB','9.5')
                        [x_start,y_start] = ginput(nG);
                    else % 2018b and onwards
                        [x_start,y_start] = my_ginput(nG);
                    end
                    start = struct('mu',[x_start,y_start],'Sigma',repmat(cov,[1,1,nG]),'ComponentProportion',ones(1,nG)./nG);
                    GModel = fitgmdist([data_x(valid),data_y(valid)],nG,'Start',start,'Options',statset('MaxIter',1000));
                else
                    %[~,ix_max] = max(HH(:));
                    %[y_start,x_start] = ind2sub([nbinsX,nbinsY],ix_max);
                    %start = struct('mu',repmat([xbins(x_start),ybins(y_start)],[nG,1]),'Sigma',repmat(cov,[1,1,nG]),'ComponentProportion',ones(1,nG)./nG);
                    GModel = fitgmdist([data_x(valid),data_y(valid)],nG,'Start','plus','Options',statset('MaxIter',1000));
                end
                Res = zeros(1,6*nG);
                Res(1:6:end) = GModel.ComponentProportion;
                Res(2:6:end) = GModel.mu(:,1);
                Res(3:6:end) = GModel.mu(:,2);
                Res(4:6:end) = sqrt(GModel.Sigma(1,1,:));
                Res(5:6:end) = sqrt(GModel.Sigma(2,2,:));
                Res(6:6:end) = GModel.Sigma(1,2,:);
                Res(end+1) = GModel.NegativeLogLikelihood;
                Res(end+1) = GModel.BIC;
                BurstMeta.Fitting.FitResult = Res;
                % plot contour plot over image plot
                % hide contourf plot, make image plot visible
                %BurstMeta.Plots.Main_Plot(1).Visible = 'on';
                %BurstMeta.Plots.Main_Plot(2).Visible = 'off';
                for i = 1:nG
                    BurstMeta.Plots.Mixture.Main_Plot(i).Visible = 'on';
                    BurstMeta.Plots.Mixture.plotX(i).Visible = 'on';
                    BurstMeta.Plots.Mixture.plotY(i).Visible = 'on';
                end
                % prepare fit data
                if h.Hist_log10.Value; HH = 10.^(HH);end;
                xbins_fit = linspace(xbins(1)-min(diff(xbins)),xbins(end)+min(diff(xbins)),1000);
                ybins_fit = linspace(ybins(1)-min(diff(ybins)),ybins(end)+min(diff(ybins)),1000);
                [X,Y] = meshgrid(xbins_fit,ybins_fit);
                p = reshape(pdf(GModel,[X(:) Y(:)]),[1000,1000]);
                pX = sum(p,1);pX = pX./sum(pX).*sum(sum(HH))*1000/nbinsX;
                pY = sum(p,2);pY = pY./sum(pY).*sum(sum(HH))*1000/nbinsY;
                BurstMeta.Plots.Mixture.Main_Plot(1).XData = xbins_fit;
                BurstMeta.Plots.Mixture.Main_Plot(1).YData = ybins_fit;
                BurstMeta.Plots.Mixture.Main_Plot(1).ZData = p/sum(sum(p)).*sum(sum(HH))*1000^2/nbinsX/nbinsY;
                BurstMeta.Plots.Mixture.Main_Plot(1).LevelList = UserValues.BurstBrowser.Settings.IsoLineGaussFit*max(max(BurstMeta.Plots.Mixture.Main_Plot(1).ZData));%linspace(0,max(max(HH)),10);
                BurstMeta.Plots.Mixture.plotX(1).XData = xbins_fit;
                BurstMeta.Plots.Mixture.plotX(1).YData = pX;
                BurstMeta.Plots.Mixture.plotY(1).XData = ybins_fit;
                BurstMeta.Plots.Mixture.plotY(1).YData = pY;
                
                [Xdata,Ydata] = meshgrid(xbins,ybins);
                %%% Update subplots
                if nG > 1
                    for i = 1:nG
                        p_ind = mvnpdf([X(:) Y(:)],GModel.mu(i,:),GModel.Sigma(:,:,i));
                        p_ind = reshape(p_ind,[1000,1000]);
                        p_ind = p_ind./sum(sum(p_ind)).*sum(sum(HH)).*GModel.ComponentProportion(i)*1000^2/nbinsX/nbinsY;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).XData = xbins_fit;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).YData = ybins_fit;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).ZData = p_ind;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).LevelList = UserValues.BurstBrowser.Settings.IsoLineGaussFit*max(max(BurstMeta.Plots.Mixture.Main_Plot(i+1).ZData));%linspace(0,max(max(p_ind)),10);
                        p_ind_x = sum(p_ind,1);
                        BurstMeta.Plots.Mixture.plotX(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.plotX(i+1).XData = xbins_fit;
                        BurstMeta.Plots.Mixture.plotX(i+1).YData = p_ind_x./sum(p_ind_x).*sum(sum(HH)).*GModel.ComponentProportion(i)*1000/nbinsX;
                        p_ind_y = sum(p_ind,2);
                        BurstMeta.Plots.Mixture.plotY(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.plotY(i+1).XData = ybins_fit;
                        BurstMeta.Plots.Mixture.plotY(i+1).YData = p_ind_y./sum(p_ind_y).*sum(sum(HH)).*GModel.ComponentProportion(i)*1000/nbinsY;
                        %%% store for species assignment using data binning
                        p_ind = mvnpdf([Xdata(:) Ydata(:)],GModel.mu(i,:),GModel.Sigma(:,:,i));
                        p_ind = reshape(p_ind,[numel(xbins),numel(ybins)]);p_ind = p_ind./sum(sum(p_ind));
                        BurstMeta.Fitting.Species{i} = p_ind;
                        BurstMeta.Fitting.MeanX(i) = GModel.mu(i,1);
                        BurstMeta.Fitting.MeanY(i) = GModel.mu(i,2);
                    end
                end
                %%% output result in table
                h.Fit_Gaussian_Text.Data(1,1:3) = {double(GModel.Converged),GModel.NegativeLogLikelihood,GModel.BIC};
                for i = 1:nG
                    h.Fit_Gaussian_Text.Data(3+i,:) = {GModel.ComponentProportion(i),GModel.mu(i,1),GModel.mu(i,2),sqrt(GModel.Sigma(1,1,i)),sqrt(GModel.Sigma(2,2,i)),GModel.Sigma(1,2,i)};
                end
                if nG < 5
                    h.Fit_Gaussian_Text.Data(3+nG+1:end,:) = cell(5-nG,6);
                end
            end
        case 'LSQ'
            if x == y %%% same data selected, 1D fitting
                BurstMeta.Fitting.FitType = '1D';
                
                xbins_fit = linspace(xbins(1)-min(diff(xbins)),xbins(end)+min(diff(xbins)),1000);
                x_start = mean(data_x(isfinite(data_x)));
                %%% for non fixed values, take estimate
                %%% set fixed values to x0
                x0 = zeros(1,12);
                lb = zeros(1,12);
                ub = inf(1,12);
                fixed = false(1,12);
                for i = 1:5
                    x0((1+(i-1)*3):(3+(i-1)*3)) = cell2mat(h.Fit_Gaussian_Text.Data(i,[1,5,13]));
                    lb((1+(i-1)*3):(3+(i-1)*3)) = cell2mat(h.Fit_Gaussian_Text.Data(i,[2,6,14]));
                    ub((1+(i-1)*3):(3+(i-1)*3)) = cell2mat(h.Fit_Gaussian_Text.Data(i,[3,7,15]));
                    fixed((1+(i-1)*3):(3+(i-1)*3)) = cell2mat(h.Fit_Gaussian_Text.Data(i,[4,8,16]));
                end

                %%% set starting center values to mean values or picked
                for i = 1:nG
                    if ~fixed(2+(i-1)*3)
                        x0(2+(i-1)*3) = x_start;
                    end
                    if ~fixed(1+(i-1)*3)
                        x0(1+(i-1)*3) = 1/nG;
                    end
                end
                
                xdata = {xbins,sum(sum(HH)),fixed,nG,0};
                ydata = sum(HH,1);
                if UserValues.BurstBrowser.Settings.FitGauss_UseWeights
                    %%% add Poissonian error (sqrt(N))
                    err = sqrt(ydata);
                    err(err == 0) = 1;
                    xdata{end+1} = err;
                    ydata = ydata./err;
                end
                
                BurstMeta.GaussianFit.Params = x0;
                opt = optimoptions('lsqcurvefit','MaxFunEvals',10000);
                [x,~,residuals] = lsqcurvefit(@MultiGaussFit_1D,x0(~fixed),xdata,ydata,lb(~fixed),ub(~fixed),opt);
                
                chi2 = sum((residuals.^2)./max(1,ydata))./(sum(ydata>0)-1-sum(fixed));
                h.Fit_GaussianChi2_Text.String = sprintf('red. Chi2 = %.2f',chi2);
                
                Res = zeros(1,numel(fixed));
                Res(~fixed)=x;
                %%% Assigns parameters from table to fixed parameters
                Res(fixed)=BurstMeta.GaussianFit.Params(fixed);
                Res(1:3:end) = Res(1:3:end)./sum(Res(1:3:end));
                BurstMeta.Fitting.FitResult = [Res(1:3*nG), chi2];
                
                p = MultiGaussFit_1D(Res,{xbins_fit,sum(sum(HH)),fixed,nG,1});
                BurstMeta.Plots.Mixture.plotX(1).Visible = 'on';
                BurstMeta.Plots.Mixture.plotX(1).XData = xbins_fit;
                BurstMeta.Plots.Mixture.plotX(1).YData = p*1000/nbinsX;
                if nG > 1
                    for i = 1:nG
                        x_ind = Res;
                        for j = 1:nG %%% set other components to zero
                            if j ~=i
                                x_ind(1+(j-1)*3) = 0;
                            else
                                x_ind(1+(j-1)*3) = 1;
                            end
                        end
                        p_ind = MultiGaussFit_1D(x_ind,{xbins_fit,sum(sum(HH)),fixed,nG,1});
                        BurstMeta.Plots.Mixture.plotX(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.plotX(i+1).XData = xbins_fit;
                        BurstMeta.Plots.Mixture.plotX(i+1).YData = Res(1+(i-1)*3)*p_ind*1000/nbinsX;
                    end
                end
                 %%% output result in table
                Data = h.Fit_Gaussian_Text.Data;
                for i = 1:nG
                    Data(i,[1,5,13]) = num2cell(Res(1+(i-1)*3:3+(i-1)*3));
                end
                h.Fit_Gaussian_Text.Data = Data;
                
            else
                BurstMeta.Fitting.FitType = '2D';
                
                cov = [std(data_x).^2,std(data_y).^2,0];
                if h.Fit_Gaussian_Pick.Value
                    if verLessThan('MATLAB','9.5')
                        [x_start,y_start] = ginput(nG);
                    else %2018b onwards
                        [x_start,y_start] = my_ginput(nG);
                    end
                    x0_input = zeros(1,18);
                    for i = 1:nG
                        x0_input((1+(i-1)*6):(6+(i-1)*6)) = [1/nG,x_start(i),y_start(i),cov];
                    end
                    drawnow;
                end

                %%% for non fixed values, take estimate
                %%% set fixed values to x0
                x0 = zeros(1,24);
                lb = zeros(1,24);
                ub = inf(1,24);
                fixed = false(1,24);
                lowerx = min(data_x);
                lowery = min(data_y);
                upperx = max(data_x);
                uppery = max(data_y);
                for i = 1:5
                    x0((1+(i-1)*6):(6+(i-1)*6)) = cell2mat(h.Fit_Gaussian_Text.Data(i,1:4:end));
                    lb((1+(i-1)*6):(6+(i-1)*6)) = cell2mat(h.Fit_Gaussian_Text.Data(i,2:4:end));
                    lb(2+(i-1)*6) = max([lowerx lb(2+(i-1)*6)]);
                    lb(3+(i-1)*6) = max([lowery lb(3+(i-1)*6)]);
                    ub((1+(i-1)*6):(6+(i-1)*6)) = cell2mat(h.Fit_Gaussian_Text.Data(i,3:4:end));
                    ub(2+(i-1)*6) = min([upperx ub(2+(i-1)*6)]);
                    ub(3+(i-1)*6) = min([uppery ub(3+(i-1)*6)]);
                    fixed((1+(i-1)*6):(6+(i-1)*6)) = cell2mat(h.Fit_Gaussian_Text.Data(i,4:4:end));
                    %%% square sigma
                    x0([4,5]+(i-1)*6) = x0([4,5]+(i-1)*6).^2;
                    lb([4,5]+(i-1)*6) = lb([4,5]+(i-1)*6).^2;
                    ub([4,5]+(i-1)*6) = ub([4,5]+(i-1)*6).^2;
                end

                %%% set starting center values to mean values or picked values
                if h.Fit_Gaussian_Pick.Value
                    for i = 1:nG
                        if ~fixed(2+(i-1)*6)
                            x0(2+(i-1)*6) = x0_input(2+(i-1)*6);
                        end
                        if ~fixed(3+(i-1)*6)
                            x0(3+(i-1)*6) = x0_input(3+(i-1)*6);
                        end
                        %%% set amplitude to 1/N
                        if ~fixed(1+(i-1)*6)
                            x0(1+(i-1)*6) = 1/nG;
                        end
                    end
                end
                
                if h.Hist_log10.Value; HH = 10.^(HH);end;
                ydata = HH;
                xdata = {xbins,ybins,sum(sum(ydata)),fixed,nG,0};
                
                if UserValues.BurstBrowser.Settings.FitGauss_UseWeights
                    %%% add Poissonian error (sqrt(N))
                    err = sqrt(ydata);
                    err(err == 0) = 1;
                    xdata{end+1} = err;
                    ydata = ydata./err;
                end
                
                BurstMeta.GaussianFit.Params = x0;
                opt = optimoptions('lsqcurvefit','MaxFunEvals',10000);
                [x,~,residuals] = lsqcurvefit(@MultiGaussFit,x0(~fixed),xdata,ydata,lb(~fixed),ub(~fixed),opt);
                valid = (ydata ~= 0);
                if UserValues.BurstBrowser.Display.KDE
                    %%% no bin is zero, so use a different threshold as well
                    valid = valid & (ydata >= 1);
                end
                chi2 = sum(sum((residuals(valid).^2)./max(1,ydata(valid))))./(numel(ydata(valid))-1-sum(fixed));
                h.Fit_GaussianChi2_Text.String = sprintf('red. Chi2 = %.2f',chi2);
                
                Res = zeros(1,numel(fixed));
                Res(~fixed)=x;
                %%% Assigns parameters from table to fixed parameters
                Res(fixed)=BurstMeta.GaussianFit.Params(fixed);
                for i =1:nG
                    COV = [Res(4+(i-1)*6),Res(6+(i-1)*6);Res(6+(i-1)*6),Res(5+(i-1)*6)];
                    [~,f] = chol(COV);
                    if f~=0 %%% error
                        COV = fix_covariance_matrix(COV);
                    end
                    Res(4+(i-1)*6) = COV(1,1);
                    Res(6+(i-1)*6) = COV(1,2);
                    Res(5+(i-1)*6) = COV(2,2);
                end
                Res(1:6:end) = Res(1:6:end)./sum(Res(1:6:end));
                
                FitResult = Res;
                FitResult(4:6:end) = sqrt(FitResult(4:6:end));
                FitResult(5:6:end) = sqrt(FitResult(5:6:end));
                BurstMeta.Fitting.FitResult = [FitResult(1:6*nG),chi2];
                % hide contourf plot, make image plot visible
                %BurstMeta.Plots.Main_Plot(1).Visible = 'on';
                %BurstMeta.Plots.Main_Plot(2).Visible = 'off';
                for i = 1:nG
                    BurstMeta.Plots.Mixture.Main_Plot(i).Visible = 'on';
                    BurstMeta.Plots.Mixture.plotX(i).Visible = 'on';
                    BurstMeta.Plots.Mixture.plotY(i).Visible = 'on';
                end

                % prepare fit data
                xbins_fit = linspace(xbins(1)-min(diff(xbins)),xbins(end)+min(diff(xbins)),1000);
                ybins_fit = linspace(ybins(1)-min(diff(ybins)),ybins(end)+min(diff(ybins)),1000);
                p = MultiGaussFit(x,{xbins_fit,ybins_fit,sum(sum(HH)),fixed,nG,0});
                pX = sum(p,1);
                pY = sum(p,2);
                BurstMeta.Plots.Mixture.Main_Plot(1).XData = xbins_fit;
                BurstMeta.Plots.Mixture.Main_Plot(1).YData = ybins_fit;
                BurstMeta.Plots.Mixture.Main_Plot(1).ZData = p*1000^2/nbinsX/nbinsY;
                BurstMeta.Plots.Mixture.Main_Plot(1).LevelList = UserValues.BurstBrowser.Settings.IsoLineGaussFit*max(max(BurstMeta.Plots.Mixture.Main_Plot(1).ZData));%linspace(0,max(max(HH)),10);
                BurstMeta.Plots.Mixture.plotX(1).XData = xbins_fit;
                BurstMeta.Plots.Mixture.plotX(1).YData = pX*1000/nbinsX;
                BurstMeta.Plots.Mixture.plotY(1).XData = ybins_fit;
                BurstMeta.Plots.Mixture.plotY(1).YData = pY*1000/nbinsY;

                %%% Update subplots
                if nG > 1
                    for i = 1:nG
                        x_ind = Res;
                        for j = 1:nG %%% set other components to zero
                            if j ~=i
                                x_ind(1+(j-1)*6) = 0;
                            else
                                x_ind(1+(j-1)*6) = 1;
                            end
                        end
                        p_ind = MultiGaussFit(x_ind,{xbins_fit,ybins_fit,sum(sum(HH)),fixed,nG,1});
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).XData = xbins_fit;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).YData = ybins_fit;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).ZData = Res(1+(i-1)*6)*p_ind*1000^2/nbinsX/nbinsY;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).LevelList = UserValues.BurstBrowser.Settings.IsoLineGaussFit*max(max(BurstMeta.Plots.Mixture.Main_Plot(i+1).ZData));%linspace(0,max(max(p_ind)),10);
                        p_ind_x = sum(p_ind,1);
                        BurstMeta.Plots.Mixture.plotX(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.plotX(i+1).XData = xbins_fit;
                        BurstMeta.Plots.Mixture.plotX(i+1).YData = Res(1+(i-1)*6)*p_ind_x*1000/nbinsX;
                        p_ind_y = sum(p_ind,2);
                        BurstMeta.Plots.Mixture.plotY(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.plotY(i+1).XData = ybins_fit;
                        BurstMeta.Plots.Mixture.plotY(i+1).YData = Res(1+(i-1)*6)*p_ind_y*1000/nbinsY;
                        %%% store for species assignment using data binning
                        p_ind = MultiGaussFit(x_ind,{xbins,ybins,sum(sum(HH)),fixed,nG,1});
                        BurstMeta.Fitting.Species{i} = Res(1+(i-1)*6)*p_ind;
                        BurstMeta.Fitting.MeanX(i) = x_ind(2+(i-1)*6);
                        BurstMeta.Fitting.MeanY(i) = x_ind(3+(i-1)*6);
                    end
                end
                %%% make variance to sigma
                for i =1:5
                    Res([4,5]+(i-1)*6) = sqrt(Res([4,5]+(i-1)*6));
                end
                %%% output result in table
                Data = h.Fit_Gaussian_Text.Data;
                for i = 1:nG
                    Data(i,1:4:end) = num2cell(Res(1+(i-1)*6:6+(i-1)*6));
                end
                h.Fit_Gaussian_Text.Data = Data;
            end
    end
    if (paramx ~= paramy) && ~h.MultiselectOnCheckbox.UserData
        BurstMeta.Fitting.BurstBins = NaN(size(BurstData{file}.DataArray,1),2);
        BurstMeta.Fitting.BurstBins(BurstData{file}.Selected,:) = bin;
        BurstMeta.Fitting.BurstCount = H;
        BurstMeta.Fitting.ParamX = BurstData{file}.NameArray{paramx};
        BurstMeta.Fitting.ParamY = BurstData{file}.NameArray{paramy};
    end
    if advanced
        h.colorbar.Ticks = [h.colorbar.Limits(1) h.colorbar.Limits(1)+0.5*(h.colorbar.Limits(2)-h.colorbar.Limits(1)) h.colorbar.Limits(2)];
    end
    h.Progress_Text.String = 'Done';
    %%% set linecolor of bar plot to none
    BurstMeta.Plots.Main_histX(2).Color = 'none';
    BurstMeta.Plots.Main_histY(2).Color = 'none';
else
    %%% set linecolor of bar plot to black
    BurstMeta.Plots.Main_histX(2).Color = [0,0,0];
    BurstMeta.Plots.Main_histY(2).Color = [0,0,0];
end

drawnow;