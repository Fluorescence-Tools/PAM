function BurstBrowser_KeyPress(obj,eventdata)
if ~isempty(obj)
    h = guidata(obj);
else
    h = guidata(findobj('Tag','BurstBrowser'));
end
if ~isempty(eventdata.Modifier)
    switch eventdata.Modifier{1}
        case {'control','command'}
            %%% File Menu Controls
            switch eventdata.Key
                case 'n'
                    %%% Load File
                    Load_Burst_Data_Callback(h.Load_Bursts,[])
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
                case 'p'
                    %%% Print currently selected axes to clipboard using
                    %%% ExportGraphs function
                    copy_figure_to_clipboard();
            end
    end
else
    switch eventdata.Key
        case 'space' %%% arbitrary cut
            ManualCut(h.ArbitraryCutButton,[])
    end
end