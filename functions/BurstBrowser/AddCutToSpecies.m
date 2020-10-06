function AddCutToSpecies(param,file,species)
%%% Adds a new parameter to a species as a cut
global BurstData
%%% Check whether the CutParameter already exists or not
ExistingCuts = vertcat(BurstData{file}.Cut{species(1),species(2)}{:});
if ~isempty(ExistingCuts)
    if any(strcmp(BurstData{file}.NameArray{param},ExistingCuts(:,1)))
        return;
    end
end

%%% use default limits for FRET efficiency and Stoichiometry
switch BurstData{file}.NameArray{param}
    case {'FRET Efficiency','FRET Efficiency GR','FRET Efficiency BG','FRET Efficiency BR'}
        lower = -0.1;
        upper = 1;
    case {'Stoichiometry','Stoichiometry GR','Stoichiometry BG','Stoichiometry BR'}
        lower = 0;
        upper = 1;
    case {'Anisotropy RR','Anisotropy GG','Anisotropy BB','Anisotropy A','Anisotropy D'}
        lower = -0.2;
        upper = 0.6;
    otherwise  
        lower = min(BurstData{file}.DataCut(~isinf(BurstData{file}.DataCut(:,param)),param));
        upper = max(BurstData{file}.DataCut(~isinf(BurstData{file}.DataCut(:,param)),param));
end

BurstData{file}.Cut{species(1),species(2)}{end+1} = {BurstData{file}.NameArray{param}, lower,upper, true,false};

%%% If Global Cuts, Update all other species
if species(2) == 1
    ChangedParameterName = BurstData{file}.NameArray{param};
    %%% find number of species for species group
    num_species = sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
    if num_species > 1 %%% Check if there are other species defined
        %%% cycle through the number of other species
        for j = 2:num_species
            %%% Check if the parameter already exists in the species j
            ParamList = vertcat(BurstData{file}.Cut{species(1),j}{:});
            if ~isempty(ParamList)
                ParamList = ParamList(1:numel(BurstData{file}.Cut{species(1),j}),1);
                CheckParam = strcmp(ParamList,ChangedParameterName);
                if any(CheckParam)
                    %%% do nothing
                else %%% Parameter is new to species
                    BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(end);
                end
            else %%% Parameter is new to GlobalCut
                BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(end);
            end
        end
    end
end