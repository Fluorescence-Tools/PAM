function UpdateLineColor(obj,~)
global BurstMeta UserValues
h = guidata(obj);
fields = fieldnames(BurstMeta.Plots.Fits);
switch obj
    case h.ColorLine1
        if ~isdeployed
            c = uisetcolor(UserValues.BurstBrowser.Display.ColorLine1);
        elseif isdeployed %%% uisetcolor dialog does not work in compiled application
            c = color_setter(UserValues.BurstBrowser.Display.ColorLine1); % open dialog to input color
        end
        UserValues.BurstBrowser.Display.ColorLine1 = c;
        n=1;
    case h.ColorLine2
        if ~isdeployed
            c = uisetcolor(UserValues.BurstBrowser.Display.ColorLine2);
        elseif isdeployed %%% uisetcolor dialog does not work in compiled application
            c = color_setter(UserValues.BurstBrowser.Display.ColorLine2); % open dialog to input color
        end
        UserValues.BurstBrowser.Display.ColorLine2 = c;
        n=2;
    case h.ColorLine3
        if ~isdeployed
            c = uisetcolor(UserValues.BurstBrowser.Display.ColorLine3);
        elseif isdeployed %%% uisetcolor dialog does not work in compiled application
            c = color_setter(UserValues.BurstBrowser.Display.ColorLine3); % open dialog to input color
        end
        UserValues.BurstBrowser.Display.ColorLine3 = c;
        n=3;
    case h.ColorLine4
        if ~isdeployed
            c = uisetcolor(UserValues.BurstBrowser.Display.ColorLine4);
        elseif isdeployed %%% uisetcolor dialog does not work in compiled application
            c = color_setter(UserValues.BurstBrowser.Display.ColorLine4); % open dialog to input color
        end
        UserValues.BurstBrowser.Display.ColorLine4 = c;
        n=4;
    case h.ColorLine5
        if ~isdeployed
            c = uisetcolor(UserValues.BurstBrowser.Display.ColorLine5);
        elseif isdeployed %%% uisetcolor dialog does not work in compiled application
            c = color_setter(UserValues.BurstBrowser.Display.ColorLine5); % open dialog to input color
        end
        UserValues.BurstBrowser.Display.ColorLine5 = c;
        n=5;
    case h.ColorLine6
        if ~isdeployed
            c = uisetcolor(UserValues.BurstBrowser.Display.ColorLine6);
        elseif isdeployed %%% uisetcolor dialog does not work in compiled application
            c = color_setter(UserValues.BurstBrowser.Display.ColorLine6); % open dialog to input color
        end
        UserValues.BurstBrowser.Display.ColorLine6 = c;
        n=6;
    case h.MarkerColor_button
        if ~isdeployed
            c = uisetcolor(UserValues.BurstBrowser.Display.MarkerColor);
        elseif isdeployed %%% uisetcolor dialog does not work in compiled application
            c = color_setter(UserValues.BurstBrowser.Display.MarkerColor); % open dialog to input color
        end
        UserValues.BurstBrowser.Display.MarkerColor = c;
end

obj.BackgroundColor = c;

if obj == h.MarkerColor_button
    fields = fieldnames(BurstMeta.Plots); %%% loop through h structure
    %%% Make Image Plots Visible, Hide Contourf Plots
    for i = 1:numel(fields)
        if ~isempty(BurstMeta.Plots.(fields{i}))
            if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                    if numel(BurstMeta.Plots.(fields{i}))>2
                        BurstMeta.Plots.(fields{i})(3).CData = c;
                    end
                end
            end
        end
    end
    PlotLifetimeInd([],[],h);
    return;
end
%%% Change Color of Line Plots
for i = 1:numel(fields)
    if n <= numel(BurstMeta.Plots.Fits.(fields{i}))
        if strcmp(BurstMeta.Plots.Fits.(fields{i})(n).Type,'line')
            BurstMeta.Plots.Fits.(fields{i})(n).Color = c;
        end
    end
end

BurstMeta.Plots.Mixture.Main_Plot(1).LineColor = UserValues.BurstBrowser.Display.ColorLine1;
BurstMeta.Plots.Mixture.Main_Plot(2).LineColor = UserValues.BurstBrowser.Display.ColorLine2;
BurstMeta.Plots.Mixture.Main_Plot(3).LineColor = UserValues.BurstBrowser.Display.ColorLine3;
BurstMeta.Plots.Mixture.Main_Plot(4).LineColor = UserValues.BurstBrowser.Display.ColorLine4;
BurstMeta.Plots.Mixture.Main_Plot(5).LineColor = UserValues.BurstBrowser.Display.ColorLine5;
BurstMeta.Plots.Mixture.Main_Plot(6).LineColor = UserValues.BurstBrowser.Display.ColorLine6;
BurstMeta.Plots.Mixture.plotX(1).Color = UserValues.BurstBrowser.Display.ColorLine1;
BurstMeta.Plots.Mixture.plotX(2).Color = UserValues.BurstBrowser.Display.ColorLine2;
BurstMeta.Plots.Mixture.plotX(3).Color = UserValues.BurstBrowser.Display.ColorLine3;
BurstMeta.Plots.Mixture.plotX(4).Color = UserValues.BurstBrowser.Display.ColorLine4;
BurstMeta.Plots.Mixture.plotX(5).Color = UserValues.BurstBrowser.Display.ColorLine5;
BurstMeta.Plots.Mixture.plotX(6).Color = UserValues.BurstBrowser.Display.ColorLine6;
BurstMeta.Plots.Mixture.plotY(1).Color = UserValues.BurstBrowser.Display.ColorLine1;
BurstMeta.Plots.Mixture.plotY(2).Color = UserValues.BurstBrowser.Display.ColorLine2;
BurstMeta.Plots.Mixture.plotY(3).Color = UserValues.BurstBrowser.Display.ColorLine3;
BurstMeta.Plots.Mixture.plotY(4).Color = UserValues.BurstBrowser.Display.ColorLine4;
BurstMeta.Plots.Mixture.plotY(5).Color = UserValues.BurstBrowser.Display.ColorLine5;
BurstMeta.Plots.Mixture.plotY(6).Color = UserValues.BurstBrowser.Display.ColorLine6;
%%% Reset color of correction fits
BurstMeta.Plots.Fits.histE_donly(1).Color = [1,0,0];
BurstMeta.Plots.Fits.histS_aonly(1).Color = [1,0,0];
BurstMeta.Plots.Fits.histEBG_blueonly(1).Color = [1,0,0];
BurstMeta.Plots.Fits.histEBR_blueonly(1).Color = [1,0,0];
BurstMeta.Plots.Fits.histSBG_greenonly(1).Color = [1,0,0];
BurstMeta.Plots.Fits.histSBR_redonly(1).Color = [1,0,0];

LSUserValues(1);
PlotLifetimeInd([],[]);