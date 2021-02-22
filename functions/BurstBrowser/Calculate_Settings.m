function Calculate_Settings(obj,~)
global UserValues BurstData BurstMeta
h = guidata(obj);
%%% Sets new divider
if obj == h.Secondary_Tab_Correlation_Divider_Menu
    %%% Opens input dialog and gets value
    Divider=inputdlg('New divider:');
    if ~isempty(Divider)
        h.Secondary_Tab_Correlation_Divider_Menu.Label = ['Divider: ' cell2mat(Divider)];
        try
            g = guidata(findobj('Tag','Pam'));
            g.Cor_Divider_Menu.Label = ['Divider: ' cell2mat(Divider)];
        end
        UserValues.Settings.Pam.Cor_Divider=round(str2double(Divider));
    end
elseif obj == h.Secondary_Tab_Correlation_Afterpulsing_Menu
    if strcmp(h.Secondary_Tab_Correlation_Afterpulsing_Menu.Checked,'on')
        h.Secondary_Tab_Correlation_Afterpulsing_Menu.Checked = 'off';
        UserValues.Settings.Pam.AfterpulsingCorrection = 0;
    else
        h.Secondary_Tab_Correlation_Afterpulsing_Menu.Checked = 'on';
        UserValues.Settings.Pam.AfterpulsingCorrection = 1;
    end
    %%% check if PAM is open, update value there
    hPAM = findobj('Tag','Pam');
    if ~isempty(hPAM)   
        hPAM = guidata(hPAM);
        hPAM.Cor.AfterPulsingCorrection.Value = UserValues.Settings.Pam.AfterpulsingCorrection;
    end
elseif obj == h.Secondary_Tab_Correlation_Standard2CMFD_Menu
    h.Correlation_Table.Data = false(size(h.Correlation_Table.Data));
    switch BurstData{BurstMeta.SelectedFile}.BAMethod
        case {1,2} %%% 2colorMFD
            h.Correlation_Table.Data(1,2) = true;
            h.Correlation_Table.Data(3,4) = true;
            h.Correlation_Table.Data(5,6) = true;
            h.Correlation_Table.Data(7,8) = true;
            h.Correlation_Table.Data(9,12) = true;
            h.Correlation_Table.Data(10,11) = true;
        case {5} %%% 2color no polarization
            h.Correlation_Table.Data(1,1) = true;
            h.Correlation_Table.Data(1,2) = true;
            h.Correlation_Table.Data(2,2) = true;
            h.Correlation_Table.Data(3,3) = true;
            h.Correlation_Table.Data(3,4) = true;
            h.Correlation_Table.Data(4,4) = true;
    end
elseif obj == h.Secondary_Tab_Correlation_Reset_Menu
    h.Correlation_Table.Data = false(size(h.Correlation_Table.Data));
end
%%% Saves UserValues
LSUserValues(1);