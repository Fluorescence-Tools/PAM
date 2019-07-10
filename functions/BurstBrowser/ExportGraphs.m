%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export Graphs to PNG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hfig, FigureName] = ExportGraphs(obj,~,ask_file)
global BurstData UserValues BurstMeta
file = BurstMeta.SelectedFile;
if nargin < 3
    ask_file = 1;
end
h = guidata(obj);
fontsize = 20;
if ispc
    fontsize = fontsize/1.3;
end

% just export data, no plot
if any(obj==[h.Export1DX_Data_Menu,h.Export1DY_Data_Menu,h.Export2D_Data_Menu])
    switch obj
        case {h.Export1DX_Data_Menu, h.Export1DY_Data_Menu}
            switch obj
                case h.Export1DX_Data_Menu
                    ax = h.axes_1d_x;
                case h.Export1DY_Data_Menu
                    ax = h.axes_1d_y;
            end
            Data = [get(ax.Children(end-1),'XData')', get(ax.Children(end-1),'YData')'];
        case h.Export2D_Data_Menu
            ax = h.axes_general;
            Data = zeros(numel(ax.Children(end).XData)+1);
            Data(2:end,1) = ax.Children(end).YData;
            Data(1,2:end) = ax.Children(end).XData;
            Data(2:end,2:end) = ax.Children(end).CData;
    end
    %%% copy Data to clipboard
    Mat2clip(Data);
    return;
end

