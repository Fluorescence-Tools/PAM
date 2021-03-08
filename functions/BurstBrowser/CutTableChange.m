%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Executes on change in the Cut Table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Cut Array and GUI/Plots     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CutTableChange(hObject,eventdata)
%this executes if a value in the CutTable is changed
h = guidata(hObject);
global BurstData BurstMeta
%check which cell was changed
index = eventdata.Indices;
index(2) = index(2)-1; %%% lower by one since we changed the parameter name to be in first column
[file_n,species_n,subspecies_n] = get_multiselection(h);

%read out the parameter name
file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;
ChangedParameterName = BurstData{BurstMeta.SelectedFile}.Cut{species(1),species(2)}{index(1)}{1};
%change value in structure
NewData = eventdata.NewData;
if isnan(NewData)
    hObject.Data{eventdata.Indices(1),eventdata.Indices(2)} = eventdata.PreviousData;
    return;
end
%%% Update Cuts of all selected species
for i = 1:numel(file_n)
    UpdateCutState(NewData,eventdata.PreviousData,index,ChangedParameterName,file_n(i),[species_n(i),subspecies_n(i)]);
end

%%% Update GUI elements
UpdateCutTable(h);
UpdateCuts();

%%% Update Plots
%%% To speed up, find out which tab is visible and only update the respective tab
switch h.Main_Tab.SelectedTab
    case h.Main_Tab_General
        %%% we switched to the general tab
        UpdatePlot([],[],h);
    case h.Main_Tab_Lifetime
        %%% we switched to the lifetime tab
        %%% figure out what subtab is selected
        UpdateLifetimePlots([],[],h);
        switch h.LifetimeTabgroup.SelectedTab
            case h.LifetimeTabAll
            case h.LifetimeTabInd
                PlotLifetimeInd([],[],h);
        end     
end

function UpdateCutState(NewData,PreviousData,index,ChangedParameterName,file,species)
global BurstData

%%% check if the parameter exists
params_in_species = vertcat(BurstData{file}.Cut{species(1),species(2)}{:});
param_index = find(strcmp(params_in_species(:,1),ChangedParameterName));
if isempty(param_index) %%% add parameter
    param = find(strcmp(BurstData{file}.NameArray,ChangedParameterName));
    AddCutToSpecies(param,file,species);
    param_index = numel(BurstData{file}.Cut{species(1),species(2)});
end
index(1)  = param_index; % update the index for this particular species

switch index(2)
    case {1} %min boundary was changed
        %%% if upper boundary is lower than new min boundary -> reject
        if BurstData{file}.Cut{species(1),species(2)}{index(1)}{3} < NewData
            NewData = PreviousData;
        end
        if species(2) ~= 1
            %%% if new lower boundary is lower than global lower boundary -->
            %%% reset to global lower boundary
            if ~isempty(BurstData{file}.Cut{species(1),1})
                %%% check whether the parameter exists in global cuts
                %%% already
                for l = 1:numel(BurstData{file}.Cut{species(1),1})
                    exist(l) = strcmp(BurstData{file}.Cut{species(1),1}{l}{1},BurstData{file}.Cut{species(1),species(2)}{index(1)}{1});
                end
                if any(exist == 1)
                    if NewData <= BurstData{file}.Cut{species(1)}{exist}{index(2)+1}
                        NewData = BurstData{file}.Cut{species(1)}{exist}{index(2)+1};
                    end
                end
            end
        end
    case {2} %max boundary was changed
        %%% if lower boundary is higher than new upper boundary --> reject
        if BurstData{file}.Cut{species(1),species(2)}{index(1)}{2} > NewData
            NewData = PreviousData;
        end
        if species(2) ~= 1
            %%% if new upper boundary is higher than global upper boundary -->
            %%% reset to global upper boundary
            if ~isempty(BurstData{file}.Cut{species(1),1})
                %%% check whether the parameter exists in global cuts
                %%% already
                for l = 1:numel(BurstData{file}.Cut{species(1),1})
                    exist(l) = strcmp(BurstData{file}.Cut{species(1),1}{l}{1},BurstData{file}.Cut{species(1),species(2)}{index(1)}{1});
                end
                if any(exist == 1)
                    if NewData >= BurstData{file}.Cut{species(1),1}{exist}{index(2)+1}
                        NewData = BurstData{file}.Cut{species(1),1}{exist}{index(2)+1};
                    end
                end
            end
        end
    case {3} %active/inactive change
        % unchanged
    case {5} % ZScale was changed
        %%% disable all other active components
        hObject = gco;
        for i = 1:size(hObject.Data)
            if i ~= index(1)
                hObject.Data{i,6} = false;
            end
        end
        %%% if arbitrary cut was clicked, prevent checking 
        if strcmp(ChangedParameterName(1:4),'AR: ')
            hObject.Data{index(1),6} = false;
        end
