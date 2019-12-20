%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Callback for Parameter List: Left-click updates plot,    %%%%%%%%%%
%%%%%%% Right-click adds parameter to CutList                    %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ParameterList_ButtonDownFcn(jListbox,eventData,hListbox)
global BurstData BurstMeta
if isempty(BurstData)
    return;
end

h = guidata(hListbox);
file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;
[file_n,species_n,subspecies_n] = get_multiselection(h);

if eventData.isMetaDown % right-click is like a Meta-button
    clickType = 'right';
else
    clickType = 'left';
end

% Determine the current listbox index
% Remember: Java index starts at 0, Matlab at 1
mousePos = java.awt.Point(eventData.getX, eventData.getY);
clickedIndex = jListbox.locationToIndex(mousePos) + 1;
if strcmpi(clickType,'right')
    %%% check if master species is selected
    if all(species == [0,0])
        disp('Cuts can not be applied to total data set. Select a species first.');
        return;
    end

    %%% add to cut list if right-clicked
    param = clickedIndex;
    
    %%% apply to all selected species
    [file_n,species_n,subspecies_n] = get_multiselection(h);
    for i = 1:numel(file_n)
        AddCutToSpecies(param,file_n(i),[species_n(i),subspecies_n(i)]);
    end
    
    UpdateCutTable(h);
    UpdateCuts();    
elseif strcmpi(clickType,'left') %%% Update Plot
    %%% Update selected value
    hListbox.Value = clickedIndex;
end
UpdatePlot([],[],h);