%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates GUI elements in fFCS tab and Lifetime Tab %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_fFCS_GUI(obj,~,h)
global BurstData BurstMeta UserValues
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end
if isempty(obj) || ~any(obj == [h.fFCS_Species1_popupmenu, h.fFCS_Species2_popupmenu])
    %%% Update the lists
    file = BurstMeta.SelectedFile;
    species = BurstData{file}.SelectedSpecies;
    if all(species == [0,0])
        num_species = 0;
    else
        num_species = sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
    end
    if num_species > 1
        species_names = BurstData{file}.SpeciesNames(species(1),2:num_species);
        if isfield(BurstMeta,'fFCS') && isfield(BurstMeta.fFCS,'syntheticpatterns_names')
            species_names = [species_names,BurstMeta.fFCS.syntheticpatterns_names];
        end
        species_names = [species_names,{'Load synthetic pattern...'}];
        h.fFCS_Species1_popupmenu.String = species_names;
        h.fFCS_Species1_popupmenu.Value = 1;
        h.fFCS_Species2_popupmenu.String = species_names;
        if num_species > 2
            h.fFCS_Species2_popupmenu.Value = 2;
        else
            h.fFCS_Species2_popupmenu.Value = 1;
        end
        h.Plot_Microtimes_button.Enable = 'on';
    else %%% Set to empty
        h.fFCS_Species1_popupmenu.String = 'Load synthetic pattern...';
        h.fFCS_Species1_popupmenu.Value = 1;
        h.fFCS_Species2_popupmenu.String = 'Load synthetic pattern...';
        h.fFCS_Species2_popupmenu.Value = 1;
        h.Plot_Microtimes_button.Enable = 'off';
        h.Calc_fFCS_Filter_button.Enable = 'off';
        h.Do_fFCS_button.Enable = 'off';
    end
else
    %%% popupmenu selection was changed
    if obj.Value == numel(obj.String) %%% we clicked the last element, which is used to load a synthetic pattern
        [FileName,PathName] = uigetfile({'*.mi','Microtime pattern (*.mi)'},'Choose a synthetic microtime pattern',UserValues.File.BurstBrowserPath);
        if FileName == 0
            return;
        end
        if ~isfield(BurstMeta,'fFCS')
            BurstMeta.fFCS = [];
        end
        if ~isfield(BurstMeta.fFCS,'syntheticpatterns_names')
            BurstMeta.fFCS.syntheticpatterns_names = [];
        end
        BurstMeta.fFCS.syntheticpatterns_names{end+1} = FileName(1:end-3);
        if ~isfield(BurstMeta.fFCS,'syntheticpatterns')
            BurstMeta.fFCS.syntheticpatterns = [];
        end
        BurstMeta.fFCS.syntheticpatterns{end+1} = load(fullfile(PathName,FileName),'-mat');
        Update_fFCS_GUI([],[]);
    else
        %%% a different pattern was selected, do nothing
    end
end