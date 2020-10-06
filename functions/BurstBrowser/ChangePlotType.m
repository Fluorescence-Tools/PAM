%%%%%%% Changes PlotType  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangePlotType(obj,~,h)
global UserValues BurstMeta
if nargin < 3
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
        obj = h.PlotTypePopumenu;
    else
        h = guidata(obj);
    end
else
    if isempty(obj)
        obj = h.PlotTypePopumenu;
    end
end



switch obj
    case h.PlotTypePopumenu
        set([h.MarkerSize_edit,h.MarkerSize_text,h.MarkerColor_button,h.MarkerColor_text,...
        h.NumberOfContourLevels_text,h.NumberOfContourLevels_edit,h.PlotOffset_edit,h.PlotOffset_text,h.PlotContourLines,h.PlotCutoff_edit,h.PlotCutoff_text,h.ContourFill,h.Multiplot_Contour],...
        'Visible','off');
            
        UserValues.BurstBrowser.Display.PlotType = obj.String{obj.Value};
        fields = fieldnames(BurstMeta.Plots); %%% loop through h structure
        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Image')
            %%% Make Image Plots Visible, Hide Contourf Plots
            for i = 1:numel(fields)
                if ~isempty(BurstMeta.Plots.(fields{i}))
                    if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                        if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                            BurstMeta.Plots.(fields{i})(1).Visible = 'on';
                            BurstMeta.Plots.(fields{i})(2).Visible = 'off';
                            if numel(BurstMeta.Plots.(fields{i}))>2
                                BurstMeta.Plots.(fields{i})(3).Visible = 'off';
                            end
                        end
                    end
                end
            end
            set([h.PlotOffset_edit,h.PlotOffset_text,h.PlotCutoff_edit,h.PlotCutoff_text],...
             'Visible','on');
            h.PlotOffset_text.String = 'Plot Offset [%]';
            h.PlotOffset_edit.String = num2str(UserValues.BurstBrowser.Display.ImageOffset);
        end
        
        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour')
            delete(BurstMeta.HexPlot.MainPlot_hex);
            %%% Make Image Plots Visible, Hide Contourf Plots
            for i = 1:numel(fields)
                if ~isempty(BurstMeta.Plots.(fields{i}))
                    if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                        if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                            BurstMeta.Plots.(fields{i})(1).Visible = 'off';
                            BurstMeta.Plots.(fields{i})(2).Visible = 'on';
                            if numel(BurstMeta.Plots.(fields{i}))>2
                                BurstMeta.Plots.(fields{i})(3).Visible = 'off';
                            end
                        end
                    end
                end
            end
            set([h.NumberOfContourLevels_edit,h.NumberOfContourLevels_text,h.PlotOffset_edit,h.PlotOffset_text,h.PlotContourLines,h.PlotCutoff_edit,h.PlotCutoff_text,h.ContourFill,h.Multiplot_Contour],...
             'Visible','on');
            h.PlotOffset_text.String = 'Plot Offset [%]';
            h.PlotOffset_edit.String = num2str(UserValues.BurstBrowser.Display.ContourOffset);
        end
        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
            delete(BurstMeta.HexPlot.MainPlot_hex);
            %%% Make Image Plots Visible, Hide Contourf Plots
            for i = 1:numel(fields)
                if ~isempty(BurstMeta.Plots.(fields{i}))
                    if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                        if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                            if numel(BurstMeta.Plots.(fields{i}))>2
                                BurstMeta.Plots.(fields{i})(1).Visible = 'off';
                                BurstMeta.Plots.(fields{i})(2).Visible = 'off';
                                BurstMeta.Plots.(fields{i})(3).Visible = 'on';
                            end
                        end
                    end
                end
            end
            UpdatePlot([],[],h);
            set([h.MarkerSize_edit,h.MarkerSize_text,h.MarkerColor_button,h.MarkerColor_text],...
                'Visible','on');
        end
        if any(strcmp(UserValues.BurstBrowser.Display.PlotType,{'Image','Contour','Scatter'}))
            fields = fieldnames(BurstMeta.HexPlot);
            for i = 1:numel(fields)
                delete(BurstMeta.HexPlot.(fields{i}));
            end
        end
        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
            %%% Make Image Plots Visible, Hide Contourf Plots
            for i = 1:numel(fields)
                if ~isempty(BurstMeta.Plots.(fields{i}))
                    if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                        if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                            if numel(BurstMeta.Plots.(fields{i}))>2
                                BurstMeta.Plots.(fields{i})(1).Visible = 'off';
                                BurstMeta.Plots.(fields{i})(2).Visible = 'off';
                                BurstMeta.Plots.(fields{i})(3).Visible = 'off';
                            end
                        end
                    end
                end
            end
            %%% Update Plots
            %%% To speed up, find out which tab is visible and only update the respective tab
            switch h.Main_Tab.SelectedTab
                case h.Main_Tab_General
                    %%% we switched to the general tab
                    UpdatePlot([],[],h);
                case h.Main_Tab_Lifetime
                    %%% we switched to the lifetime tab
                    %%% figure out what subtab is selected
                    UpdateLifetimePlots([],[],h);
                    switch h.LifetimeTabgroup.SelectedTab
                        case h.LifetimeTabAll
                        case h.LifetimeTabInd
                            PlotLifetimeInd([],[],h);
                    end     
            end
        end
    case h.PlotContourLines
        UserValues.BurstBrowser.Display.PlotContourLines = h.PlotContourLines.Value;
        fields = fieldnames(BurstMeta.Plots); %%% loop through h structure
        for i = 1:numel(fields)
            if ~isempty(BurstMeta.Plots.(fields{i}))
                if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                    if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                        if UserValues.BurstBrowser.Display.PlotContourLines == 0
                            BurstMeta.Plots.(fields{i})(2).LineStyle = 'none';
                        elseif UserValues.BurstBrowser.Display.PlotContourLines == 1
                            BurstMeta.Plots.(fields{i})(2).LineStyle = '-';
                        end
                    end
                end
            end
        end
end
UpdatePlot([],[],h);
UpdateLifetimePlots([],[],h);
PlotLifetimeInd([],[],h);
LSUserValues(1);