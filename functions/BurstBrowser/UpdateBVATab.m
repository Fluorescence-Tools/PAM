% Updates GUI elements
function UpdateBVATab(obj,~,h)
global UserValues BurstData BurstMeta
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end

file = BurstMeta.SelectedFile;
if isempty(obj)
    if isempty(BurstData)
        h.Rstate1_edit.String = UserValues.BurstBrowser.Settings.BVA_R1;
        h.Rstate2_edit.String = UserValues.BurstBrowser.Settings.BVA_R2;
        h.Rstate3_edit.String = UserValues.BurstBrowser.Settings.BVA_R3;
        h.Rsigma1_edit.String = UserValues.BurstBrowser.Settings.BVA_Rsigma1;
        h.Rsigma2_edit.String = UserValues.BurstBrowser.Settings.BVA_Rsigma2;
        h.Rsigma3_edit.String = UserValues.BurstBrowser.Settings.BVA_Rsigma3;
        h.Rstate1st_edit.String = UserValues.BurstBrowser.Settings.BVA_R1_static;
        h.Rstate2st_edit.String = UserValues.BurstBrowser.Settings.BVA_R2_static;
        h.Rstate3st_edit.String = UserValues.BurstBrowser.Settings.BVA_R3_static;
        h.Rsigma1st_edit.String = UserValues.BurstBrowser.Settings.BVA_Rsigma1_static;
        h.Rsigma2st_edit.String = UserValues.BurstBrowser.Settings.BVA_Rsigma2_static;
        h.Rsigma3st_edit.String = UserValues.BurstBrowser.Settings.BVA_Rsigma3_static;
        h.KineticRates_table2.Data = mat2cell(UserValues.BurstBrowser.Settings.BVA_KineticRatesTable2);
        h.KineticRates_table3.Data = mat2cell(UserValues.BurstBrowser.Settings.BVA_KineticRatesTable3);
    else
        %%% add rates, sigma and R as additional parameter
        if ~isfield(BurstData{file},'AdditionalParameters')
            BurstData{file}.AdditionalParameters = [];
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_R1')
            BurstData{file}.AdditionalParameters.BVA_R1 = UserValues.BurstBrowser.Settings.BVA_R1;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_R2')
            BurstData{file}.AdditionalParameters.BVA_R2 = UserValues.BurstBrowser.Settings.BVA_R2;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_R3')
            BurstData{file}.AdditionalParameters.BVA_R3 = UserValues.BurstBrowser.Settings.BVA_R3;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_Rsigma1')
            BurstData{file}.AdditionalParameters.BVA_Rsigma1 = UserValues.BurstBrowser.Settings.BVA_Rsigma1;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_Rsigma2')
            BurstData{file}.AdditionalParameters.BVA_Rsigma2 = UserValues.BurstBrowser.Settings.BVA_Rsigma2;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_Rsigma3')
            BurstData{file}.AdditionalParameters.BVA_Rsigma3 = UserValues.BurstBrowser.Settings.BVA_Rsigma3;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_R1_static')
            BurstData{file}.AdditionalParameters.BVA_R1_static = UserValues.BurstBrowser.Settings.BVA_R1_static;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_R2_static')
            BurstData{file}.AdditionalParameters.BVA_R2_static = UserValues.BurstBrowser.Settings.BVA_R2_static;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_R3_static')
            BurstData{file}.AdditionalParameters.BVA_R3_static = UserValues.BurstBrowser.Settings.BVA_R3_static;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_Rsigma1_static')
            BurstData{file}.AdditionalParameters.BVA_Rsigma1_static = UserValues.BurstBrowser.Settings.BVA_Rsigma1_static;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_Rsigma2_static')
            BurstData{file}.AdditionalParameters.BVA_Rsigma2_static = UserValues.BurstBrowser.Settings.BVA_Rsigma1_static;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_Rsigma3_static')
            BurstData{file}.AdditionalParameters.BVA_Rsigma3_static = UserValues.BurstBrowser.Settings.BVA_Rsigma1_static;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_KineticRatesTable2')
            BurstData{file}.AdditionalParameters.BVA_KineticRatesTable2 = UserValues.BurstBrowser.Settings.BVA_KineticRatesTable2;
        end
        if ~isfield(BurstData{file}.AdditionalParameters,'BVA_KineticRatesTable3')
            BurstData{file}.AdditionalParameters.BVA_KineticRatesTable3 = UserValues.BurstBrowser.Settings.BVA_KineticRatesTable3;
        end
        
        %%% Update GUI with values stored in BurstData Structure
        h.Rstate1_edit.String = num2str(BurstData{file}.AdditionalParameters.BVA_R1);
        h.Rstate2_edit.String = num2str(BurstData{file}.AdditionalParameters.BVA_R2);
        h.Rstate3_edit.String = num2str(BurstData{file}.AdditionalParameters.BVA_R3);
        h.Rsigma1_edit.String = num2str(BurstData{file}.AdditionalParameters.BVA_Rsigma1);
        h.Rsigma2_edit.String = num2str(BurstData{file}.AdditionalParameters.BVA_Rsigma2);
        h.Rsigma3_edit.String = num2str(BurstData{file}.AdditionalParameters.BVA_Rsigma3);
        h.Rstate1st_edit.String = num2str(BurstData{file}.AdditionalParameters.BVA_R1_static);
        h.Rstate2st_edit.String = num2str(BurstData{file}.AdditionalParameters.BVA_R2_static);
        h.Rstate3st_edit.String = num2str(BurstData{file}.AdditionalParameters.BVA_R3_static);
        h.Rsigma1st_edit.String = num2str(BurstData{file}.AdditionalParameters.BVA_Rsigma1_static);
        h.Rsigma2st_edit.String = num2str(BurstData{file}.AdditionalParameters.BVA_Rsigma2_static);
        h.Rsigma3st_edit.String = num2str(BurstData{file}.AdditionalParameters.BVA_Rsigma3_static);
        h.KineticRates_table2.Data = num2cell(BurstData{file}.AdditionalParameters.BVA_KineticRatesTable2);
        h.KineticRates_table3.Data = num2cell(BurstData{file}.AdditionalParameters.BVA_KineticRatesTable3);
        h.KineticRates_table3.Data(1,1) = {NaN};h.KineticRates_table2.Data(1,1) = {NaN};
        h.KineticRates_table3.Data(2,2) = {NaN};h.KineticRates_table2.Data(2,2) = {NaN};
        h.KineticRates_table3.Data(3,3) = {NaN};
    end
