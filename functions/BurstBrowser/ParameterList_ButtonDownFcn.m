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
%file = BurstMeta.SelectedFile;
%species = BurstData{file}.SelectedSpecies;
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
    for i = 1:numel(file_n);
        file = file_n(i);
        species = [species_n(i), subspecies_n(i)];
        %%% check if master species is selected
        if all(species == [0,0])
            disp('Cuts can not be applied to total data set. Select a species first.');
            return;
        end

        %%%add to cut list if right-clicked
        param = clickedIndex;

        %%% Check whether the CutParameter already exists or not
        ExistingCuts = vertcat(BurstData{file}.Cut{species(1),species(2)}{:});
        if ~isempty(ExistingCuts)
            if any(strcmp(BurstData{file}.NameArray{param},ExistingCuts(:,1)))
                return;
            end
        end

        %%% use default limits for FRET efficiency and Stoichiometry
        switch BurstData{file}.NameArray{clickedIndex}
            case {'FRET Efficiency','FRET Efficiency GR','FRET Efficiency BG','FRET Efficiency BR','FRET Efficiency B->G+R','Proximity Ratio GR','Proximity Ratio BG','Proximity Ratio BR'}
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
    end
    UpdateCutTable(h);
    UpdateCuts();    
elseif strcmpi(clickType,'left') %%% Update Plot
    %%% Update selected value
    hListbox.Value = clickedIndex;
end
UpdatePlot([],[],h);