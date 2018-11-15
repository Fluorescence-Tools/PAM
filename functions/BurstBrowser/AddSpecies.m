%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Add Species to List (Right-click menu item)  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AddSpecies(~,~)
global BurstData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));

file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;
% distinguish between top level ('Species') or SpeciesGroup 
% using name --> level = 0,1
if all(species == [0,0])
    return;
elseif species(2) == 1
    level = 1;
elseif species(2) > 1
    level = 2;
end

switch level
    case 1
        % add a species group to top level
        % use default cut template
        switch BurstData{file}.BAMethod
            case {1,2,5}
                %%% FRET efficiency and stoichiometry basic cuts
                Cut = {{'FRET Efficiency',-0.1,1.1,true,false},{'Stoichiometry',-0.1,1.1,true,false}};
            case {3,4}
                %%% 3color, only do FRET GR and Stoichiometry cuts
                Cut = {{'FRET Efficiency GR',-0.1,1.1,true,false},{'Stoichiometry GR',-0.1,1.1,true,false},...
                    {'Stoichiometry BG',-0.1,1.1,true,false},{'Stoichiometry BR',-0.1,1.1,true,false}};
        end
        name = ['Species ' num2str(size(BurstData{file}.SpeciesNames,1)+1)];
        BurstData{file}.SpeciesNames{end+1,1} = name;
        BurstData{file}.Cut{end+1,1} = Cut;
        BurstData{file}.SelectedSpecies = [size(BurstData{file}.SpeciesNames,1),1];
        %%% add two subspecies
        BurstData{file}.SpeciesNames{end,2} = 'Subspecies 1';
        BurstData{file}.SpeciesNames{end,3} = 'Subspecies 2';
        BurstData{file}.Cut{end,2} = Cut; BurstData{file}.Cut{end,3} = Cut;
    case 2
        % add species to species group
        % check if species group exists
        if ~isempty(BurstData{file}.SpeciesNames{species(1),species(2)})
            % find out number of existing species for species group
            num_species= sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
            name = ['Subspecies ' num2str(num_species)];
            BurstData{file}.SpeciesNames{species(1),num_species+1} = name;
            BurstData{file}.Cut{species(1),num_species+1} = BurstData{file}.Cut{species(1),1};
            BurstData{file}.SelectedSpecies(2) = num_species+1;
        end
end
        
UpdateSpeciesList(h);
h = guidata(gcf);drawnow;
UpdateCutTable(h);
UpdateCuts();
Update_fFCS_GUI([],[]);

UpdatePlot([],[],h);
UpdateLifetimePlots([],[],h);
PlotLifetimeInd([],[],h);