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

%%% save as *.bst file in subfolder named by species
SelectedSpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)};
SelectedSpeciesName = strrep(strrep(strrep(SelectedSpeciesName,'/','-'),':',''),' ','_');
SelectedSpeciesName = ['BID_' SelectedSpeciesName];
FileName = BurstData{file}.FileInfo.FileName{1};
% add "_0" to filename before file extension
[~,FileName,ext] = fileparts(FileName);
FileName = [FileName '_0' ext];
PathName = fullfile(BurstData{file}.PathName,SelectedSpeciesName);
if ~(exist(PathName,'file') == 7)
    mkdir(PathName);
end
filename = fullfile(PathName,FileName);
filename = [filename  '.bst'];
dlmwrite(filename,bid,'delimiter','\t','precision','%i');

%%% TODO: Add the cut information and correction factors





