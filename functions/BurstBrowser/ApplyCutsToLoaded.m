%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Applies Cuts to all Loaded files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ApplyCutsToLoaded(obj,~)
global BurstMeta BurstData
h = guidata(obj);
file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;
if species(2) > 1
    disp('Only implemented for top level species');
    return;
end
speciesname = BurstData{file}.SpeciesNames{species(1),species(2)};
%%% read out cuts of currently selected species
currentCuts = BurstData{file}.Cut{species(1),species(2)};
%%% Synchronize all other top-level species
for i = 1:numel(BurstData)
    if i == file
        continue;
    end
    %%% Check if species with same name exists
    if any(strcmp(BurstData{i}.SpeciesNames(:,1),speciesname))
        targetSpecies = strcmp(BurstData{i}.SpeciesNames(:,1),speciesname);
        for j = 1:numel(currentCuts)
            %%% Check if the parameter already exists in the species j
            ParamList = vertcat(BurstData{i}.Cut{targetSpecies,1}{:});
            if ~isempty(ParamList)
                ParamList = ParamList(:,1);
                CheckParam = strcmp(ParamList,currentCuts{j}{1});
                if any(CheckParam) %%% parameter exists
                    %%% overwrite limits and active state
                    BurstData{i}.Cut{targetSpecies,1}{CheckParam}(2:4) = currentCuts{j}(2:4);
                else
                    %%% parameter is new
                    BurstData{i}.Cut{targetSpecies,1}(end+1) = currentCuts(j);
                end
            else %%% parameter is new
                BurstData{i}.Cut{targetSpecies,1}(end+1) = currentCuts(j);
            end
        end
    else %%% add a species with this name
        BurstData{i}.Cut{end+1,1} = currentCuts;
        BurstData{i}.SpeciesNames{end+1,1} = speciesname;
        BurstData{i}.SelectedSpecies = [size(BurstData{i}.SpeciesNames,1),1];
    end
end

UpdateSpeciesList(h);