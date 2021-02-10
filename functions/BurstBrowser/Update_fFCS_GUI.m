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
if isempty(obj) || ~any(obj == [h.fFCS_Species1_popupmenu, h.fFCS_Species2_popupmenu, h.fFCS_Species3_popupmenu])
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
        species_names = [species_names,{'Load microtime pattern...'}];
        h.fFCS_Species1_popupmenu.String = species_names;
        h.fFCS_Species1_popupmenu.Value = 1;
        h.fFCS_Species2_popupmenu.String = species_names;
        h.fFCS_Species3_popupmenu.String = [{'-'},species_names];
        if num_species > 2
            h.fFCS_Species2_popupmenu.Value = 2;
        else
            h.fFCS_Species2_popupmenu.Value = 1;
        end
        if num_species > 3
            h.fFCS_Species3_popupmenu.Enable = 'on';
            h.fFCS_Species3_popupmenu.Value = 4;
        else
            h.fFCS_Species3_popupmenu.Enable = 'on';
            h.fFCS_Species3_popupmenu.Value = 1;
        end
        h.Plot_Microtimes_button.Enable = 'on';
    else %%% Set to empty
        h.fFCS_Species1_popupmenu.String = 'Load microtime pattern...';
        h.fFCS_Species1_popupmenu.Value = 1;
        h.fFCS_Species2_popupmenu.String = 'Load microtime pattern...';
        h.fFCS_Species2_popupmenu.Value = 1;
        h.fFCS_Species3_popupmenu.String = 'Load microtime pattern...';
        h.fFCS_Species3_popupmenu.Value = 1;
        h.Plot_Microtimes_button.Enable = 'off';
        h.Calc_fFCS_Filter_button.Enable = 'off';
        h.Do_fFCS_button.Enable = 'off';
    end
else
    %%% popupmenu selection was changed
    if obj.Value == numel(obj.String) %%% we clicked the last element, which is used to load a synthetic pattern
        [File,Path] = uigetfile({'*.mi','Microtime pattern (*.mi)'},'Load a microtime pattern',UserValues.File.BurstBrowserPath);
        if File == 0
            return;
        end
        File = {File};
        if ~isfield(BurstMeta,'fFCS')
            BurstMeta.fFCS = [];
        end
        if ~isfield(BurstMeta.fFCS,'syntheticpatterns_names')
            BurstMeta.fFCS.syntheticpatterns_names = [];
        end
        %BurstMeta.fFCS.syntheticpatterns_names{end+1} = FileName(1:end-3);
        if ~isfield(BurstMeta.fFCS,'syntheticpatterns')
            BurstMeta.fFCS.syntheticpatterns = [];
        end
        % previously, microtime patterns were stored as mat files
        %BurstMeta.fFCS.syntheticpatterns{end+1} = load(fullfile(PathName,FileName),'-mat');
        % now, they are stored as text files
        % read data from text files and store in "MIPattern" cell array
        PamMeta.fFCS.MIPattern = cell(0);
        PamMeta.fFCS.MIPattern_Name = cell(0);
        for i = 1:1%numel(File)
            header_lines = 0;
            while 1
                try
                    data = dlmread(fullfile(Path,File{i}),',',header_lines,0);
                    break;
                catch
                    %%% read text as stringvbnm
                    header_lines = header_lines + 1;
                end
            end
            %%% process header information
            fid = fopen(fullfile(Path,File{i}),'r');
            line = fgetl(fid);
            filename = textscan(line,'Microtime patterns of measurement: %s\n');
            for j = 1:(header_lines-1)
                line = fgetl(fid);
                temp = textscan(line,['Channel ' num2str(j) ': Detector %d and Routing %d\n']);
                Det(j) = temp{1};
                Rout(j) = temp{2};
            end
            fclose(fid);
            MIPattern = cell(0);
            for j = 1:numel(Det)
                MIPattern{Det(j),Rout(j)} = data(:,j);
            end
            [~,patternname,~] = fileparts(filename{1}{1});
            idx = find(strcmp(patternname,BurstMeta.fFCS.syntheticpatterns_names));
            if isempty(idx)
                BurstMeta.fFCS.syntheticpatterns_names{end+1} = patternname;
                BurstMeta.fFCS.syntheticpatterns{end+1}.MIPattern = MIPattern;
            else %%% overwrite
                BurstMeta.fFCS.syntheticpatterns{idx}.MIPattern = MIPattern;
            end
        end
        Update_fFCS_GUI([],[]);
    else
        %%% a different pattern was selected, do nothing
    end
end