else
    switch obj
        case {h.KineticRates_table2,h.KineticRates_table3}
            h.KineticRates_table3.Data(1,1) = {NaN};h.KineticRates_table2.Data(1,1) = {NaN};
            h.KineticRates_table3.Data(2,2) = {NaN};h.KineticRates_table2.Data(2,2) = {NaN};
            h.KineticRates_table3.Data(3,3) = {NaN};
            UserValues.BurstBrowser.Settings.BVA_KineticRatesTable2 = cell2mat(h.KineticRates_table2.Data);
            UserValues.BurstBrowser.Settings.BVA_KineticRatesTable3 = cell2mat(h.KineticRates_table3.Data);
            BurstData{file}.AdditionalParameters.BVA_KineticRatesTable2 = UserValues.BurstBrowser.Settings.BVA_KineticRatesTable2;
            BurstData{file}.AdditionalParameters.BVA_KineticRatesTable3 = UserValues.BurstBrowser.Settings.BVA_KineticRatesTable3;
        case h.Rstate1_edit
            UserValues.BurstBrowser.Settings.BVA_R1 = str2double(h.Rstate1_edit.String);
            BurstData{file}.AdditionalParameters.BVA_R1 = UserValues.BurstBrowser.Settings.BVA_R1;
        case h.Rstate2_edit
            UserValues.BurstBrowser.Settings.BVA_R2
            BurstData{file}.AdditionalParameters.BVA_R2 = UserValues.BurstBrowser.Settings.BVA_R2;
        case h.Rstate3_edit
            UserValues.BurstBrowser.Settings.BVA_R3 = str2double(h.Rstate3_edit.String);
            BurstData{file}.AdditionalParameters.BVA_R3 = UserValues.BurstBrowser.Settings.BVA_R3;
        case h.Rsigma1_edit
            UserValues.BurstBrowser.Settings.BVA_Rsigma1 = str2double(h.Rsigma1_edit.String);
            BurstData{file}.AdditionalParameters.BVA_Rsigma1 = UserValues.BurstBrowser.Settings.BVA_Rsigma1;
        case h.Rsigma2_edit
            UserValues.BurstBrowser.Settings.BVA_Rsigma2 = str2double(h.Rsigma2_edit.String);
            BurstData{file}.AdditionalParameters.BVA_Rsigma2 = UserValues.BurstBrowser.Settings.BVA_Rsigma2;
        case h.Rsigma3_edit
            UserValues.BurstBrowser.Settings.BVA_Rsigma3 = str2double(h.Rsigma3_edit.String);
            BurstData{file}.AdditionalParameters.BVA_Rsigma3 = UserValues.BurstBrowser.Settings.BVA_Rsigma3;
        case h.Rstate1st_edit
            UserValues.BurstBrowser.Settings.BVA_R1_static = str2double(h.Rstate1st_edit.String);
            BurstData{file}.AdditionalParameters.BVA_R1_static = UserValues.BurstBrowser.Settings.BVA_R1_static;
        case h.Rstate2st_edit
            UserValues.BurstBrowser.Settings.BVA_R2_static = str2double(h.Rstate2st_edit.String);
            BurstData{file}.AdditionalParameters.BVA_R2_static = UserValues.BurstBrowser.Settings.BVA_R2_static;
        case h.Rstate3st_edit
            UserValues.BurstBrowser.Settings.BVA_R3_static = str2double(h.Rstate3st_edit.String);
            BurstData{file}.AdditionalParameters.BVA_R3_static = UserValues.BurstBrowser.Settings.BVA_R3_static;
        case h.Rsigma1st_edit
            UserValues.BurstBrowser.Settings.BVA_Rsigma1_static = str2double(h.Rsigma1st_edit.String);
            BurstData{file}.AdditionalParameters.BVA_Rsigma1_static = UserValues.BurstBrowser.Settings.BVA_Rsigma1_static;
        case h.Rsigma2st_edit
            UserValues.BurstBrowser.Settings.BVA_Rsigma2_static = str2double(h.Rsigma2st_edit.String);
            BurstData{file}.AdditionalParameters.BVA_Rsigma2_static = UserValues.BurstBrowser.Settings.BVA_Rsigma2_static;
        case h.Rsigma3st_edit
            UserValues.BurstBrowser.Settings.BVA_Rsigma3_static = str2double(h.Rsigma3st_edit.String);
            BurstData{file}.AdditionalParameters.BVA_Rsigma3_static = UserValues.BurstBrowser.Settings.BVA_Rsigma3_static;
        case h.DynamicStates_Popupmenu
            UserValues.BurstBrowser.Settings.BVA_DynamicStates = h.DynamicStates_Popupmenu.Value+1; 
            switch UserValues.BurstBrowser.Settings.BVA_DynamicStates
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
        case h.StaticStates_Popupmenu
            UserValues.BurstBrowser.Settings.BVA_StaticStates = h.StaticStates_Popupmenu.Value+1; 
            switch UserValues.BurstBrowser.Settings.BVA_StaticStates
                case 2
                    h.state3st_text.Visible = 'off';
                    h.Rstate3st_text.Visible = 'off';
                    h.Rstate3st_edit.Visible = 'off';
                    h.Rsigma3st_text.Visible = 'off';
                    h.Rsigma3st_edit.Visible = 'off';
                case 3
                    h.state3st_text.Visible = 'on';
                    h.Rstate3st_text.Visible = 'on';
                    h.Rstate3st_edit.Visible = 'on';
                    h.Rsigma3st_text.Visible = 'on';
                    h.Rsigma3st_edit.Visible = 'on';
            end
        case h.DynamicAnalysisMethod_Popupmenu
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
        case h.BinNumber_edit
            UserValues.BurstBrowser.Settings.NumberOfBins_BVA = str2double(h.BinNumber_edit.String);
        case h.BurstsPerBin_edit
            UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA = str2double(h.BurstsPerBin_edit.String);
        case h.ConfidenceInterval_edit
            UserValues.BurstBrowser.Settings.ConfidenceSampling_BVA = str2double(h.ConfidenceInterval_edit.String);
        case h.PhotonsPerWindow_edit
            UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA = str2double(h.PhotonsPerWindow_edit.String);
        case h.Xaxis_Popupmenu
            UserValues.BurstBrowser.Settings.BVA_X_axis = h.Xaxis_Popupmenu.Value;
        case h.FRETpair_Popupmenu
            UserValues.BurstBrowser.Settings.FRETpair = h.FRETpair_Popupmenu.Value;
        case h.ModelComparison_checkbox
            UserValues.BurstBrowser.Settings.BVA_ModelComparison = h.ModelComparison_checkbox.Value;
        case h.DynFRETLine_checkbox
            UserValues.BurstBrowser.Settings.BVAdynFRETline = h.DynFRETLine_checkbox.Value;
        case h.ConsistencyMethod_Popupmenu
            UserValues.BurstBrowser.Settings.Dynamic_Analysis_Method = h.ConsistencyMethod_Popupmenu.Value;
        case h.ConsistencyAnalysis_Button
            BurstData{file}.AdditionalParameters.BVA_KineticRatesTable2 = cell2mat(h.KineticRates_table2.Data);
            BurstData{file}.AdditionalParameters.BVA_KineticRatesTable3 = cell2mat(h.KineticRates_table3.Data);
            BurstData{file}.AdditionalParameters.BVA_R1 = str2double(h.Rstate1_edit.String);
            BurstData{file}.AdditionalParameters.BVA_R2 = str2double(h.Rstate2_edit.String);
            BurstData{file}.AdditionalParameters.BVA_R3 = str2double(h.Rstate3_edit.String);
            BurstData{file}.AdditionalParameters.BVA_Rsigma1 = str2double(h.Rsigma1_edit.String);
            BurstData{file}.AdditionalParameters.BVA_Rsigma2 = str2double(h.Rsigma2_edit.String);
            BurstData{file}.AdditionalParameters.BVA_Rsigma3 = str2double(h.Rsigma3_edit.String);
            BurstData{file}.AdditionalParameters.BVA_R1_static = str2double(h.Rstate1st_edit.String);
            BurstData{file}.AdditionalParameters.BVA_R2_static = str2double(h.Rstate2st_edit.String);
            BurstData{file}.AdditionalParameters.BVA_R3_static = str2double(h.Rstate3st_edit.String);
            BurstData{file}.AdditionalParameters.BVA_Rsigma1_static = str2double(h.Rsigma1st_edit.String);
            BurstData{file}.AdditionalParameters.BVA_Rsigma2_static = str2double(h.Rsigma2st_edit.String);
            BurstData{file}.AdditionalParameters.BVA_Rsigma3_static = str2double(h.Rsigma3st_edit.String);
    end
end
LSUserValues(1);
end