size_pixels = 500;
switch obj
    case h.Export1DX_Menu
        %%% Create a new figure with aspect ratio appropiate for the current plot
        %%% i.e. 1.2*[x y]
        AspectRatio = 0.7;
        pos = [100,100, round(1.2*size_pixels),round(1.2*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1],'Visible','on');
        %%% Copy axes to figure
        axes_copy = copyobj(h.axes_1d_x,hfig);
        %%% Rescale Position
        axes_copy.Position = [0.15 0.19 0.8 0.78];
        %%% Increase fontsize
        axes_copy.FontSize = fontsize;
        %%% change Background Color
        axes_copy.Color = [1,1,1];
        %%% change X/YColor Color Color
        axes_copy.XColor = [0,0,0];
        axes_copy.YColor = [0,0,0];
        axes_copy.XLabel.Color = [0,0,0];
        axes_copy.YLabel.Color = [0,0,0];
        %%% Reset XAxis Location
        axes_copy.XAxisLocation = 'bottom';
        %%% Make Ticks point Outwards
        axes_copy.TickDir = 'out';
        %%% Disable Box
        axes_copy.Box = 'off';
        %%% Change FaceColor of BarPlot
        %axes_copy.Children(end-1).FaceColor = [0.5 0.5 0.5];
        %axes_copy.Children(4).LineWidth = 1;
        %%% Redo YAxis Label
        axes_copy.YTickMode = 'auto';
        %%% Set XLabel
        xlabel(BurstData{file}.NameArray{h.ParameterListX.Value},'FontSize',fontsize);
        ylabel('Frequency','FontSize',fontsize);
        axes_copy.XTickLabelMode = 'auto';
        %%% Construct Name
        FigureName = BurstData{file}.NameArray{h.ParameterListX.Value};
        %%%remove text
        del = false(numel(axes_copy.Children),1);
        for i = 1:numel(axes_copy.Children)
            if strcmp(axes_copy.Children(i).Type,'text')
                del(i) = true;
            end
        end
        delete(axes_copy.Children(del));
        if (h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1)
            %%% Multiplot is used (first stair plot is visible)
            %%% delete all invisible plots
            del = false(numel(axes_copy.Children),1);
            for i = 1:numel(axes_copy.Children);
                if strcmp(axes_copy.Children(i).Visible, 'off')
                    del(i) = true;
                end
            end
            delete(axes_copy.Children(del));
            if numel(axes_copy.Children)>1
                handle_legend = [];
                if verLessThan('MATLAB','9.1')
                    % 2016a and earlier
                    % find the legend
                    if sum(strcmp(get(h.axes_1d_x.Parent.Children,'Type'),'legend')) > 0
                        handle_legend = h.axes_1d_x.Parent.Children(strcmp(get(h.axes_1d_x.Parent.Children,'Type'),'legend'));
                    end
                else % 2016b and upwards
                    if ~isempty(h.axes_1d_x.Legend)
                        handle_legend = h.axes_1d_x.Legend;                        
                    end
                end
                if ~isempty(handle_legend)
                    hl = legend(handle_legend.String);
                    hl.Box = 'off';
                    hfig.Units = 'pixel';
                    axes_copy.Units = 'pixel';
                    hl.Units = 'pixel';
                    hl.FontSize = 12;
                    hfig.Position(4) = hfig.Position(4) + 75;
                    if ~verLessThan('MATLAB','9.1') % 2016b and upwards
                        hl.Position(2) =  hl.Position(2)+75;
                    end
                    hl.Position(1) = 40;
                end
            end
        end
    case h.Export1DY_Menu
        AspectRatio = 0.7;
        pos = [100,100, round(1.2*size_pixels),round(1.2*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1],'Visible','on');
        %%% Copy axes to figure
        axes_copy = copyobj(h.axes_1d_y,hfig);
        %%% flip axes
        axes_copy.View = [0,90];
        %%% Reverse XDir
        axes_copy.XDir = 'normal';
        %%% Rescale Position
        axes_copy.Position = [0.15 0.19 0.8 0.78];
        %%% Increase fontsize
        axes_copy.FontSize = fontsize;
        %%% change Background Color
        axes_copy.Color = [1,1,1];
        %%% change X/YColor Color Color
        axes_copy.XColor = [0,0,0];
        axes_copy.YColor = [0,0,0];
        axes_copy.XLabel.Color = [0,0,0];
        axes_copy.YLabel.Color = [0,0,0];
        %%% Reset XAxis Location
        axes_copy.XAxisLocation = 'bottom';
        %%% Make Ticks point Outwards
        axes_copy.TickDir = 'out';
        %%% Disable Box
        axes_copy.Box = 'off';
        %%% Change FaceColor of BarPlot
        %axes_copy.Children(4).FaceColor = [0.5 0.5 0.5];
        %axes_copy.Children(4).LineWidth = 3;
        %%% Redo YAxis Label
        axes_copy.YTickMode = 'auto';
        %%% Set XLabel
        xlabel(BurstData{file}.NameArray{h.ParameterListY.Value},'FontSize',fontsize);
        ylabel('Frequency','FontSize',fontsize);
        axes_copy.XTickLabelMode = 'auto';
        %%% Construct Name
        FigureName = BurstData{file}.NameArray{h.ParameterListY.Value};
        %%%remove text
        del = false(numel(axes_copy.Children),1);
        for i = 1:numel(axes_copy.Children)
            if strcmp(axes_copy.Children(i).Type,'text')
                del(i) = true;
            end
        end
        delete(axes_copy.Children(del));
        if (h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1)
            %%% Multiplot is used (first stair plot is visible)
            %%% delete all invisible plots
            del = false(numel(axes_copy.Children),1);
            for i = 1:numel(axes_copy.Children);
                if strcmp(axes_copy.Children(i).Visible, 'off')
                    del(i) = true;
                end
            end
            delete(axes_copy.Children(del));
            if numel(axes_copy.Children)>1
                if ~isempty(h.axes_1d_x.Legend)
                    hl = legend(h.axes_1d_x.Legend.String);
                    hl.Box = 'off';
                    hfig.Units = 'pixel';
                    axes_copy.Units = 'pixel';
                    hl.Units = 'pixel';
                    hl.FontSize = 12;
                    hfig.Position(4) = hfig.Position(4) + 75;
                    hl.Position(2) =  hl.Position(2)+75;                
                    hl.Position(1) = 40;
                end
            end
        end
    case h.Export2D_Menu
        AspectRatio = 1;
        pos = [100,100, round(1.3*size_pixels),round(1.2*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1],'Visible','on');
        %%% Copy axes to figure
        panel_copy = copyobj(h.MainTabGeneralPanel,hfig);
        panel_copy.ShadowColor = [1 1 1];
        %%% set Background Color to white
        panel_copy.BackgroundColor = [1 1 1];
        panel_copy.HighlightColor = [1 1 1];
        %%% Update ColorMap
        if ischar(UserValues.BurstBrowser.Display.ColorMap)
            if ~UserValues.BurstBrowser.Display.ColorMapFromWhite
                colormap(UserValues.BurstBrowser.Display.ColorMap);
            else
                if ~strcmp(UserValues.BurstBrowser.Display.ColorMap,'jet')
                    colormap(colormap_from_white(UserValues.BurstBrowser.Display.ColorMap));
                else %%% jet is a special case, use jetvar colormap
                    colormap(jetvar);
                end
            end
        else
            colormap(UserValues.BurstBrowser.Display.ColorMap);
        end
        if UserValues.BurstBrowser.Display.ColorMapInvert
            colormap(h.BurstBrowser,flipud(colormap));
        end
        %%% Remove non-axes object
        del = zeros(numel(panel_copy.Children),1);
        for i = 1:numel(panel_copy.Children)
            if ~strcmp(panel_copy.Children(i).Type,'axes')
                if ~strcmp(panel_copy.Children(i).Type,'legend')
                    del(i) = 1;
                end
            end
        end
        delete(panel_copy.Children(logical(del)));
        
        for i = 1:numel(panel_copy.Children)
            if strcmp(panel_copy.Children(i).Type,'legend')
                continue;
            end
            %%% Set the Color of Axes to white
            panel_copy.Children(i).Color = [1 1 1];
            %%% change X/YColor Color Color
            panel_copy.Children(i).XColor = [0,0,0];
            panel_copy.Children(i).YColor = [0,0,0];
            %%% Increase FontSize
            panel_copy.Children(i).FontSize = fontsize;
            %panel_copy.Children(i).Layer = 'bottom'; %put the grid lines (axis) below the plot
            %%% Reorganize Axes Positions
            switch panel_copy.Children(i).Tag
                case 'Axes_1D_Y'
                    panel_copy.Children(i).Position = [0.77 0.135 0.15 0.65];
                    panel_copy.Children(i).YTickLabelRotation = 270;
                    lim = 0;
                    for j = 1:numel(panel_copy.Children(i).Children)
                        if strcmp(panel_copy.Children(i).Children(j).Type,'text')
                            delete(panel_copy.Children(i).Children(j));
                            continue;
                        end
                        if strcmp(panel_copy.Children(i).Children(j).Visible,'on')
                            lim = max([lim,max(panel_copy.Children(i).Children(j).YData)*1.05]);
                        end
                    end
                    set(panel_copy.Children(i),'YTickLabelRotation',0);
                    panel_copy.Children(i).YLim = [0, lim];
                    panel_copy.Children(i).YTickMode = 'auto';
                    panel_copy.Children(i).YTickLabel = [];
                    panel_copy.Children(i).YLabel.String = '';
                    panel_copy.Children(i).YGrid = 'off';
                    panel_copy.Children(i).XGrid = 'off';
                    panel_copy.Children(i).Layer = 'top';
                    %yticks = get(panel_copy.Children(i),'YTick');
                    %set(panel_copy.Children(i),'YTick',yticks(2:end));
                    % change the grayscale of the bars and remove the line
                    if strcmp(panel_copy.Children(i).Children(9).Type,'bar')
                        panel_copy.Children(i).Children(9).FaceColor = [0.7 0.7 0.7];
                        panel_copy.Children(i).Children(9).LineStyle = 'none';
                    end
                case 'Axes_1D_X'
                    drawnow;
                    panel_copy.Children(i).Position = [0.12 0.785 0.65 0.15];
                    xlabel(panel_copy.Children(i),'');
                    lim = 0;
                    for j = 1:numel(panel_copy.Children(i).Children)
                        if strcmp(panel_copy.Children(i).Children(j).Type,'text')
                            delete(panel_copy.Children(i).Children(j));
                            continue;
                        end
                        if strcmp(panel_copy.Children(i).Children(j).Visible,'on')
                            lim = max([lim,max(panel_copy.Children(i).Children(j).YData)*1.05]);
                        end
                    end
                    panel_copy.Children(i).YLim = [0, lim];
                    panel_copy.Children(i).YTickMode = 'auto';
                    panel_copy.Children(i).YTickLabel = [];
                    panel_copy.Children(i).YLabel.String = '';
                    panel_copy.Children(i).YGrid = 'off';
                    panel_copy.Children(i).XGrid = 'off';
                    panel_copy.Children(i).Layer = 'top';
                    %yticks = get(panel_copy.Children(i),'YTick');
                    %set(panel_copy.Children(i),'YTick',yticks(2:end));
                    panel_copy.Children(i).XTickLabelMode = 'auto';
                    % change the grayscale of the bars and remove the line
                    if strcmp(panel_copy.Children(i).Children(9).Type,'bar')
                        panel_copy.Children(i).Children(9).FaceColor = [0.7 0.7 0.7];
                        panel_copy.Children(i).Children(9).LineStyle = 'none';
                    end
                    ax1dx = i;
                case 'Axes_General'
                    panel_copy.Children(i).XLabel.Color = [0 0 0];
                    panel_copy.Children(i).YLabel.Color = [0 0 0];
                    panel_copy.Children(i).Position = [0.12 0.135 0.65 0.65];
                    ax2d = i;
                case 'axes_ZScale'
                    if strcmp(panel_copy.Children(i).Visible,'on')
                        panel_copy.Children(i).Position = [0.77,0.785,0.15,0.13];
                    end
                    panel_copy.Children(i).YGrid = 'off';
            end
        end
        %%% Update Colorbar by plotting it anew
        %%% multiplot is NOT used
        if any(cell2mat(h.CutTable.Data(:,6))) && ~(h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1)  %%% colored by parameter
            cbar = colorbar(panel_copy.Children(4),'Location','north','Color',[0 0 0],'FontSize',fontsize-8); 
            %panel_copy.Children(3).XTickLabel(end) = {' '};
            param = h.CutTable.Data{cell2mat(h.CutTable.Data(:,6)),1};
            param = param(23:end-18); %%% remove html string
            cbar.Position = [0.77,0.915,0.15,0.02];
            cbar.AxisLocation = 'out';
            cbar.Label.String = 'Occurrence';
            cbar.Label.Units = 'normalized';
            cbar.Label.Position = [0.5,2.85,0];
            cbar.Label.String = param;
            cbar.Ticks = [cbar.Limits(1), cbar.Limits(1) + 0.5*(cbar.Limits(2)-cbar.Limits(1)),cbar.Limits(2)];
            zlim = [h.CutTable.Data{cell2mat(h.CutTable.Data(:,6)),2} h.CutTable.Data{cell2mat(h.CutTable.Data(:,6)),3}];
            cbar.TickLabels = {sprintf('%.1f',(zlim(1)));sprintf('%.1f',zlim(1)+(zlim(2)-zlim(1))/2);sprintf('%.1f',zlim(2))};
            if (panel_copy.Children(3).XLim(2) - panel_copy.Children(3).XTick(end))/(panel_copy.Children(3).XLim(2)-panel_copy.Children(3).XLim(1)) < 0.05 %%% Last XTick Label is at the end of the axis and thus overlaps with colorbar
                panel_copy.Children(3).XTickLabel{end} = '';
            end
        elseif ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter') %%% only occurence
            for n = 1:numel(panel_copy.Children)
                if strcmp(panel_copy.Children(n).Tag,'Axes_General')
                    ax2d = n;
                elseif strcmp(panel_copy.Children(n).Tag,'Axes_1D_X')
                    ax1dx = n;
                end
            end
            panel_copy.Children(ax1dx).XTickLabel = panel_copy.Children(ax2d).XTickLabel; 
            % for some strange reason, the below colorbar will be part of panel_copy.Children, before the Axes_General 
            cbar = colorbar('peer', panel_copy.Children(ax2d),'Location','north','Color',[0 0 0],'FontSize',fontsize-6); 
            cbar.Position = [0.8,0.85,0.18,0.025];
            cbar.Label.String = 'Occurrence';
            cbar.Limits(1) = 0;
            cbar.TicksMode = 'auto';
            cbar.TickLabelsMode = 'auto';
        end
        for n = 1:numel(panel_copy.Children)
            if strcmp(panel_copy.Children(n).Tag,'Axes_1D_X')
                ax1dx = n;
            end
        end
        if (h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1)
            %%% (if multi plot is used, first stair plot is visible)
            %%% if multiplot, extend figure and shift legend upstairs
            %%% delete the zscale axis
            for i = 1:numel(hfig.Children(end).Children)
                if strcmp(hfig.Children(end).Children(i).Tag,'axes_ZScale')
                    del = i;
                end
            end
            delete(hfig.Children(end).Children(del));
            %%% Set all units to pixels for easy editing without resizing
            hfig.Units = 'pixels';
            panel_copy.Units = 'pixels';
            for i = 1:numel(panel_copy.Children)
                if isprop(panel_copy.Children(i),'Units');
                    panel_copy.Children(i).Units = 'pixels';
                end
            end
            %%% refind legend item
            leg = [];
            for i = 1:numel(panel_copy.Children)
                if strcmp(panel_copy.Children(i).Type,'legend')
                    leg = i;
                end
            end
            if ~isempty(leg)
                if strcmp(panel_copy.Children(leg).Visible,'on')
                    hfig.Position(4) = 650;
                    panel_copy.Position(4) = 650;
                    panel_copy.Children(leg).Position(1) = 40;
                    panel_copy.Children(leg).Position(2) = 590;
                end
            end
            %%% hide colorbar if it exists
            if exist('cbar','var')
                %cbar.Visible = 'off';
            end
        end
        if UserValues.BurstBrowser.Display.ColorMapInvert
            colormap(flipud(colormap));
        end
        %%% check if occurrence scale in BurstBrowser is visible
        if strcmp(h.colorbar.Visible,'off')
            cbar.Visible = 'off';
        end
        if ~UserValues.BurstBrowser.Display.PlotGridAboveData
            %%% create dummy axis to prevent data overlapping the axis
            ax2d = findobj(panel_copy.Children,'Tag','Axes_General');
            ax_dummy = axes('Parent',panel_copy,'Units',ax2d.Units,'Position',ax2d.Position);
            %linkaxes([ax2d ax_dummy]);
            set(ax_dummy,'Color','none','XTick',ax2d.XTick,'YTick',ax2d.YTick,'XTickLAbel',[],'YTickLabel',[],...
                'LineWidth',1,'Box','on','XLim',ax2d.XLim, 'YLim', ax2d.YLim);
        end
        FigureName = [BurstData{file}.NameArray{h.ParameterListX.Value} '_' BurstData{file}.NameArray{h.ParameterListY.Value}];
    case h.ExportLifetime_Menu
        fontsize = 20;
        if ispc
            fontsize = fontsize/1.3;
        end
        AspectRatio = 1;
        pos = [100,100, round(1.6*size_pixels),round(1.6*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1]);
        %%% Copy axes to figure
        panel_copy = copyobj(h.LifetimePanelAll,hfig);
        panel_copy.ShadowColor = [1 1 1];
        panel_copy.HighlightColor = [1 1 1];
        %%% set Background Color to white
        panel_copy.BackgroundColor = [1 1 1];
        %%% Update ColorMap
        if ischar(UserValues.BurstBrowser.Display.ColorMap)
            if ~UserValues.BurstBrowser.Display.ColorMapFromWhite
                colormap(UserValues.BurstBrowser.Display.ColorMap);
            else
                if ~strcmp(UserValues.BurstBrowser.Display.ColorMap,'jet')
                    colormap(colormap_from_white(UserValues.BurstBrowser.Display.ColorMap));
                else %%% jet is a special case, use jetvar colormap
                    colormap(jetvar);
                end
            end
        else
            colormap(UserValues.BurstBrowser.Display.ColorMap);
        end
        if any(BurstData{file}.BAMethod == [1,2,5])
            for i = 1:numel(panel_copy.Children)
                %%% Set the Color of Axes to white
                panel_copy.Children(i).Color = [1 1 1];
                %%% change X/YColor Color Color
                panel_copy.Children(i).XColor = [0,0,0];
                panel_copy.Children(i).YColor = [0,0,0];
                panel_copy.Children(i).XLabel.Color = [0,0,0];
                panel_copy.Children(i).YLabel.Color = [0,0,0];
                %%% Increase FontSize
                panel_copy.Children(i).FontSize = fontsize;
                %%% Make Bold
                %panel_copy.Children(i).FontWeight = 'bold';
                %%% disable titles
                title(panel_copy.Children(i),'');
                %panel_copy.Children(i).Layer = 'bottom';
                %%% move axes up and left
                panel_copy.Children(i).Position = panel_copy.Children(i).Position + [0.01 0.02 0 0];
                if any(i==[1,2])
                    panel_copy.Children(i).YLabel.Units = 'normalized';
                    panel_copy.Children(i).YLabel.Position = [-0.16 0.5 0];
                end
                %%% Add rotational correlation time
                if isfield(BurstData{file},'Parameters')
                    switch i
                        case 1
                            %%%rRR vs TauRR
                            if isfield(BurstData{file}.Parameters,'rhoRR')
                                if ~isempty(BurstData{file}.Parameters.rhoRR)
                                    str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoRR(1))];
                                    if numel(BurstData{file}.Parameters.rhoRR) > 1
                                        str = {[str(1:4) '_1' str(5:end)]};
                                        for j=2:numel(BurstData{file}.Parameters.rhoRR)
                                            str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoRR(j))];
                                        end
                                    end
                                end
                            end
                            text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                            %'BackgroundColor',[1 1 1],...
                            %'EdgeColor',[0 0 0]);
                        case 2
                            %%%rGG vs TauGG
                            if isfield(BurstData{file}.Parameters,'rhoGG')
                                if ~isempty(BurstData{file}.Parameters.rhoGG)
                                    str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoGG(1))];
                                    if numel(BurstData{file}.Parameters.rhoGG) > 1
                                        str = {[str(1:4) '_1' str(5:end)]};
                                        for j=2:numel(BurstData{file}.Parameters.rhoGG)
                                            str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoGG(j))];
                                        end
                                    end
                                end
                            end
                            text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                            %'BackgroundColor',[1 1 1],...
                            %'EdgeColor',[0 0 0]);
                    end
                end
            end
        elseif any(BurstData{file}.BAMethod == [3,4])
            hfig.Position(3) = hfig.Position(3)*1.55;
            %hfig.Position(4) = hfig.Position(3)*1.1;
            
            for i = 1:numel(panel_copy.Children)
                %%% Set the Color of Axes to white
                panel_copy.Children(i).Color = [1 1 1];
                %%% Move axis to top of stack
                %panel_copy.Children(i).Layer = 'bottom';
                %%% change X/YColor Color Color
                panel_copy.Children(i).XColor = [0,0,0];
                panel_copy.Children(i).YColor = [0,0,0];
                panel_copy.Children(i).XLabel.Color = [0,0,0];
                panel_copy.Children(i).YLabel.Color = [0,0,0];
                %%% Increase FontSize
                panel_copy.Children(i).FontSize = fontsize;
                %%% Make Bold
                %panel_copy.Children(i).FontWeight = 'bold';
                %%% disable titles
                title(panel_copy.Children(i),'');
                %%% move axes up and left
                panel_copy.Children(i).Position = panel_copy.Children(i).Position + [0.01 0.02 0 0];
                if any(i==[1,3,4])
                    panel_copy.Children(i).YLabel.Units = 'normalized';
                    panel_copy.Children(i).YLabel.Position = [-0.16 0.5 0];
                end
                %%% Add rotational correlation time
                if isfield(BurstData{file},'Parameters')
                    switch i
                        case 1
                            %%%rBB vs TauBB
                            if isfield(BurstData{file}.Parameters,'rhoBB')
                                if ~isempty(BurstData{file}.Parameters.rhoBB)
                                    str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoBB(1))];
                                    if numel(BurstData{file}.Parameters.rhoBB) > 1
                                        str = {[str(1:4) '_1' str(5:end)]};
                                        for j=2:numel(BurstData{file}.Parameters.rhoBB)
                                            str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoBB(j))];
                                        end
                                    end
                                end
                            end
                            text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                            %'BackgroundColor',[1 1 1],...
                            %'EdgeColor',[0 0 0]);
                        case 3
                            %%%rRR vs TauRR
                            if isfield(BurstData{file}.Parameters,'rhoRR')
                                if ~isempty(BurstData{file}.Parameters.rhoRR)
                                    str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoRR(1))];
                                    if numel(BurstData{file}.Parameters.rhoRR) > 1
                                        str = {[str(1:4) '_1' str(5:end)]};
                                        for j=2:numel(BurstData{file}.Parameters.rhoRR)
                                            str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoRR(j))];
                                        end
                                    end
                                end
                            end
                            text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                            %'BackgroundColor',[1 1 1],...
                            %'EdgeColor',[0 0 0]);
                        case 4
                            %%%rGG vs TauGG
                            if isfield(BurstData{file}.Parameters,'rhoGG')
                                if ~isempty(BurstData{file}.Parameters.rhoGG)
                                    str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoGG(1))];
                                    if numel(BurstData{file}.Parameters.rhoGG) > 1
                                        str = {[str(1:4) '_1' str(5:end)]};
                                        for j=2:numel(BurstData{file}.Parameters.rhoGG)
                                            str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoGG(j))];
                                        end
                                    end
                                end
                            end
                            text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                            %'BackgroundColor',[1 1 1],...
                            %'EdgeColor',[0 0 0]);
                    end
                end
            end
        end
        FigureName = 'LifetimePlots';
    case h.Export2DLifetime_Menu
        AspectRatio = 1;
        pos = [100,100, round(1.3*size_pixels),round(1.2*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1],'Visible','on');
        %%% Copy axes to figure
        panel_copy = copyobj(h.LifetimePanelInd,hfig);
        panel_copy.ShadowColor = [1 1 1];
        %%% set Background Color to white
        panel_copy.BackgroundColor = [1 1 1];
        panel_copy.HighlightColor = [1 1 1];
        
        color_bar = true;
        
        %%% Update ColorMap
        if ischar(UserValues.BurstBrowser.Display.ColorMap)
            if ~UserValues.BurstBrowser.Display.ColorMapFromWhite
                colormap(UserValues.BurstBrowser.Display.ColorMap);
            else
                if ~strcmp(UserValues.BurstBrowser.Display.ColorMap,'jet')
                    colormap(colormap_from_white(UserValues.BurstBrowser.Display.ColorMap));
                else %%% jet is a special case, use jetvar colormap
                    colormap(jetvar);
                end
            end
        else
            colormap(UserValues.BurstBrowser.Display.ColorMap);
        end
        if UserValues.BurstBrowser.Display.ColorMapInvert
            colormap(h.BurstBrowser,flipud(colormap));
        end
        %%% Remove non-axes object
        del = zeros(numel(panel_copy.Children),1);
        for i = 1:numel(panel_copy.Children)
            if ~strcmp(panel_copy.Children(i).Type,'axes')
                if ~strcmp(panel_copy.Children(i).Type,'legend')
                    del(i) = 1;
                end
            end
        end
        delete(panel_copy.Children(logical(del)));
        for i = 1:numel(panel_copy.Children)
            if strcmp(panel_copy.Children(i).Type,'legend')
                pause(1e-100) % for some reason, matlab needs an infinitesimal break here for the correct positioning of the x axes
                continue
            end
            %%% Set the Color of Axes to white
            panel_copy.Children(i).Color = [1 1 1];
            %%% change X/YColor Color Color
            panel_copy.Children(i).XColor = [0,0,0];
            panel_copy.Children(i).YColor = [0,0,0];
            %%% Increase FontSize
            panel_copy.Children(i).FontSize = fontsize;
            %panel_copy.Children(i).Layer = 'bottom';
            
            %%% Reorganize Axes Positions
            switch panel_copy.Children(i).Tag
                case 'axes_lifetime_ind_1d_y'
                    panel_copy.Children(i).Position = [0.77 0.135 0.15 0.65];
                    panel_copy.Children(i).YTickLabelRotation = 270;
                    if numel(panel_copy.Children(i).Children) == 1 %%% no multiplot
                        panel_copy.Children(i).YLim = [0, max(panel_copy.Children(i).Children(1).YData)*1.05];
                    else
                        if all(panel_copy.Children(i).Children(1).Color == [0,0,0]) %%% overlayed plot, not multiplot
                            panel_copy.Children(i).YLim = [0, max(panel_copy.Children(i).Children(1).YData)*1.05];
                        else
                             maxY = 0;
                             for k = 1:numel(panel_copy.Children(i).Children)-1
                                 if strcmp(panel_copy.Children(i).Children(k).Visible,'on')
                                    maxY = max([maxY,max(panel_copy.Children(i).Children(k).YData)]);
                                 end
                             end
                             panel_copy.Children(i).YLim = [0, maxY*1.05];
                             color_bar = false;
                        end
                    end
                    panel_copy.Children(i).YTickLabel = [];
                    panel_copy.Children(i).YLabel.String = '';
                    panel_copy.Children(i).YGrid = 'off';
                    panel_copy.Children(i).XGrid = 'off';
                    panel_copy.Children(i).Layer = 'top';
                    % change the grayscale of the bars and remove the line
                    for k = 1:numel(panel_copy.Children(i).Children)
                        if strcmp(panel_copy.Children(i).Children(k).Type,'bar')
                            %panel_copy.Children(i).Children(k).FaceColor = [0.7 0.7 0.7];
                            panel_copy.Children(i).Children(k).LineStyle = 'none';
                        end
                    end
                case 'axes_lifetime_ind_1d_x'
                    panel_copy.Children(i).Position = [0.12 0.785 0.65 0.15];
                    xlabel(panel_copy.Children(i),'');
                    if numel(panel_copy.Children(i).Children) == 1 %%% no multiplot
                        panel_copy.Children(i).YLim = [0, max(panel_copy.Children(i).Children(1).YData)*1.05];
                    else
                        if all(panel_copy.Children(i).Children(1).Color == [0,0,0]) %%% overlayed plot, not multiplot
                            panel_copy.Children(i).YLim = [0, max(panel_copy.Children(i).Children(1).YData)*1.05];
                        else
                            maxY = 0;
                            for k = 1:numel(panel_copy.Children(i).Children)-1
                                if strcmp(panel_copy.Children(i).Children(k).Visible,'on')
                                    maxY = max([maxY,max(panel_copy.Children(i).Children(k).YData)]);
                                end
                            end
                            panel_copy.Children(i).YLim = [0, maxY*1.05];
                        end
                    end
                    panel_copy.Children(i).YTickLabel = [];
                    panel_copy.Children(i).YLabel.String = '';
                    panel_copy.Children(i).YGrid = 'off';
                    panel_copy.Children(i).XGrid = 'off';
                    panel_copy.Children(i).Layer = 'top';
                    % change the grayscale of the bars and remove the line
                    for k = 1:numel(panel_copy.Children(i).Children)
                        if strcmp(panel_copy.Children(i).Children(k).Type,'bar')
                            %panel_copy.Children(i).Children(k).FaceColor = [0.7 0.7 0.7];
                            panel_copy.Children(i).Children(k).LineStyle = 'none';
                        end
                    end
                case 'axes_lifetime_ind_2d'
                    panel_copy.Children(i).Position = [0.12 0.135 0.65 0.65];
                    panel_copy.Children(i).XLabel.Color = [0 0 0];
                    panel_copy.Children(i).YLabel.Color = [0 0 0];
                    ax2d = i;
                    switch BurstData{file}.BAMethod
                        case {1,2}
                            switch h.lifetime_ind_popupmenu.Value
                                case {3,4} % Ansiotropy plot, adjust y axis label
                                    panel_copy.Children(i).YLabel.Position(1) =...
                                        panel_copy.Children(i).YLabel.Position(1) + 0.1;
                            end
                        case {3,4}
                            switch h.lifetime_ind_popupmenu.Value
                                case {4,5,6} % Ansiotropy plot, adjust y axis label
                                    panel_copy.Children(i).YLabel.Position(1) =...
                                        panel_copy.Children(i).YLabel.Position(1) + 0.1;
                            end
                    end
            end
        end
        if ~verLessThan('MATLAB','9.4') %%% for some reason, the change before is disregarded by MATLAB in 2018a onwards.
            panel_copy.Children(ax2d).Position = [0.12 0.135 0.65 0.65];
        end
        if ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter') && color_bar
            cbar = colorbar(panel_copy.Children(find(strcmp(get(panel_copy.Children,'Tag'),'axes_lifetime_ind_2d'))),...
                'Location','north','Color',[0 0 0],'FontSize',fontsize-6); 
            cbar.Position = [0.8,0.85,0.18,0.025];
            cbar.Label.String = 'Occurrence';
            cbar.TickLabelsMode = 'auto';
            if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour')
                labels = cellfun(@str2double,cbar.TickLabels);
                %%% find maximum number of bursts
                for j = 1:numel(panel_copy.Children)
                    if strcmp(panel_copy.Children(j).Tag,'axes_lifetime_ind_2d')
                        for k=1:numel(panel_copy.Children(j).Children)
                            if strcmp(panel_copy.Children(j).Children(k).Type,'image')
                                maxZ = max(panel_copy.Children(j).Children(k).CData(:));
                            end
                        end
                    end
                end
                if maxZ > 1 %%% ensure that the plot is not normalized
                    for i = 1:numel(labels)
                        cbar.TickLabels{i} = num2str(round(labels(i)*maxZ));
                    end
                end
            end
            cbar.Units = 'pixels';drawnow;
        end
        if (h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1)
            %%% Set all units to pixels for easy editing without resizing
            hfig.Units = 'pixels';
            panel_copy.Units = 'pixels';
            for i = 1:numel(panel_copy.Children)
                if isprop(panel_copy.Children(i),'Units');
                    panel_copy.Children(i).Units = 'pixels';
                end
            end
            %%% refind legend item
            for i = 1:numel(panel_copy.Children)
                if strcmp(panel_copy.Children(i).Type,'legend')
                    leg = i;
                end
            end
            if strcmp(panel_copy.Children(leg).Visible,'on')
                hfig.Position(4) = 660;
                panel_copy.Position(4) = 660;
                panel_copy.Children(leg).Position(1) = 10;
                panel_copy.Children(leg).Position(2) = 590;
            end
        end
        if UserValues.BurstBrowser.Display.ColorMapInvert
            colormap(flipud(colormap));
        end
        adjust_data_aspect_for_phasor = false;
        if adjust_data_aspect_for_phasor && (h.lifetime_ind_popupmenu.Value > 4) && any(BurstData{BurstMeta.SelectedFile}.BAMethod == [1,2,5])
            %%% we have a Phasor plot, adjust the data aspect ratio
            ax2d = findobj(panel_copy.Children,'Tag','axes_lifetime_ind_2d');
            ax2d.DataAspectRatio(1:2) = [1,1];
            pos_ax2d = plotboxpos(ax2d); %%%get position of actual used axis
            ax1dx = findobj(panel_copy.Children,'Tag','axes_lifetime_ind_1d_x');
            ax1dx.Position(2) = pos_ax2d(2) + pos_ax2d(4);
            ax1dy = findobj(panel_copy.Children,'Tag','axes_lifetime_ind_1d_y');
            ax1dy.Position(4) = pos_ax2d(4);
            ax1dy.Position(2) = pos_ax2d(2);
        end
        if ~UserValues.BurstBrowser.Display.PlotGridAboveData
            %%% create dummy axis to prevent data overlapping the axis
            ax2d = findobj(panel_copy.Children,'Tag','axes_lifetime_ind_2d');
            if ~exist('pos_ax2d','var')
                pos_ax2d = ax2d.Position;
            end
            ax_dummy = axes('Parent',panel_copy,'Units',ax2d.Units,'Position',pos_ax2d);
            %linkaxes([ax2d ax_dummy]);
            set(ax_dummy,'Color','none','XTick',ax2d.XTick,'YTick',ax2d.YTick,'XTickLAbel',[],'YTickLabel',[],...
                'LineWidth',1,'Box','on','XLim',ax2d.XLim, 'YLim', ax2d.YLim)
        end
        FigureName = h.lifetime_ind_popupmenu.String{h.lifetime_ind_popupmenu.Value};
        %%% remove html formatting
        origStr = {'<html>','</html>','&',';','<sub>','</sub>'}; repStr = {'','','','','',''};
        for i = 1:numel(origStr)
            FigureName = strrep(FigureName,origStr{i},repStr{i});
        end
    case h.ExportCorrections_Menu
        fontsize = 22;
        if ispc
            fontsize = fontsize/1.3;
        end
        AspectRatio = 1;
        pos = [100,100, round(1.6*size_pixels),round(1.6*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1]);
        %%% Copy axes to figure
        panel_copy = copyobj(h.MainTabCorrectionsPanel,hfig);
        panel_copy.ShadowColor = [1 1 1];
        panel_copy.HighlightColor = [1 1 1];
        %%% set Background Color to white
        panel_copy.BackgroundColor = [1 1 1];
        %%% Update ColorMap
        if ischar(UserValues.BurstBrowser.Display.ColorMap)
            if ~UserValues.BurstBrowser.Display.ColorMapFromWhite
                colormap(UserValues.BurstBrowser.Display.ColorMap);
            else
                if ~strcmp(UserValues.BurstBrowser.Display.ColorMap,'jet')
                    colormap(colormap_from_white(UserValues.BurstBrowser.Display.ColorMap));
                else %%% jet is a special case, use jetvar colormap
                    colormap(jetvar);
                end
            end
        else
            colormap(UserValues.BurstBrowser.Display.ColorMap);
        end
        if any(BurstData{file}.BAMethod == [1,2,5])
            for i = 1:numel(panel_copy.Children)
                %%% Set the Color of Axes to white
                panel_copy.Children(i).Color = [1 1 1];
                %%% change X/YColor Color Color
                panel_copy.Children(i).XColor = [0,0,0];
                panel_copy.Children(i).YColor = [0,0,0];
                panel_copy.Children(i).XLabel.Color = [0,0,0];
                panel_copy.Children(i).YLabel.Color = [0,0,0];
                %%% Increase FontSize
                panel_copy.Children(i).FontSize = fontsize;
                %%% Make Bold
                %panel_copy.Children(i).FontWeight = 'bold';
                %%% disable titles
                title(panel_copy.Children(i),'');
                %panel_copy.Children(i).Layer = 'bottom';
                %%% move axes up and left
                panel_copy.Children(i).Position = panel_copy.Children(i).Position + [0.03 0.04 0 0];
                %%% Add parameters on plot
                if isfield(BurstData{file},'Corrections')
                    switch i
                        case 4
                            %%% crosstalk
                            str = ['crosstalk = ' sprintf('%1.3f',BurstData{file}.Corrections.CrossTalk_GR)];
                            text(0.35*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                        case 3
                            %%%direct excitation
                            str = ['direct exc. = ' sprintf('%1.3f',BurstData{file}.Corrections.DirectExcitation_GR)];
                            text(0.35*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                        case 2
                            %%% gamma
                            str = ['gamma = ' sprintf('%1.3f',BurstData{file}.Corrections.Gamma_GR)];

                            text(0.35*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                    end
                end
            end
        elseif any(BurstData{file}.BAMethod == [3,4])
            hfig.Position(3) = hfig.Position(3)*1.55;
            %hfig.Position(4) = hfig.Position(3)*1.1;
            
            for i = 1:numel(panel_copy.Children)
                %%% Set the Color of Axes to white
                panel_copy.Children(i).Color = [1 1 1];
                %%% Move axis to top of stack
                %panel_copy.Children(i).Layer = 'bottom';
                %%% change X/YColor Color Color
                panel_copy.Children(i).XColor = [0,0,0];
                panel_copy.Children(i).YColor = [0,0,0];
                panel_copy.Children(i).XLabel.Color = [0,0,0];
                panel_copy.Children(i).YLabel.Color = [0,0,0];
                %%% Increase FontSize
                panel_copy.Children(i).FontSize = fontsize;
                %%% Make Bold
                %panel_copy.Children(i).FontWeight = 'bold';
                %%% disable titles
                title(panel_copy.Children(i),'');
                %%% move axes up and left
                panel_copy.Children(i).Position = panel_copy.Children(i).Position + [0.01 0.02 0 0];
                if any(i==[1,3,4])
                    panel_copy.Children(i).YLabel.Units = 'normalized';
                    panel_copy.Children(i).YLabel.Position = [-0.16 0.5 0];
                end
                msgbox('anders, see the 2 color code')
%                 %%% Add rotational correlation time
%                 if isfield(BurstData{file},'Parameters')
%                     switch i
%                         case 1
%                             %%%rBB vs TauBB
%                             if isfield(BurstData{file}.Parameters,'rhoBB')
%                                 if ~isempty(BurstData{file}.Parameters.rhoBB)
%                                     str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoBB(1))];
%                                     if numel(BurstData{file}.Parameters.rhoBB) > 1
%                                         str = {[str(1:4) '_1' str(5:end)]};
%                                         for j=2:numel(BurstData{file}.Parameters.rhoBB)
%                                             str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoBB(j))];
%                                         end
%                                     end
%                                 end
%                             end
%                             text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
%                                 'Parent',panel_copy.Children(i),...
%                                 'FontSize',fontsize);
%                             %'BackgroundColor',[1 1 1],...
%                             %'EdgeColor',[0 0 0]);
%                         case 3
%                             %%%rRR vs TauRR
%                             if isfield(BurstData{file}.Parameters,'rhoRR')
%                                 if ~isempty(BurstData{file}.Parameters.rhoRR)
%                                     str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoRR(1))];
%                                     if numel(BurstData{file}.Parameters.rhoRR) > 1
%                                         str = {[str(1:4) '_1' str(5:end)]};
%                                         for j=2:numel(BurstData{file}.Parameters.rhoRR)
%                                             str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoRR(j))];
%                                         end
%                                     end
%                                 end
%                             end
%                             text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
%                                 'Parent',panel_copy.Children(i),...
%                                 'FontSize',fontsize);
%                             %'BackgroundColor',[1 1 1],...
%                             %'EdgeColor',[0 0 0]);
%                         case 4
%                             %%%rGG vs TauGG
%                             if isfield(BurstData{file}.Parameters,'rhoGG')
%                                 if ~isempty(BurstData{file}.Parameters.rhoGG)
%                                     str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoGG(1))];
%                                     if numel(BurstData{file}.Parameters.rhoGG) > 1
%                                         str = {[str(1:4) '_1' str(5:end)]};
%                                         for j=2:numel(BurstData{file}.Parameters.rhoGG)
%                                             str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoGG(j))];
%                                         end
%                                     end
%                                 end
%                             end
%                             text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
%                                 'Parent',panel_copy.Children(i),...
%                                 'FontSize',fontsize);
%                             %'BackgroundColor',[1 1 1],...
%                             %'EdgeColor',[0 0 0]);
%                     end
%                 end
             end
        end
        FigureName = 'CorrectionPlots';
end

%%% Set all units to pixels for easy editing without resizing
hfig.Units = 'pixels';
for i = 1:numel(hfig.Children)
    if isprop(hfig.Children(i),'Units');
        hfig.Children(i).Units = 'pixels';
    end
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
FigureName = [FileName SpeciesName '_' FigureName];
%%% remove spaces
FigureName = strrep(strrep(FigureName,' ','_'),'/','-');
hfig.CloseRequestFcn = {@ExportGraph_CloseFunction,ask_file,FigureName};