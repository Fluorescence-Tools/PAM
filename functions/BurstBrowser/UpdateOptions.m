%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Update Options in UserValues Structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateOptions(obj,~,h)
global UserValues
if isempty(obj)
    return;
end
if nargin < 3
    h = guidata(obj);
end
switch obj
    case h.SaveOnClose
        UserValues.BurstBrowser.Settings.SaveOnClose = obj.Value;
    case h.Downsample_fFCS_edit
        UserValues.BurstBrowser.Settings.Downsample_fFCS_Time = str2double(h.Downsample_fFCS_edit.String);
    case h.Downsample_fFCS
        UserValues.BurstBrowser.Settings.Downsample_fFCS = obj.Value;
        switch h.Downsample_fFCS.Value
            case 1
                h.Downsample_fFCS_edit.Enable = 'on';
            case 0
                h.Downsample_fFCS_edit.Enable = 'off';
        end
    case h.fFCS_UseIRF
        UserValues.BurstBrowser.Settings.fFCS_UseIRF = obj.Value;
    case h.CorrelateWindow_Edit
        UserValues.BurstBrowser.Settings.Corr_TimeWindowSize = str2double(obj.String);
    case h.fFCS_selectmode_popupmenu
        UserValues.BurstBrowser.Settings.fFCS_Mode = obj.Value;
    case h.SaveFileExportFigure_Checkbox
        UserValues.BurstBrowser.Settings.SaveFileExportFigure = obj.Value;
    case h.fFCS_UseFRET
        UserValues.BurstBrowser.Settings.fFCS_UseFRET = obj.Value;
    case h.Fit_Gaussian_Pick
        UserValues.BurstBrowser.Settings.FitGaussPick = obj.Value;
    case h.Fit_Gaussian_Use_Weights
        UserValues.BurstBrowser.Settings.FitGauss_UseWeights = obj.Value;
    case h.ApplyCorrectionsOnLoad
        UserValues.BurstBrowser.Settings.CorrectionOnLoad = obj.Value;
    case h.Fit_GaussianMethod_Popupmenu
        switch obj.Value
            case 1 %%% changed to MLE
                h.Fit_Gaussian_Text.ColumnName = h.GUIData.ColumnNameMLE;
                h.Fit_Gaussian_Text.Data = h.GUIData.TableDataMLE;
                h.Fit_Gaussian_Text.ColumnEditable = h.GUIData.ColumnEditableMLE;
                h.Fit_Gaussian_Text.ColumnWidth = h.GUIData.ColumnWidthMLE;
                h.Fit_Gaussian_Text.ColumnFormat = h.GUIData.ColumnFormatMLE;
                UserValues.BurstBrowser.Settings.GaussianFitMethod = 'MLE';
                h.Fit_GaussianChi2_Text.String = '';
                h.Fit_Gaussian_Use_Weights.Visible = 'off';
            case 2 %%% changed to LSQ
                h.Fit_Gaussian_Text.ColumnName = h.GUIData.ColumnNameLSQ;
                h.Fit_Gaussian_Text.Data = h.GUIData.TableDataLSQ;
                h.Fit_Gaussian_Text.ColumnEditable = h.GUIData.ColumnEditableLSQ;
                h.Fit_Gaussian_Text.ColumnWidth = h.GUIData.ColumnWidthLSQ;
                h.Fit_Gaussian_Text.ColumnFormat = h.GUIData.ColumnFormatLSQ;
                UserValues.BurstBrowser.Settings.GaussianFitMethod = 'LSQ';
                h.Fit_Gaussian_Use_Weights.Visible = 'on';
        end
        UpdateOptions(h.Fit_NGaussian_Popupmenu,[]);
    case h.Fit_NGaussian_Popupmenu
        if strcmp(UserValues.BurstBrowser.Settings.GaussianFitMethod,'LSQ')
            %%% change fixed values in table
            nG = obj.Value;
            h.Fit_Gaussian_Text.Data(:,1) = {1/nG,1/nG,1/nG,1/nG,1/nG};
            for i = 1:nG           
                h.Fit_Gaussian_Text.Data(i,4:4:end) = {false,false,false,false,false,false};
            end
            for i = (nG+1):5           
                h.Fit_Gaussian_Text.Data(i,4:4:end) = {true,true,true,true,true,true};
                h.Fit_Gaussian_Text.Data{i,1} = 0;
            end
        end
    case h.IsoLineGaussFit_Edit
        UserValues.BurstBrowser.Settings.IsoLineGaussFit = str2double(obj.String);
    case h.TimeBinPDAEdit
        % store it as a string cause it might not be a number but a range
        UserValues.BurstBrowser.Settings.PDATimeBin = obj.String;
    case h.TimeBin_TimeWindow_Edit
        % store it as a string cause it might not be a number but a range
        UserValues.BurstBrowser.Settings.TimeWindow_TimeBin = obj.String;
    case h.CompareFRETHist_Waterfall
        UserValues.BurstBrowser.Settings.CompareFRETHist_Waterfall = obj.Value;
    case h.MultiPlot_PlotType
        UserValues.BurstBrowser.Display.MultiPlotMode = obj.Value;
    case h.MultiselectOnCheckbox
        switch obj.UserData
            case 0
                %%% enable multiselect
                h.SpeciesList.Tree.setMultipleSelectionEnabled(true);
                % disable right click
                set(h.SpeciesList.Tree.getTree, 'MousePressedCallback', []);
                %%% enable multiplot button
                h.MultiPlotButton.Visible = 'on';
                %%% Disable buttonsin Species List
                h.AddSpecies_Button.Visible = 'off';
                h.RemoveSpecies_Button.Visible = 'off';
                h.RenameSpecies_Button.Visible = 'off';
                h.Export_To_PDA_Button.Visible = 'off';
                h.Send_to_TauFit_Button.Visible = 'off';
                h.Param_comp_selected_Menu.Enable = 'on';
                set(h.Param_comp_selected_Menu.Children,'Enable','on');
                h.FRET_comp_selected_Menu.Enable = 'on';
                set(h.FRET_comp_selected_Menu.Children,'Enable','on');
                obj.UserData = 1;
                obj.CData = circshift(obj.CData,[0,0,1]);
            case 1
                %%% disable multiselect
                h.SpeciesList.Tree.setMultipleSelectionEnabled(false);
                % reenable right click
                set(h.SpeciesList.Tree.getTree, 'MousePressedCallback', {@SpeciesListContextMenuCallback,h.SpeciesListMenu});
                %%% disable multiplot button
                h.MultiPlotButton.Visible = 'off';
                %%% Reenable buttonsin Species List
                h.AddSpecies_Button.Visible = 'on';
                h.RemoveSpecies_Button.Visible = 'on';
                h.RenameSpecies_Button.Visible = 'on';
                h.Export_To_PDA_Button.Visible = 'on';
                h.Send_to_TauFit_Button.Visible = 'on';
                h.Param_comp_selected_Menu.Enable = 'off';
                h.FRET_comp_selected_Menu.Enable = 'off';
                obj.UserData = 0;
                obj.CData = circshift(obj.CData,[0,0,-1]);
        end
        UpdatePlot([],[],h);
        UpdateLifetimePlots([],[],h);
        PlotLifetimeInd([],[],h);
    case h.Threshold_S_Donly_Min_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
             h.Threshold_S_Donly_Min_Edit.String = num2str(UserValues.BurstBrowser.Settings.S_Donly_Min);
        else
            UserValues.BurstBrowser.Settings.S_Donly_Min = newVal;
        end
    case h.Threshold_S_Donly_Max_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
             h.Threshold_S_Donly_Max_Edit.String = num2str(UserValues.BurstBrowser.Settings.S_Donly_Max);
        else
            UserValues.BurstBrowser.Settings.S_Donly_Max = newVal;
        end
    case h.Threshold_S_Aonly_Min_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
             h.Threshold_S_Aonly_Min_Edit.String = num2str(UserValues.BurstBrowser.Settings.S_Aonly_Min);
        else
            UserValues.BurstBrowser.Settings.S_Aonly_Min = newVal;
        end
    case h.Threshold_S_Aonly_Max_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
            h.Threshold_S_Aonly_Max_Edit.String = num2str(UserValues.BurstBrowser.Settings.S_Aonly_Max);
        else
            UserValues.BurstBrowser.Settings.S_Aonly_Max = newVal;
        end
    case h.Threshold_E_Aonly_Min_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
            h.Threshold_E_Aonly_Min_Edit.String = num2str(UserValues.BurstBrowser.Settings.E_Aonly_Min);
        else
            UserValues.BurstBrowser.Settings.E_Aonly_Min = newVal;
        end
    case h.Threshold_E_Aonly_Max_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
            h.Threshold_E_Aonly_Max_Edit.String = num2str(UserValues.BurstBrowser.Settings.E_Aonly_Max);
        else
            UserValues.BurstBrowser.Settings.E_Aonly_Max = newVal;
        end
    case h.Threshold_E_Donly_Min_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
            h.Threshold_E_Donly_Min_Edit.String = num2str(UserValues.BurstBrowser.Settings.E_Donly_Min);
        else
            UserValues.BurstBrowser.Settings.E_Donly_Min = newVal;
        end
    case h.Threshold_E_Donly_Max_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
            h.Threshold_E_Donly_Max_Edit.String = num2str(UserValues.BurstBrowser.Settings.E_Donly_Max);
        else
            UserValues.BurstBrowser.Settings.E_Donly_Max = newVal;
        end
    case h.ArbitraryCutInvertCheckbox
        switch h.ArbitraryCutInvertCheckbox.Checked
            case 'off'
                h.ArbitraryCutInvertCheckbox.Checked = 'on';
            case 'on'
                h.ArbitraryCutInvertCheckbox.Checked = 'off';
        end
    case h.MultiPlotButtonMenu_ToggleNormalize
        switch h.MultiPlotButtonMenu_ToggleNormalize.Checked
            case 'off'
                h.MultiPlotButtonMenu_ToggleNormalize.Checked = 'on';
                UserValues.BurstBrowser.Settings.Normalize_Multiplot = true;
            case 'on'
                h.MultiPlotButtonMenu_ToggleNormalize.Checked = 'off';
                UserValues.BurstBrowser.Settings.Normalize_Multiplot = false;
        end
        UpdatePlot([],[],h);
        UpdateLifetimePlots([],[],h);
        PlotLifetimeInd([],[],h);
   case h.MultiPlotButtonMenu_ToggleDisplayTotal
        switch h.MultiPlotButtonMenu_ToggleDisplayTotal.Checked
            case 'off'
                h.MultiPlotButtonMenu_ToggleDisplayTotal.Checked = 'on';
                UserValues.BurstBrowser.Settings.Display_Total_Multiplot = true;
            case 'on'
                h.MultiPlotButtonMenu_ToggleDisplayTotal.Checked = 'off';
                UserValues.BurstBrowser.Settings.Display_Total_Multiplot = false;
        end
        UpdatePlot([],[],h);
        PlotLifetimeInd([],[],h); 
    case {h.MultiPlotButtonMenu_NormalizeMaximum, h.MultiPlotButtonMenu_NormalizeArea}
        switch obj
            case h.MultiPlotButtonMenu_NormalizeMaximum
                h.MultiPlotButtonMenu_NormalizeMaximum.Checked = 'on';
                h.MultiPlotButtonMenu_NormalizeArea.Checked = 'off';
                UserValues.BurstBrowser.Settings.Normalize_Method = 'max';
            case h.MultiPlotButtonMenu_NormalizeArea
                h.MultiPlotButtonMenu_NormalizeMaximum.Checked = 'off';
                h.MultiPlotButtonMenu_NormalizeArea.Checked = 'on';
                UserValues.BurstBrowser.Settings.Normalize_Method = 'area';
        end
        UpdatePlot([],[],h);
        UpdateLifetimePlots([],[],h);
        PlotLifetimeInd([],[],h);
    case h.Hist_log10
        UpdatePlot([],[],h);
        UpdateLifetimePlots([],[],h);
        PlotLifetimeInd([],[],h);
    case h.Dog_Mode
        if strcmp(h.Dog_Mode.Checked,'off')       
            h.Dog_Mode.Checked = 'on';
            UserValues.BurstBrowser.Dog_Mode = true;
        else
            h.Dog_Mode.Checked = 'off';
            UserValues.BurstBrowser.Dog_Mode = false;
        end
end
LSUserValues(1);