function export_as_Seidel_Burst_Data(obj,~)
global UserValues BurstData BurstMeta
if isempty(obj)
    h = guidata(findobj('Tag','BurstBrowser'));
else
    h = guidata(obj);
end
file = BurstMeta.SelectedFile;
PathName = uigetdir(UserValues.File.BurstBrowserPath,'Select folder');

% 'bg4','bi4_bur','br4','info'
Progress(0,h.Progress_Axes,h.Progress_Text,'Exporting data...');

% get the data
ParameterNames = BurstData{file}.NameArray;
DataArray = BurstData{file}.DataArray;

% split and save in bur, bg4, br4, by4 files

% the parameters needed for the margarita files
bur_parameters = {'First Photon','Last photon','Number of Photons','Duration [ms)',...
    'Number of Photons (green)','Number of Photons (red)','Number of Photons (yellow)'};
bg4_parameters = {'First Photon (green)','Last Photon (green)','Mean Photon (green)',...
    'Middle Photon (green)','Photons in Burst (green)','Photon Mean Time (green) [ms]','Middle Photon Time (green) [ms]',...
    'Duration of Burst (green) [ms]','2I* (green)','Intensity of Burst (green) [KHz]','Tau  (green) [ns]','Gamma (green)',...
    'r0 (green)','Phi (green)','Alpha (green)','r Scatter (green)','r Experimental (green)','r Cut (green)',...
    'Start Time (green) [ms]','End Time (green) [ms]'};
br4_parameters = {'First Photon (red)','Last Photon (red)','Mean Photon (red)',...
    'Middle Photon (red)','Photons in Burst (red)','Photon Mean Time (red) [ms]',...
    'Middle Photon Time (red) [ms]','Duration of Burst (red) [ms]','2I* (red)',...
    'Intensity of Burst (red) [KHz]','Tau  (red) [ns]','Number (red)','r Experimental (red)',...
    'r Experimental (red)','r Cut (red)','Start Time (red) [ms]','End Time (red) [ms]'};
by4_parameters = {'First Photon (yellow)','Last Photon (yellow)','Mean Photon (yellow)','Middle Photon (yellow)',...
    'Photons in Burst (yellow)','Photon Mean Time (yellow) [ms]','Middle Photon Time (yellow) [ms]','Duration of Burst (yellow) [ms]',...
    '2I* (yellow)','Intensity of Burst (yellow) [KHz]','Tau  (yellow) [ns]','Number (yellow)','r Experimental (yellow)',...
    'r Experimental (yellow)','r Cut (yellow)','Start Time (yellow) [ms]','End Time (yellow) [ms]'};

% the respective names in BurstBrowser
% empty if parameter is not available
bur_parameters_BB = {'','','Number of Photons','Duration [ms]',...
    'Number of Photons (DD)','Number of Photons (DA)','Number of Photons (AA)'};
bg4_parameters_BB = {'','','',...
    '','Number of Photons (DD)','Mean Macrotime [s]','',...
    'Duration [ms]','','Count rate (DD) [kHz]','Lifetime D [ns]','',...
    '','','','Anisotropy D','Anisotropy D','',...
    '',''};
br4_parameters_BB = {'','','',...
    '','Number of Photons (DA)','Mean Macrotime [s]','',...
    'Duration [ms]','','Count rate (DA) [kHz]','','','',...
    '','','',''};
by4_parameters_BB = {'','','',...
    '','Number of Photons (AA)','Mean Macrotime [s]','',...
    'Duration [ms]','','Count rate (AA) [kHz]','Lifetime A [ns]',...
    '','Anisotropy A','Anisotropy A','','',''};

% assign the data
bur_data = zeros(size(DataArray,1),numel(bur_parameters));
for i = 1:numel(bur_parameters)
    if ~isempty(bur_parameters_BB{i})
        bur_data(:,i) = DataArray(:,strcmp(ParameterNames,bur_parameters_BB{i}));
    end
