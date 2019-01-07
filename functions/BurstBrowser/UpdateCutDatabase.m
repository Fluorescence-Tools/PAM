%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Callback of CutSelection Popupmenu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateCutDatabase(obj,eventData)
global UserValues BurstData BurstMeta
h = guidata(obj);

if ~isempty(BurstData)
    %%% check burst method
    %%% 1 for 2color, 2 for 3color
    switch BurstData{BurstMeta.SelectedFile}.BAMethod
        case {1,2,5}
            BAMethod = 1;
        case {3,4}
            BAMethod = 2;
    end
else %%% fall back to 2C
    BAMethod = 1;
end

switch obj
    case {h.ApplyCutDatabase, h.AddCutDatabase} %%% button was clicked
        %%% check if cuts are available
        if isempty(fieldnames(UserValues.BurstBrowser.CutDatabase{BAMethod}))
            disp('No cuts stored!');
            return;
        end
        %%% read out cut
        cutName = h.CutDatabase.String{h.CutDatabase.Value};
        cutToApply = UserValues.BurstBrowser.CutDatabase{BAMethod}.(cutName);
        switch obj
            case h.ApplyCutDatabase
                %%% apply to selected species
                if ~h.MultiselectOnCheckbox.UserData
                    file_n = BurstMeta.SelectedFile;
                    species_n = BurstData{file_n}.SelectedSpecies(1);
                    subspecies_n = BurstData{file_n}.SelectedSpecies(2);
                else
                    [file_n,species_n,subspecies_n] = get_multiselection(h);
                end
                for f = 1:numel(file_n)
                    file = file_n(f);
                    species = [species_n(f), subspecies_n(f)];
                    for i = 1:numel(cutToApply)
                        paramName  = cutToApply{i}{1};
                        %%% Check whether the CutParameter already exists or not
                        ExistingCuts = vertcat(BurstData{file}.Cut{species(1),species(2)}{:});
                        paramExists = false;
                        if ~isempty(ExistingCuts)
                            if any(strcmp(paramName,ExistingCuts(:,1)))
                                paramExists = find(strcmp(paramName,ExistingCuts(:,1)));
                            else
                                paramExists = false;
                            end
                        end
                        if paramExists
                            %%% override boundaries
                            BurstData{file}.Cut{species(1),species(2)}{paramExists}{2} = cutToApply{i}{2};
                            BurstData{file}.Cut{species(1),species(2)}{paramExists}{3} = cutToApply{i}{3};
                        else
                            %%% append to Cut Array
                            BurstData{file}.Cut{species(1),species(2)}{end+1} = cutToApply{i};
                        end

                        %%% If Global Cuts, Update all other species
                        if species(2) == 1
                            ChangedParameterName = paramName;
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
                end
            case h.AddCutDatabase
                file = BurstMeta.SelectedFile;
                %%% add a new top level species
                BurstData{file}.SpeciesNames{end+1,1} = cutName;
                BurstData{file}.Cut{end+1,1} = cutToApply;
                UpdateSpeciesList(h);
        end
        %%% Update Cuts
        UpdateCutTable(h);
        UpdateCuts();
        
        %%% Update Plot
        UpdatePlot([],[],h);
        UpdateLifetimePlots([],[],h);
    case h.RemoveCutDatabase_Menu
        %%% check if cuts are available
        if isempty(fieldnames(UserValues.BurstBrowser.CutDatabase{BAMethod}))
            disp('No cuts stored!');
            return;
        end
        %%% remove field from database
        currentCut = h.CutDatabase.String{h.CutDatabase.Value};
        UserValues.BurstBrowser.CutDatabase{BAMethod} = rmfield(UserValues.BurstBrowser.CutDatabase{BAMethod},currentCut);
        %%% Refresh GUI
        if ~isempty(fieldnames(UserValues.BurstBrowser.CutDatabase{BAMethod}))
            h.CutDatabase.String = fieldnames(UserValues.BurstBrowser.CutDatabase{BAMethod});
        else
            h.CutDatabase.String = '-';
        end
        LSUserValues(1);
    case h.StoreInCutDatabase_Menu %%% add cut to database
        file = BurstMeta.SelectedFile;
        species = BurstData{file}.SelectedSpecies;
        if all(species == [0,0])
            return;
        end
        %%% query name
        CutName = inputdlg('Specify the new cut name:','Adding cut to database...',[1 50],{'New Cut'},'on');
        if ~isempty(CutName)
            CutName = CutName{1};
            CutName = matlab.lang.makeValidName(CutName); %%% make it a valid variable name
            Cut = BurstData{file}.Cut{species(1),species(2)}; %%% read out the cut
            del = false(size(Cut));
            for i = 1:numel(Cut) %%% remove Arbitrary Region cuts
                if strcmp(Cut{i}{1}(1:4),'AR: ')
                    del(i) = true;
                end
            end
            Cut(del) = [];
            UserValues.BurstBrowser.CutDatabase{BAMethod}.(CutName) = Cut;
        end
        %%% Refresh GUI
        h.CutDatabase.String = fieldnames(UserValues.BurstBrowser.CutDatabase{BAMethod});
        LSUserValues(1);
    case h.PrintDatabaseCut_Menu
        %%% read out cut
        cutName = h.CutDatabase.String{h.CutDatabase.Value};
        %%% print output
        disp(sprintf('Cuts for database entry:\t%s',cutName));
        currentCut = UserValues.BurstBrowser.CutDatabase{BAMethod}.(cutName);
        currentCut = vertcat(currentCut{:});
        currentCut = currentCut(:,1:3);
        output = table(currentCut(:,1),cell2mat(currentCut(:,2)),cell2mat(currentCut(:,3)),'VariableNames',{'Parameter','min','max'});
        str = evalc('disp(output)');
        disp(str);
        str = strrep(str,'<strong>','');str = strrep(str,'</strong>','');
        msgbox(str,cutName);
end