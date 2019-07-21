%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Update the print path %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Choose_PrintPath_Menu(obj,~)
global UserValues BurstData BurstMeta
h = guidata(obj);
switch obj
    case h.Choose_PrintPath_Menu
        try
            PathName = uigetdir(UserValues.BurstBrowser.PrintPath, 'Choose a folder to place files into');
        catch
            path = pwd;
            PathName = uigetdir(path, 'Choose a folder to place files into');
        end

        if PathName == 0
            return;
        end
        UserValues.BurstBrowser.PrintPath = PathName;
    case h.Autoset_PrintPath_Menu
        switch obj.Checked
            case 'off'
                if ~isempty(BurstData)
                    PathName = BurstData{BurstMeta.SelectedFile}.PathName;
                end
                obj.Checked = 'on';
                UserValues.BurstBrowser.Settings.UseFilePathForExport = 1;
                h.Choose_PrintPath_Menu.Enable = 'off';
                h.Current_PrintPath_Menu.Enable = 'off';
            case 'on'
                obj.Checked = 'off';
                UserValues.BurstBrowser.Settings.UseFilePathForExport = 0;
                PathName = UserValues.BurstBrowser.PrintPath;
                h.Choose_PrintPath_Menu.Enable = 'on';
                h.Current_PrintPath_Menu.Enable = 'on';
        end
end
h.Current_PrintPath_Text.Label = UserValues.BurstBrowser.PrintPath;
LSUserValues(1);