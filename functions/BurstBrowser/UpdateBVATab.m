% Updates GUI elements
function UpdateBVATab(obj,~,h)
global UserValues
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end

if obj == h.KineticRates_table2 || obj == h.KineticRates_table3
    h.KineticRates_table3.Data(1,1) = {NaN};h.KineticRates_table2.Data(1,1) = {NaN};
    h.KineticRates_table3.Data(2,2) = {NaN};h.KineticRates_table2.Data(2,2) = {NaN};
    h.KineticRates_table3.Data(3,3) = {NaN};
    UserValues.BurstBrowser.Settings.BVA_KineticRatesTable2 = cell2mat(h.KineticRates_table2.Data);
    UserValues.BurstBrowser.Settings.BVA_KineticRatesTable3 = cell2mat(h.KineticRates_table3.Data);
elseif obj == h.Rstate1_edit
    UserValues.BurstBrowser.Settings.BVA_R1 = str2double(h.Rstate1_edit.String);
elseif obj == h.Rstate2_edit
    UserValues.BurstBrowser.Settings.BVA_R2 = str2double(h.Rstate2_edit.String);
elseif obj == h.Rstate3_edit
    UserValues.BurstBrowser.Settings.BVA_R3 = str2double(h.Rstate3_edit.String);
elseif obj == h.Rsigma1_edit
    UserValues.BurstBrowser.Settings.BVA_Rsigma1 = str2double(h.Rsigma1_edit.String);
elseif obj == h.Rsigma2_edit
    UserValues.BurstBrowser.Settings.BVA_Rsigma2 = str2double(h.Rsigma2_edit.String);
elseif obj == h.Rsigma3_edit
    UserValues.BurstBrowser.Settings.BVA_Rsigma3 = str2double(h.Rsigma3_edit.String);
elseif obj == h.BVA_Nstates_Popupmenu
    UserValues.BurstBrowser.Settings.BVA_Nstates = h.BVA_Nstates_Popupmenu.Value+1; 
    switch UserValues.BurstBrowser.Settings.BVA_Nstates
        case 2
            h.KineticRates_table3.Visible = 'off';
            h.KineticRates_table2.Visible = 'on';
            h.state3_text.Visible = 'off';
            h.Rstate3_text.Visible = 'off';
            h.Rstate3_edit.Visible = 'off';
            h.Rsigma3_text.Visible = 'off';
            h.Rsigma3_edit.Visible = 'off';
        case 3
            h.KineticRates_table2.Visible = 'off';
            h.KineticRates_table3.Visible = 'on';
            h.state3_text.Visible = 'on';
            h.Rstate3_text.Visible = 'on';
            h.Rstate3_edit.Visible = 'on';
            h.Rsigma3_text.Visible = 'on';
            h.Rsigma3_edit.Visible = 'on';
    end
elseif obj == h.DynamicAnalysisMethod_Popupmenu
        UserValues.BurstBrowser.Settings.DynamicAnalysisMethod = h.DynamicAnalysisMethod_Popupmenu.Value;
        switch UserValues.BurstBrowser.Settings.DynamicAnalysisMethod
            case 1 % BVA
                %UserValues.BurstBrowser.Settings.DynamicAnalysisMethod = 1;
                h.PhotonsPerWindow_text.Visible = 'on';
                h.PhotonsPerWindow_edit.Visible = 'on';
            case 2 % E vs TauD
                %UserValues.BurstBrowser.Settings.DynamicAnalysisMethod = 'E vs TauD';
                h.PhotonsPerWindow_text.Visible = 'off';
                h.PhotonsPerWindow_edit.Visible = 'off';
            case 3 % FRET-2CDE
                %UserValues.BurstBrowser.Settings.DynamicAnalysisMethod = 'FRET-2CDE';
                h.PhotonsPerWindow_text.Visible = 'off';
                h.PhotonsPerWindow_edit.Visible = 'off';
        end
elseif obj == h.BinNumber_edit
    UserValues.BurstBrowser.Settings.NumberOfBins_BVA = str2double(h.BinNumber_edit.String);
elseif obj == h.BurstsPerBin_edit
    UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA = str2double(h.BurstsPerBin_edit.String);
elseif obj == h.ConfidenceInterval_edit
    UserValues.BurstBrowser.Settings.ConfidenceSampling_BVA = str2double(h.ConfidenceInterval_edit.String);
elseif obj == h.PhotonsPerWindow_edit
    UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA = str2double(h.PhotonsPerWindow_edit);
elseif obj == h.Xaxis_Popupmenu
    UserValues.BurstBrowser.Settings.BVA_X_axis = h.Xaxis_Popupmenu.Value;
elseif obj == h.FRETpair_Popupmenu
    UserValues.BurstBrowser.Settings.FRETpair = h.FRETpair_Popupmenu.Value;
end
