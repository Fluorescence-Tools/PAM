%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Saves the state of the analysis to the .bur file %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Save_Analysis_State_Callback(obj,~)
global BurstData BurstTCSPCData BurstMeta
if isempty(obj)
    h = guidata(findobj('Tag','BurstBrowser'));
else
    h = guidata(obj);
end
if isempty(BurstData)
    disp('No data loaded.');
    return;
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Saving...');
%%% construct filenames
for i = 1:numel(BurstData)
    filename{i} = fullfile(BurstData{i}.PathName, BurstData{i}.FileName);
end
%%% Store burstdata in temp var
if all(strcmp(cellfun(@(x) x(end-2:end),filename,'UniformOutput',false),'bur')) % all bur file, normal 'fast' save
    for i = 1:numel(BurstData)
        Cut = BurstData{i}.Cut;
        SpeciesNames = BurstData{i}.SpeciesNames;
        SelectedSpecies = BurstData{i}.SelectedSpecies;
        Background = BurstData{i}.Background;
        Corrections = BurstData{i}.Corrections;
        %%% New: Cuts stored in Additional Variables (first happens when
        %%% saved in BurstBrowser)
        save(filename{i},'Cut','SpeciesNames','SelectedSpecies',...
            'Background','Corrections','-append');
        if isfield(BurstData{i},'FitCut')
            FitCut = BurstData{i}.FitCut;
            save(filename{i},'FitCut','-append');
        end
        if isfield(BurstData{i},'ArbitraryCut')
            ArbitraryCut = BurstData{i}.ArbitraryCut;
            save(filename{i},'ArbitraryCut','-append');
        end
        if isfield(BurstData{i},'AdditionalParameters')
            AdditionalParameters = BurstData{i}.AdditionalParameters;
            save(filename{i},'AdditionalParameters','-append');
        end
        Progress(i/numel(BurstData),h.Progress_Axes,h.Progress_Text,'Saving...');
    end
elseif any(strcmp(cellfun(@(x) x(end-2:end),filename,'UniformOutput',false),'kba')) % kba files loaded, convert to bur
    BurstData_temp = BurstData;
    BurstTCSPCData_temp = BurstTCSPCData;
    for i = 1:numel(BurstData_temp)
        BurstData = BurstData_temp{i};
        Cut = BurstData.Cut;
        SpeciesNames = BurstData.SpeciesNames;
        SelectedSpecies = BurstData.SelectedSpecies;
        Background = BurstData.Background;
        Corrections = BurstData.Corrections;
        save([filename{i}(1:end-4) '_kba.bur'],'BurstData',...
            'Cut','SpeciesNames','SelectedSpecies','Background','Corrections');
        if ~isempty(BurstTCSPCData_temp{i})
            %%% also save BurstTCSPCData
            BurstTCSPCData = BurstTCSPCData_temp{i};
            save([filename{i}(1:end-4) '_kba.bps'],'-struct','BurstTCSPCData');
        end
        Progress(i/numel(BurstData),h.Progress_Axes,h.Progress_Text,'Saving...');
    end
    BurstData = BurstData_temp;
    BurstTCSPCData= BurstTCSPCData_temp;
end
Progress(1,h.Progress_Axes,h.Progress_Text);