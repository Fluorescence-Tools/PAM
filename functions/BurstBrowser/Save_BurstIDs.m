function Save_BurstIDs(obj,~)
%%% saves the "burst IDs" 
%%% Burst IDs are the global photon numbers of the start and stop of
%%% selected bursts, i.e. of all photons recorded in the measurement
global BurstMeta BurstData
h = guidata(obj);

if h.MultiselectOnCheckbox.UserData & numel(get_multiselection(h)) > 1
    disp('Please select only one file.');
    return;
end
file = BurstMeta.SelectedFile;
if ~isfield(BurstData{file},'BID')
    disp('No BurstIDs found, please reanalyze the file.');
    return;
end

%%% read out the burst IDs of the selected files
bid = BurstData{file}.BID(BurstData{file}.Selected,:);

%%% save as *.bst file
SelectedSpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)};
SelectedSpeciesName = strrep(strrep(SelectedSpeciesName,'/','-'),':','');
[~,FileName,~] = fileparts(BurstData{file}.FileName);
filename = fullfile(BurstData{file}.PathName,FileName);
filename = GenerateName([filename(1:end-4) '_' SelectedSpeciesName '.bst'], 1);
dlmwrite(filename,bid,'delimiter','\t','precision','%i');