end

if index(2) < 4
    % assign the new value
    BurstData{file}.Cut{species(1),species(2)}{index(1)}{index(2)+1}=NewData;
elseif index(2) == 4 %delete this entry
    BurstData{file}.Cut{species(1),species(2)}(index(1)) = [];
    try
        BurstData{file}.ArbitraryCut{species(1),species(2)}(index(1)) = [];
    end
end

%%% If a change was made to the GlobalCuts Species, update all other
%%% existent species with the changes
if species(2) == 1
    %%% find number of species for species group
    num_species = sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
    if  num_species > 1 %%% Check if there are other species defined
        %%% cycle through the number of other species
        for j = 2:num_species
            %%% Check if the parameter already exists in the species j
            ParamList = vertcat(BurstData{file}.Cut{species(1),j}{:});
            if ~isempty(ParamList)
                ParamList = ParamList(1:numel(BurstData{file}.Cut{species(1),j}),1);
                CheckParam = strcmp(ParamList,ChangedParameterName);
                if any(CheckParam)
                    %%% Check whether to delete or change the parameter
                    if index(2) ~= 4 %%% Parameter added or changed
                        %%% Override the parameter with GlobalCut
                        %%% But only if it affects the boundaries of the
                        %%% species!
                        switch index(2)
                            case 1 %%% lower boundary changed
                                %%% If new global lower boundary is above
                                %%% species lower boundary, update
                                if BurstData{file}.Cut{species(1),1}{index(1)}{index(2)+1} > BurstData{file}.Cut{species(1),j}{CheckParam}{index(2)+1}
                                    BurstData{file}.Cut{species(1),j}{CheckParam}(index(2)+1) = BurstData{file}.Cut{species(1),1}{index(1)}(index(2)+1);
                                end
                            case 2 %%% upper boundary changed
                                %%% If new global upper boundary is below
                                %%% species upper boundary, update
                                if BurstData{file}.Cut{species(1),1}{index(1)}{index(2)+1} < BurstData{file}.Cut{species(1),j}{CheckParam}{index(2)+1}
                                    BurstData{file}.Cut{species(1),j}{CheckParam}(index(2)+1) = BurstData{file}.Cut{species(1),1}{index(1)}(index(2)+1);
                                end
                            case 3 %%% active changed
                                BurstData{file}.Cut{species(1),j}{CheckParam}(index(2)+1) = BurstData{file}.Cut{species(1),1}{index(1)}(index(2)+1);
                        end
                    elseif index(2) == 4 %%% Parameter was deleted
                        BurstData{file}.Cut{species(1),j}(CheckParam) = [];
                        try
                            BurstData{file}.ArbitraryCut{species(1),j}(CheckParam) = [];
                        end
                    end
                else %%% Parameter is new to species
                    if index(2) ~= 4 %%% Parameter added or changed
                        BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(index(1));
                    end
                end
            else %%% Parameter is new to GlobalCut
                if ~strcmp(ChangedParameterName(1:4),'AR: ') %%% make sure it is not an arbitrary selection
                    BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(index(1));
                end
            end
        end
    end
end
