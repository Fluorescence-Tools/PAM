function UpdateGUIOptions(obj,~,h)
global UserValues BurstMeta
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end
if obj == h.NumberOfBinsXEdit
    nbinsX = str2double(h.NumberOfBinsXEdit.String);
    if ~isnan(nbinsX)
        if nbinsX > 0
            UserValues.BurstBrowser.Display.NumberOfBinsX = nbinsX;
        else
            h.NumberOfBinsXEdit.String = UserValues.BurstBrowser.Display.NumberOfBinsX;
        end
    else
        h.NumberOfBinsXEdit.String = num2str(UserValues.BurstBrowser.Display.NumberOfBinsX);
    end        
    UpdateLifetimePlots(obj,[]);
end
if obj == h.NumberOfBinsYEdit
    nbinsY = str2double(h.NumberOfBinsYEdit.String);
    if ~isnan(nbinsY)
        if nbinsY > 0
            UserValues.BurstBrowser.Display.NumberOfBinsY = nbinsY;
        else
            h.NumberOfBinsYEdit.String = UserValues.BurstBrowser.Display.NumberOfBinsY;
        end
    else
        h.NumberOfBinsYEdit.String = num2str(UserValues.BurstBrowser.Display.NumberOfBinsY);
    end
    UpdateLifetimePlots(obj,[]);
end
if obj == h.logX_checkbox
    UserValues.BurstBrowser.Display.logX = obj.Value;
end
if obj == h.logY_checkbox
    UserValues.BurstBrowser.Display.logY = obj.Value;
end
if obj == h.NumberOfContourLevels_edit
    nClevels = str2double(h.NumberOfContourLevels_edit.String);
    if ~isnan(nClevels)
        if nClevels > 1
            UserValues.BurstBrowser.Display.NumberOfContourLevels = nClevels;
        else
            h.NumberOfContourLevels_edit.String = UserValues.BurstBrowser.Display.NumberOfContourLevels;
        end
    else
        h.NumberOfContourLevels_edit.String = num2str(UserValues.BurstBrowser.Display.NumberOfContourLevels);
    end
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
end
if obj == h.ZScale_Intensity
    UserValues.BurstBrowser.Display.ZScale_Intensity = obj.Value;
end
if obj == h.PlotOffset_edit
    switch UserValues.BurstBrowser.Display.PlotType
        case 'Contour'
            ContourOffset = str2double(h.PlotOffset_edit.String);
            if ~isnan(ContourOffset)
                if ContourOffset >=0 && ContourOffset<=100
                    UserValues.BurstBrowser.Display.ContourOffset = ContourOffset;
                else
                    h.PlotOffset_edit.String = UserValues.BurstBrowser.Display.ContourOffset;
                end
            else
                h.PlotOffset_edit.String = num2str(UserValues.BurstBrowser.Display.ContourOffset);
            end
        case 'Image'
            ImageOffset = str2double(h.PlotOffset_edit.String);
            if ~isnan(ImageOffset)
                if ImageOffset >=0 && ImageOffset<=100
                    UserValues.BurstBrowser.Display.ImageOffset = ImageOffset;
                else
                    h.PlotOffset_edit.String = UserValues.BurstBrowser.Display.ImageOffset;
                end
            else
                h.PlotOffset_edit.String = num2str(UserValues.BurstBrowser.Display.ImageOffset);
            end
    end
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
end
if obj == h.PlotCutoff_edit
    val = str2double(h.PlotCutoff_edit.String);
    if ~isnan(val)
        if (val > 0) && (val <= 100)
            UserValues.BurstBrowser.Display.PlotCutoff = val;
        else
            h.PlotCutoff_edit.String = num2str(UserValues.BurstBrowser.Display.PlotCutoff);
        end
    else
        h.PlotCutoff_edit.String = num2str(UserValues.BurstBrowser.Display.PlotCutoff);
    end
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
end
if obj == h.ColorMapPopupmenu
    UserValues.BurstBrowser.Display.ColorMap = h.ColorMapPopupmenu.String{h.ColorMapPopupmenu.Value};
end
if obj == h.ColorMapFromWhite
    UserValues.BurstBrowser.Display.ColorMapFromWhite = obj.Value;
end
if obj == h.SmoothKDE
    UserValues.BurstBrowser.Display.KDE = h.SmoothKDE.Value;
    UpdateLifetimePlots(obj,[]);
