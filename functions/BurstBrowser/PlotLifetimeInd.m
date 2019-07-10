%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Copies Selected Lifetime Plot to Individual Tab %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotLifetimeInd(obj,~,h)
global BurstMeta UserValues BurstData
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
%%% reset axis motion function (used for phasor plot to read out lifetimes)
h.BurstBrowser.WindowButtonMotionFcn = [];
h.axes_lifetime_ind_2d_textbox.String = '';
switch BurstData{file}.BAMethod
    case {1,2,5}
        switch h.lifetime_ind_popupmenu.Value
            case 1 %E vs tauGG
                origin = h.axes_EvsTauGG;
                switch UserValues.BurstBrowser.Settings.LifetimeMode
                    case 1
                        paramX = 'Lifetime D [ns]';
                        paramY = 'FRET Efficiency';
                    case 2
                        paramX = 'Lifetime D [ns]';
                        paramY = 'log(FD/FA)';
                    case 3
                        paramX = 'FRET Efficiency';
                        paramY = 'M1-M2';
                end                
            case 2 %E vs tauRR
                origin = h.axes_EvsTauRR;                
                switch UserValues.BurstBrowser.Settings.LifetimeMode
                    case 1
                        paramX = 'Lifetime A [ns]';
                        paramY = 'FRET Efficiency';
                    case 2
                        paramX = 'Lifetime A [ns]';
                        paramY = 'log(FD/FA)';
                    case 3
                        paramX = 'Lifetime A [ns]';
                        paramY = 'FRET Efficiency';
                end     
            case 3 %rGG vs tauGG
                origin = h.axes_rGGvsTauGG;
                paramX = 'Lifetime D [ns]';
                paramY = 'Anisotropy D';
            case 4 %rRR vs tauRR
                origin = h.axes_rRRvsTauRR;
                paramX = 'Lifetime A [ns]';
                paramY = 'Anisotropy A';
            case 5 % Phasor plot of g_d vs s_d                
                paramX = 'Phasor: gD';
                paramY = 'Phasor: sD';
            case 6 % Phasor plot of g_a vs s_a                
                paramX = 'Phasor: gA';
                paramY = 'Phasor: sA';
        end
    case {3,4}
        switch h.lifetime_ind_popupmenu.Value
            case 1 %E vs tauGG
                origin = h.axes_EvsTauGG;
                paramX = 'Lifetime GG [ns]';
                paramY = 'FRET Efficiency GR';                
            case 2 %E vs tauRR
                origin = h.axes_EvsTauRR;
                paramX = 'Lifetime RR [ns]';
                paramY = 'FRET Efficiency GR';
            case 3 %E1A vs tauBB
                origin = h.axes_E_BtoGRvsTauBB;
                paramX = 'Lifetime BB [ns]';
                paramY = 'FRET Efficiency B->G+R';
            case 4 %rGG vs tauGG
                origin = h.axes_rGGvsTauGG;
                paramX = 'Lifetime GG [ns]';
                paramY = 'Anisotropy GG';
            case 5 %rRR vs tauRR
                origin = h.axes_rRRvsTauRR;
                paramX = 'Lifetime RR [ns]';
                paramY = 'Anisotropy RR';
            case 6 %rBB vs tauBB
                origin = h.axes_rBBvsTauBB;
                paramX = 'Lifetime BB [ns]';
                paramY = 'Anisotropy BB';
        end
end
set(BurstMeta.Plots.LifetimeInd_histX,'Visible','on');
set(BurstMeta.Plots.LifetimeInd_histY,'Visible','on');
for i=1:numel(BurstMeta.Plots.MultiScatter.h1dx_lifetime)
    try;delete(BurstMeta.Plots.MultiScatter.h1dx_lifetime(i));end;
end
for i=1:numel(BurstMeta.Plots.MultiScatter.h1dy_lifetime)
    try;delete(BurstMeta.Plots.MultiScatter.h1dy_lifetime(i));end;
end
legend(h.axes_lifetime_ind_1d_x,'off');
cla(h.axes_lifetime_ind_2d);

if exist('origin','var') %%% simply copy the plots
    plots =origin.Children;
    for i = numel(plots):-1:1
        handle_temp = copyobj(plots(i),h.axes_lifetime_ind_2d);
        type{i} = plots(i).Type;
        handle_temp.UIContextMenu = h.ExportGraphLifetime_Menu;
    end

    h.axes_lifetime_ind_2d.XLim = origin.XLim;
    h.axes_lifetime_ind_2d.YLim = origin.YLim;
    h.axes_lifetime_ind_2d.XLabel.String = origin.XLabel.String;
    h.axes_lifetime_ind_2d.XLabel.Color = UserValues.Look.Fore;
    h.axes_lifetime_ind_2d.YLabel.String = origin.YLabel.String;
    h.axes_lifetime_ind_2d.YLabel.Color = UserValues.Look.Fore;
    h.axes_lifetime_ind_2d.CLimMode = 'auto';h.axes_lifetime_ind_2d.CLim(1) = 0;
    %%% find the image plot
    xdata = plots(strcmp(type,'image')).XData;
    ydata = plots(strcmp(type,'image')).YData;
    zdata = plots(strcmp(type,'image')).CData;
