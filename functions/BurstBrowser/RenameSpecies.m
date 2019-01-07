%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Rename Selected Species (Right-click menu item)  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RenameSpecies(~,~)
global BurstData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;
SelectedSpeciesName = BurstData{file}.SpeciesNames{species(1),species(2)};
NewName = inputdlg('Specify the new species name','Rename Species',[1 50],{SelectedSpeciesName},'on');

if ~isempty(NewName)
    BurstData{file}.SpeciesNames{species(1),species(2)} = NewName{1};
    UpdateSpeciesList(h);
end
Update_fFCS_GUI([],[]);