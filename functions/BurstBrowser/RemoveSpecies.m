%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Remove Selected Species (Right-click menu item)  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RemoveSpecies(obj,eventData)
global BurstData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));

file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;
% distinguish between  SpeciesGroup or Species
% using name --> level = 1,2
if species(2) == 1
    level = 1;
elseif species(2) > 1
    level = 2;
elseif species(2) == 0
    level = 0;
end
switch level
    case 0
        %%% remove file
        BurstData{file} = [];
        for i = file:(numel(BurstData)-1);
            BurstData{i} = BurstData{i+1};
        end
        BurstData(end) = [];
        BurstMeta.SelectedFile = 1;
        UpdatePlot([],[],h);
        UpdateLifetimePlots([],[],h);
    case 1
        %%% remove entire species group
        %%% only remove if there are other groups left afterwards!
        if size(BurstData{file}.SpeciesNames,1) > 1
            BurstData{file}.SpeciesNames(species(1),:) = [];
            BurstData{file}.Cut(species(1),:) = [];
            BurstData{file}.SelectedSpecies(1)=species(1)-1;
        end
    case 2 %%% subspecies
        %%% only remove if there is more than 1 subspecies left
        if sum(cellfun(@(x) ~isempty(x),BurstData{file}.SpeciesNames(species(1),:))) >= 3
            %%% remove only the one field and shift right of it to the left
            BurstData{file}.SpeciesNames{species(1),species(2)} = [];
            temp = BurstData{file}.SpeciesNames(species(1),:);
            temp = temp(~cellfun(@isempty,temp));
            BurstData{file}.SpeciesNames(species(1),:) = [];
            BurstData{file}.SpeciesNames(species(1),1:numel(temp)) = temp;

            BurstData{file}.Cut{species(1),species(2)} = [];
            temp = BurstData{file}.Cut(species(1),:);
            temp = temp(cellfun(@iscell,temp));
            BurstData{file}.Cut(species(1),:) = [];
            BurstData{file}.Cut(species(1),1:numel(temp)) = temp;
        end
end

UpdateSpeciesList(h);
h = guidata(gcf);drawnow;
Update_fFCS_GUI([],[]);