end
bg4_data = zeros(size(DataArray,1),numel(bg4_parameters));
for i = 1:numel(bg4_parameters)
    if ~isempty(bg4_parameters_BB{i})
        bg4_data(:,i) = DataArray(:,strcmp(ParameterNames,bg4_parameters_BB{i}));
    end
end
br4_data = zeros(size(DataArray,1),numel(br4_parameters));
for i = 1:numel(br4_parameters)
    if ~isempty(br4_parameters_BB{i})
        br4_data(:,i) = DataArray(:,strcmp(ParameterNames,br4_parameters_BB{i}));
    end
end
by4_data = zeros(size(DataArray,1),numel(by4_parameters));
for i = 1:numel(by4_parameters)
    if ~isempty(by4_parameters_BB{i})
        by4_data(:,i) = DataArray(:,strcmp(ParameterNames,by4_parameters_BB{i}));
    end
end

%% save as corresponding files in folder structure
Progress(0,h.Progress_Axes,h.Progress_Text,'Saving data...');

% bur file
if ~exist([PathName filesep 'bi4_bur'],'dir')
    mkdir([PathName filesep 'bi4_bur']);
end
fn = [PathName filesep 'bi4_bur' filesep BurstData{file}.FileNameSPC];
fn = [fn '.bur'];
fid = fopen(fn,'w');
fprintf(fid,[repmat('%s\t',1,numel(bur_parameters)-1) '%s\n'],bur_parameters{:});
fclose(fid);
dlmwrite(fn,bur_data,'-append','delimiter','\t','precision','%.10f');

Progress(0.25,h.Progress_Axes,h.Progress_Text,'Saving data...');

% bg4 file
if ~exist([PathName filesep 'bg4'],'dir')
    mkdir([PathName filesep 'bg4']);
end
fn = [PathName filesep 'bg4' filesep BurstData{file}.FileNameSPC];
fn= [fn '.bg4'];
fid = fopen(fn,'w');
fprintf(fid,[repmat('%s\t',1,numel(bg4_parameters)-1) '%s\n'],bg4_parameters{:});
fclose(fid);
dlmwrite(fn,bg4_data,'-append','delimiter','\t','precision','%.10f');

Progress(0.5,h.Progress_Axes,h.Progress_Text,'Saving data...');

% br4 file
if ~exist([PathName filesep 'br4'],'dir')
    mkdir([PathName filesep 'br4']);
end
fn = [PathName filesep 'br4' filesep BurstData{file}.FileNameSPC];
fn= [fn '.br4'];
fid = fopen(fn,'w');
fprintf(fid,[repmat('%s\t',1,numel(br4_parameters)-1) '%s\n'],br4_parameters{:});
fclose(fid);
dlmwrite(fn,br4_data,'-append','delimiter','\t','precision','%.10f');

Progress(0.75,h.Progress_Axes,h.Progress_Text,'Saving data...');

% by4 file
if ~exist([PathName filesep 'by4'],'dir')
    mkdir([PathName filesep 'by4']);
end
fn = [PathName filesep 'by4' filesep BurstData{file}.FileNameSPC];
fn= [fn '.by4'];
fid = fopen(fn,'w');
fprintf(fid,[repmat('%s\t',1,numel(by4_parameters)-1) '%s\n'],by4_parameters{:});
fclose(fid);
dlmwrite(fn,by4_data,'-append','delimiter','\t','precision','%.10f');

Progress(1,h.Progress_Axes,h.Progress_Text,'Saving data...');

% save the required mti file
% this file contains the path to the data file and the measurement duration
if ~exist([PathName filesep 'info'],'dir')
    mkdir([PathName filesep 'info']);
end
fn = [PathName filesep 'info' filesep BurstData{file}.FileNameSPC];
fn= [fn '.mti'];
fid = fopen(fn,'w');
for i = 1:numel(BurstData{file}.FileInfo.FileName)
    fprintf(fid,'%s\t%.6f\n',fullfile(BurstData{file}.FileInfo.Path,BurstData{file}.FileInfo.FileName{i}),...
        BurstData{file}.FileInfo.MeasurementTime);
end
fclose(fid);

Progress(1,h.Progress_Axes,h.Progress_Text,'Done');