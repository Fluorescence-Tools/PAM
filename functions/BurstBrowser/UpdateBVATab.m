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
end
    

% switch obj 
%     case {h.KineticRates_table3,h.KineticRates_table2}
%         %%% if diagonal elements were clicked, reset them to NaN to indicate
%         %%% that they are not used
%         h.KineticRates_table.Data3(1,1) = {NaN};h.KineticRates_table2.Data(1,1) = {NaN};
%         h.KineticRates_table.Data3(2,2) = {NaN};h.KineticRates_table2.Data(2,2) = {NaN};
%         h.KineticRates_table.Data3(3,3) = {NaN};
%         UserValues.BurstBrowser.Settings.BVA_k21 = cell2mat(h.KineticRates_table3.Data(1,2));
%         UserValues.BurstBrowser.Settings.BVA_k31 = cell2mat(h.KineticRates_table3.Data(1,3));
%         UserValues.BurstBrowser.Settings.BVA_k12 = cell2mat(h.KineticRates_table3.Data(2,1));
%         UserValues.BurstBrowser.Settings.BVA_k32 = cell2mat(h.KineticRates_table3.Data(2,3));
%         UserValues.BurstBrowser.Settings.BVA_k13 = cell2mat(h.KineticRates_table3.Data(3,1));
%         UserValues.BurstBrowser.Settings.BVA_k23 = cell2mat(h.KineticRates_table3.Data(3,2));
%         
%         UserValues.BurstBrowser.Settings.BVA_k21 = cell2mat(h.KineticRates_table2.Data(1,2));
%         UserValues.BurstBrowser.Settings.BVA_k12 = cell2mat(h.KineticRates_table2.Data(2,1));
%     case h.Rstate1_edit
%         UserValues.BurstBrowser.Settings.BVA_R1 = cell2mat(h.Rstate1_edit.String);
%     case h.Rstate2_edit
%         UserValues.BurstBrowser.Settings.BVA_R2 = cell2mat(h.Rstate2_edit.String);
%     case h.Rstate3_edit
%         UserValues.BurstBrowser.Settings.BVA_R3 = cell2mat(h.Rstate3_edit.String);
%     case h.Rsigma1_edit
%         UserValues.BurstBrowser.Settings.BVA_R1 = cell2mat(h.Rsgima1_edit.String);
%     case h.Rsigma2_edit
%         UserValues.BurstBrowser.Settings.BVA_R1 = cell2mat(h.Rsgima2_edit.String);
%     case h.Rsigma3_edit
%         UserValues.BurstBrowser.Settings.BVA_R1 = cell2mat(h.Rsgima3_edit.String);
%     case h.BVA_Nstates_Popupmenu
%         UserValues.BurstBrowser.Settings.BVA_Nstates = h.BVA_Nstates_Popupmenu.Value+1; 
%         switch UserValues.BurstBrowser.Settings.BVA_Nstates
%             case 2
%                 h.KineticRates_table3.Visible = 'off';
%                 h.KineticRates_table2.Visible = 'on';
%                 h.state3_text.Visible = 'off';
%                 h.Rstate3_text.Visible = 'off';
%                 h.Rstate3_edit.Visible = 'off';
%                 h.Rsigma3_text.Visible = 'off';
%                 h.Rsigma3_edit.Visible = 'off';
%             case 3
%                 h.KineticRates_table2.Visible = 'off';
%                 h.KineticRates_table3.Visible = 'on';
%                 h.state3_text.Visible = 'on';
%                 h.Rstate3_text.Visible = 'on';
%                 h.Rstate3_edit.Visible = 'on';
%                 h.Rsigma3_text.Visible = 'on';
%                 h.Rsigma3_edit.Visible = 'on';
%         end
% end