end
if obj == h.Multiplot_Contour
    UserValues.BurstBrowser.Display.Multiplot_Contour = h.Multiplot_Contour.Value;
end
if obj == h.ColorMapInvert
    UserValues.BurstBrowser.Display.ColorMapInvert = h.ColorMapInvert.Value;
end
if obj == h.ContourFill
    UserValues.BurstBrowser.Display.ContourFill = h.ContourFill.Value;
end
if obj == h.BrightenColorMap_edit
    beta = str2double(h.BrightenColorMap_edit.String);
    if ~isnan(beta)
        if beta > 1
            h.BrightenColorMap_edit.String = 1;
            UserValues.BurstBrowser.Display.BrightenColorMap = 1;
        elseif beta < -1
            h.BrightenColorMap_edit.String = -1;
            UserValues.BurstBrowser.Display.BrightenColorMap = -1;
        else
            UserValues.BurstBrowser.Display.BrightenColorMap = beta;
        end
    else
        h.BrightenColorMap_edit.String = num2str(UserValues.BurstBrowser.Display.BrightenColorMap);
    end
end
if obj == h.PlotGridAboveDataCheckbox
    %%% change layer property of 2d axes to "top" or "bottom"
    UserValues.BurstBrowser.Display.PlotGridAboveData = obj.Value;
    switch obj.Value
        case 0
            layer = 'bottom';
        case 1
            layer = 'top';
    end
    set([h.axes_general,h.axes_EvsTauGG,h.axes_EvsTauRR,h.axes_rGGvsTauGG,h.axes_rRRvsTauRR,...
        h.axes_E_BtoGRvsTauBB,h.axes_rBBvsTauBB,h.axes_lifetime_ind_2d],'Layer',layer);
end
if obj == h.Restrict_EandS_Range
    UserValues.BurstBrowser.Display.Restrict_EandS_Range = obj.Value;
end
if obj == h.MarkerSize_edit
    markersize = str2double(h.MarkerSize_edit.String);
    if ~isnan(markersize)
        UserValues.BurstBrowser.Display.MarkerSize = markersize;
        fields = fieldnames(BurstMeta.Plots); %%% loop through h structure
        for i = 1:numel(fields)
            if ~isempty(BurstMeta.Plots.(fields{i}))
                if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                    if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                        if numel(BurstMeta.Plots.(fields{i}))>2
                            BurstMeta.Plots.(fields{i})(3).SizeData = markersize;
                        end
                    end
                end
            end
        end
    else
        h.MarkerSize_edit.String = num2str(UserValues.BurstBrowser.Display.MarkerSize);
    end
    PlotLifetimeInd([],[],h);
end
if obj == h.LifetimeMode_Menu
    UserValues.BurstBrowser.Settings.LifetimeMode = h.LifetimeMode_Menu.Value;
    % change axis labels and lifetime_ind selection box
    switch UserValues.BurstBrowser.Settings.LifetimeMode
        case 1
            h.axes_EvsTauGG.YLabel.String = 'FRET Efficiency';
            h.axes_EvsTauRR.YLabel.String = 'FRET Efficiency';
            h.lifetime_ind_popupmenu.String{1} = '<html>E vs &tau;<sub>D(A)</sub></html>';
            h.lifetime_ind_popupmenu.String{2} = '<html>E vs &tau;<sub>A</sub></html>';
        case 2
            h.axes_EvsTauGG.YLabel.String = 'log(FD/FA)';
            h.axes_EvsTauRR.YLabel.String = 'log(FD/FA)';
            h.lifetime_ind_popupmenu.String{1} = '<html>log(F<sub>D</sub>/F<sub>A</sub>) vs &tau;<sub>D(A)</sub></html>';
            h.lifetime_ind_popupmenu.String{2} = '<html>log(F<sub>D</sub>/F<sub>A</sub>) vs &tau;<sub>A</sub></html>';
        case 3
            h.axes_EvsTauGG.YLabel.String = 'M_1-M_2';
            h.axes_EvsTauGG.XLabel.String = 'FRET Efficiency';
            h.lifetime_ind_popupmenu.String{1} = '<html>M<sub>1</sub>-M<sub>2</sub>) vs E</html>';
            h.lifetime_ind_popupmenu.String{2} = '<html>E vs &tau;<sub>A</sub></html>';
    end
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
    % hide dynamic FRET lines
    set(BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG,'Visible','off');
end
LSUserValues(1);