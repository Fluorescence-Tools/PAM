%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export Microtime Pattern for fFCS analysis %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export_Microtime_Pattern(~,~)
global BurstData BurstTCSPCData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));

file = BurstMeta.SelectedFile;
Progress(0,h.Progress_Axes,h.Progress_Text,'Exporting...');
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Exporting...');
%%% find selected bursts
MI = BurstTCSPCData{file}.Microtime(BurstData{file}.Selected);
CH = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);

MI = vertcat(MI{:});
CH = vertcat(CH{:});

% read number of channels and compute microtime histograms
NChan = numel(unique(CH));
hMI = cell(NChan,1);
for i = 1:NChan %%% 6 Channels (GG1,GG2,GR1,GR2,RR1,RR2)
    hMI{i} = histc(MI(CH == i),0:(BurstData{file}.FileInfo.MI_Bins-1));
end

Progress(0.5,h.Progress_Axes,h.Progress_Text,'Exporting...');

% assign donor/fret/acceptor channels back to routing/detector
MIPattern = cell(0);
for i = 1:numel(hMI)
    MIPattern{BurstData{file}.PIE.Detector(i),BurstData{file}.PIE.Router(i)} = hMI{i};
end

% save
SpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)};
SpeciesName = strrep(SpeciesName,' ','_');
SpeciesName = strrep(strrep(SpeciesName,'/','-'),':','');
Path = BurstData{file}.PathName;
FileName = [BurstData{file}.FileName(1:end-4) '_' SpeciesName];
[File, Path] = uiputfile('*.mi', 'Save Microtime Pattern', fullfile(Path,FileName));
if all(File==0)
    return
end
save(fullfile(Path,File),'MIPattern');

Progress(1,h.Progress_Axes,h.Progress_Text);