elseif ~isempty(strfind(paramX,'Phasor')) %%% phasor plot
    %%% data needs to be read out from the parameters
    idx_x = find(strcmp(BurstData{file}.NameArray,paramX));
    idx_y = find(strcmp(BurstData{file}.NameArray,paramY));
    %%% Read out the Number of Bins
    nbinsX = UserValues.BurstBrowser.Display.NumberOfBinsX;
    nbinsY = UserValues.BurstBrowser.Display.NumberOfBinsY;
    %%% set limits
    if ~(h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1)
        datatoplot = BurstData{file}.DataCut;
        min_max = max(datatoplot(:,idx_x))-min(datatoplot(:,idx_x));
        x_lim = [max([-0.1,min(datatoplot(:,idx_x))-0.1*min_max]),min([1.1,max(datatoplot(:,idx_x))+0.1*min_max])];
        min_max = max(datatoplot(:,idx_y))-min(datatoplot(:,idx_y));
        y_lim = [max([0,min(datatoplot(:,idx_y))-0.1*min_max]),min([0.75,max(datatoplot(:,idx_y))+0.1*min_max])];
        [H, xbins, ybins] = calc2dhist(datatoplot(:,idx_x), datatoplot(:,idx_y),[nbinsX nbinsY], x_lim, y_lim);
        datapoints = [datatoplot(:,idx_x), datatoplot(:,idx_y)];
    else
        NameArray = BurstData{file}.NameArray;
        [H,xbins,ybins,x_lim,y_lim,datapoints,n_per_species,H_ind] = MultiPlot([],[],h,NameArray{idx_x},NameArray{idx_y},{[-0.1,1.1],[-0.1,0.75]});
        if iscell(H)
            HH = zeros(numel(ybins),numel(xbins));
            for i = 1:numel(H)
                HH = HH+H{i};
            end
            H = HH;
        end
    end
    if(get(h.Hist_log10, 'Value'))
        H = log10(H);
        if UserValues.BurstBrowser.Display.KDE
            H = real(H);
        end
    end
    H = H/max(max(H));
    %%% copy the E vs tauA plot as template
    origin =  h.axes_EvsTauRR;
    plots = origin.Children;  
    for i = numel(plots):-1:1
        handle_temp = copyobj(plots(i),h.axes_lifetime_ind_2d);
        type{i} = plots(i).Type;
        handle_temp.UIContextMenu = h.ExportGraphLifetime_Menu;
    end
    %%% clear patches
    if numel(h.axes_lifetime_ind_2d.Children) > 3
        delete(h.axes_lifetime_ind_2d.Children(1:end-3));
    end
    c = flipud(h.axes_lifetime_ind_2d.Children);
    c(1).XData = xbins;
    c(1).YData = ybins;
    c(1).CData = H;
    if ~UserValues.BurstBrowser.Display.KDE
        c(1).AlphaData = H./max(max(H)) > UserValues.BurstBrowser.Display.ImageOffset/100;
    elseif UserValues.BurstBrowser.Display.KDE
        c(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
    end
    c(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
    c(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
    Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
    % replicate to fix edges
    Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
    Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
    c(2).ZData = Hcontour;
    c(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
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
        c(3).XData = datapoints(:,1);
        c(3).YData = datapoints(:,2);
        c(3).CData = colordata;
    end
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') & (numel(get_multiselection(h)) > 1) && UserValues.BurstBrowser.Display.Multiplot_Contour
        c(2).Visible = 'off';
        axes(h.axes_lifetime_ind_2d);
        % overlay contour plots
        colors = lines(numel(H_ind));
        ContourPatches = [];
        for i = 1:numel(H_ind)
            %level_list = max(H{i}(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,UserValues.BurstBrowser.Display.PlotCutoff/100,UserValues.BurstBrowser.Display.NumberOfContourLevels);
            [C,contour_plot] = contour(xbins,ybins,H_ind{i},UserValues.BurstBrowser.Display.NumberOfContourLevels,'LineColor','none');
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
        c(2).Visible = 'on';
    end
    xlim(h.axes_lifetime_ind_2d,x_lim);
    ylim(h.axes_lifetime_ind_2d,y_lim);
    h.axes_lifetime_ind_2d.CLimMode = 'auto';h.axes_lifetime_ind_2d.CLim(1) = 0;    
    %%% plot the universal circle
    if ~isempty(strfind(paramX,'gD'))
        h.axes_lifetime_ind_2d.XLabel.String = 'g_D';
        h.axes_lifetime_ind_2d.YLabel.String = 's_D';
        add_universal_circle(h.axes_lifetime_ind_2d,true); % with linker correction
    else
        h.axes_lifetime_ind_2d.XLabel.String = 'g_A';
        h.axes_lifetime_ind_2d.YLabel.String = 's_A';
        add_universal_circle(h.axes_lifetime_ind_2d);
    end
    xdata = xbins;
    ydata = ybins;
    zdata = H;
    
    origin = []; origin.XLim = x_lim; origin.YLim = y_lim;       
    origin.CLim = [0,max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100];
end
h.axes_lifetime_ind_2d.CLim = origin.CLim;
if(get(h.Hist_log10, 'Value')) % transform back for 1d hists
    zdata = 10.^zdata;
end
if sum(zdata(:)) == 0
    return;
end
histx = sum(zdata,1);
histy = sum(zdata,2);

BurstMeta.Plots.LifetimeInd_histX(1).XData = xdata;
BurstMeta.Plots.LifetimeInd_histX(1).YData = histx;
BurstMeta.Plots.LifetimeInd_histX(2).XData = [xdata,xdata(end)+min(diff(xdata))]-min(diff(xdata))/2;
BurstMeta.Plots.LifetimeInd_histX(2).YData = [histx, histx(end)];

BurstMeta.Plots.LifetimeInd_histY(1).XData = ydata;
BurstMeta.Plots.LifetimeInd_histY(1).YData = histy;
BurstMeta.Plots.LifetimeInd_histY(2).XData = [ydata,ydata(end)+min(diff(ydata))]-min(diff(ydata))/2;
BurstMeta.Plots.LifetimeInd_histY(2).YData = [histy; histy(end)];

h.axes_lifetime_ind_1d_x.XLim = origin.XLim;
h.axes_lifetime_ind_1d_y.XLim = origin.YLim;
try;h.axes_lifetime_ind_1d_x.YLim = [0,max(histx)*1.05];end;
try;h.axes_lifetime_ind_1d_y.YLim = [0,max(histy)*1.05];end;

if h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1 %%% multiple species selected, color automatically
    [H,xbins,ybins,xlimits,ylimits,datapoints,n_per_species] = MultiPlot([],[],h,paramX,paramY,{origin.XLim,origin.YLim});
    normalize = UserValues.BurstBrowser.Settings.Normalize_Multiplot && ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex');
    if gcbo ~= h.MultiPlotButton
        %%% prepare 1d hists
        binsx = linspace(xlimits(1),xlimits(2),numel(xbins)+1);
        binsy = linspace(ylimits(1),ylimits(2),numel(ybins)+1);
        n_per_species = cumsum([1,(n_per_species-1)]);
        for i = 1:numel(n_per_species)-1
            hx{i} = histcounts(datapoints(n_per_species(i):n_per_species(i+1),1),binsx); 
            if normalize;
                switch UserValues.BurstBrowser.Settings.Normalize_Method
                    case 'area'
                        hx{i} = hx{i}./sum(hx{i});
                    case 'max'
                        hx{i} = hx{i}./max(hx{i});
                end
            end;
            hy{i} = histcounts(datapoints(n_per_species(i):n_per_species(i+1),2),binsy); 
            if normalize;
                switch UserValues.BurstBrowser.Settings.Normalize_Method
                    case 'area'
                        hy{i} = hy{i}./sum(hy{i});
                    case 'max'
                        hy{i} = hy{i}./max(hy{i});
                end
            end;
        end
        color = lines(numel(n_per_species));
        for i = 1:numel(hx)
            BurstMeta.Plots.MultiScatter.h1dx_lifetime(i) = handle(stairs(binsx,[hx{i},hx{i}(end)],'Color',color(i,:),'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_x));
            BurstMeta.Plots.MultiScatter.h1dy_lifetime(i) = handle(stairs(binsy,[hy{i},hy{i}(end)],'Color',color(i,:),'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_y));
        end
        if UserValues.BurstBrowser.Settings.Display_Total_Multiplot
            hx_total = sum(vertcat(hx{:}),1);hy_total = sum(vertcat(hy{:}),1);
            BurstMeta.Plots.MultiScatter.h1dx_lifetime(end+1) = handle(stairs(binsx,[hx_total,hx_total(end)],'Color',[0,0,0],'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_x));
            BurstMeta.Plots.MultiScatter.h1dy_lifetime(end+1) = handle(stairs(binsy,[hy_total,hy_total(end)],'Color',[0,0,0],'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_y));
        end
    elseif gcbo == h.MultiPlotButton
        if (numel(H) > 3) & ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour')
            H = H(1:3); % limit to 3
        elseif (numel(H) > 6) & strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour')
            H = H(1:6); % limit to 6
        end
        
        del = false(numel(h.axes_lifetime_ind_2d.Children),1);
        for k = 1:numel(h.axes_lifetime_ind_2d.Children)
            if ~strcmp(h.axes_lifetime_ind_2d.Children(k).Type,'line')
                del(k) = true;
            end
        end
        delete(h.axes_lifetime_ind_2d.Children(del));
        
        normalize = UserValues.BurstBrowser.Settings.Normalize_Multiplot;
        
        if ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour')
            [zz,color] = overlay_colored(H);
            multiplot = imagesc(h.axes_lifetime_ind_2d,xbins,ybins,zz);
            uistack(multiplot,'bottom'); multiplot.UIContextMenu = h.ExportGraphLifetime_Menu;
            white = 1-UserValues.BurstBrowser.Display.MultiPlotMode;
            %%% set alpha property
            if white == 0
                multiplot.AlphaData = sum(zz,3)>0;
            else
                multiplot.AlphaData = 1-(sum(zz,3)==3);
            end
        elseif strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour')
            axes(h.axes_lifetime_ind_2d);
            % overlay contour plots
            colors = lines(numel(H));
            ContourPatches = [];
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
            color = colors;
        end
        
        %plot first histogram
        hx = sum(H{1},1);
        if normalize
            switch UserValues.BurstBrowser.Settings.Normalize_Method
                case 'area'
                    hx = hx./sum(hx);
                case 'max'
                    hx = hx./max(hx);
            end
        end
        hx = hx'; hx = [hx; hx(end)];
        xbins = [xbins, xbins(end)+min(diff(xbins))]-min(diff(xbins))/2;
        BurstMeta.Plots.MultiScatter.h1dx_lifetime(1) = handle(stairs(xbins,hx,'Color',color(1,:),'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_x));
        %plot rest of histograms
        for i = 2:numel(H)
            hx = sum(H{i},1);
            if normalize
                switch UserValues.BurstBrowser.Settings.Normalize_Method
                    case 'area'
                        hx = hx./sum(hx);
                    case 'max'
                        hx = hx./max(hx);
                end
            end
            hx = hx'; hx = [hx; hx(end)];
            BurstMeta.Plots.MultiScatter.h1dx_lifetime(i) = handle(stairs(xbins,hx,'Color',color(i,:),'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_x));
        end
        
        %plot first histogram
        hy = sum(H{1},2);
        if normalize
            switch UserValues.BurstBrowser.Settings.Normalize_Method
                case 'area'
                    hy = hy./sum(hy);
                case 'max'
                    hy = hy./max(hy);
            end
        end
        hy = [hy; hy(end)];
        ybins = [ybins, ybins(end)+min(diff(ybins))]-min(diff(ybins))/2;
        BurstMeta.Plots.MultiScatter.h1dy_lifetime(1) = handle(stairs(ybins,hy,'Color',color(1,:),'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_y));
        %plot rest of histograms
        for i = 2:numel(H)
            hy = sum(H{i},2);
            if normalize
                switch UserValues.BurstBrowser.Settings.Normalize_Method
                    case 'area'
                        hy = hy./sum(hy);
                    case 'max'
                        hy = hy./max(hy);
                end
            end
            hy = [hy; hy(end)];
            BurstMeta.Plots.MultiScatter.h1dy_lifetime(i) = handle(stairs(ybins,hy,'Color',color(i,:),'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_y));
        end
    end
    %%% hide normal 1d plots
    set(BurstMeta.Plots.LifetimeInd_histX,'Visible','off');
    set(BurstMeta.Plots.LifetimeInd_histY,'Visible','off');
    
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
    if gcbo ~= h.MultiPlotButton
        if UserValues.BurstBrowser.Settings.Display_Total_Multiplot
            legend(h.axes_lifetime_ind_1d_x.Children((num_species+1):-1:2),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
        else
            legend(h.axes_lifetime_ind_1d_x.Children(num_species:-1:1),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
        end
    elseif gcbo ==  h.MultiPlotButton
        legend(h.axes_lifetime_ind_1d_x.Children(num_species:-1:1),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
    end
    h.axes_lifetime_ind_1d_x.YLimMode = 'auto';
    h.axes_lifetime_ind_1d_y.YLimMode = 'auto';
end
h.axes_lifetime_ind_1d_x.YTickMode = 'auto';
yticks= get(h.axes_lifetime_ind_1d_x,'YTick');
set(h.axes_lifetime_ind_1d_x,'YTick',yticks(2:end));
h.axes_lifetime_ind_1d_y.YTickMode = 'auto';
yticks= get(h.axes_lifetime_ind_1d_y,'YTick');
set(h.axes_lifetime_ind_1d_y,'YTick',yticks(2:end));