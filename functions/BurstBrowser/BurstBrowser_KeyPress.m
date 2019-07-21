function BurstBrowser_KeyPress(obj,eventdata)
h = guidata(obj);
if ~isempty(eventdata.Modifier)
    switch eventdata.Modifier{1}
        case 'control'
            %%% File Menu Controls
            switch eventdata.Key
                case 'n'
                    %%% Load File
                    Load_Burst_Data_Callback([],[])
                case 's'
                    %%% Save Analysis State
                    Save_Analysis_State_Callback([],[])
                case 'q'
                    %%% Close Application
                    Close_BurstBrowser([],[])
                case 'space'
                    %%% Manual Cut
                     ManualCut(h.CutButton,[])
                case 't'
                    %%% open notepad
                    Open_Notepad([],[])
                case 'c'
                    %%% Copy currently selected x-parameter to clipboard
                    Param_to_clip([],[]);
            end
    end
else
    switch eventdata.Key
        case 'space' %%% arbitrary cut
            ManualCut(h.ArbitraryCutButton,[])
    end
end