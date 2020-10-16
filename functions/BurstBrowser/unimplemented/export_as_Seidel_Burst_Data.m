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
% convert macrotime to ms
DataArray(:,strcmp(ParameterNames,'Mean Macrotime [s]')) = DataArray(:,strcmp(ParameterNames,'Mean Macrotime [s]'))*1000;
% split and save in bur, bg4, br4, by4 files

% the parameters needed for the margarita files
bur_parameters = {'First Photon','Last Photon','Duration (ms)','Mean Macro Time (ms)',...
    'Number of Photons','Count Rate (KHz)','First File','Last File',...
    'Duration (green) (ms)','Mean Macrotime (green) (ms)','Number of Photons (green)','Green Count Rate (KHz)',...
    'Duration (red) (ms)','Mean Macrotime (red) (ms)','Number of Photons (red)','Red Count Rate (KHz)',...
    'Duration (yellow) (ms)','Mean Macrotime (yellow) (ms)','Number of Photons (yellow)','Yellow Count Rate (KHz)',...
    'S prompt red (kHz)','S delayed red (kHz)','TGX-TRR','ALEX-2CDE','FRET-2CDE'};
bg4_parameters = {'Ng-p-all','Ng-s-all','Number of Photons (fit window) (green)','Ng-p (fit window)','Ng-s (fit window)',...
    '2I*  (green)','Tau (green)','gamma (green)','r0 (green)','rho (green)','BIFL scatter? (green)','2I*: P+2S? (green)',...
    'r Scatter (green)','r Experimental (green)'};
br4_parameters = {'Nr-p-all','Nr-s-all','Number of Photons (fit window) (red)','Nr-p (fit window)','Nr-s (fit window)',...
    '2I*  (red)','Tau (red)','const (red)','r Scatter (red)','r Experimental (red)','r Cut (red)'};
by4_parameters = {'Ny-p-all','Ny-s-all','Number of Photons (fit window) (yellow)','Ny-p (fit window)','Ny-s (fit window)',...
    '2I*  (yellow)','Tau (yellow)','gamma (yellow)','r0 (yellow)','rho (yellow)','BIFL scatter? (yellow)','2I*: P+2S? (yellow)',...
    'r Scatter (yellow)','r Experimental (yellow)'};

% the respective names in BurstBrowser
% empty if parameter is not available
bur_parameters_BB = {'','','Duration [ms]','Mean Macrotime [s]',...
    'Number of Photons','Count rate [kHz]','','',...
    'Duration [ms]','Mean Macrotime [s]','Number of Photons (DD)','Count rate (DD) [kHz]',...
    'Duration [ms]','Mean Macrotime [s]','Number of Photons (DA)','Count rate (DA) [kHz]',...
    'Duration [ms]','Mean Macrotime [s]','Number of Photons (AA)','Count rate (AA) [kHz]',...
    'Count rate (DA) [kHz]','Count rate (AA) [kHz]','|TDX-TAA| Filter','ALEX 2CDE Filter','FRET 2CDE Filter'};
bg4_parameters_BB = {'Number of Photons (DD par)','Number of Photons (DD perp)','Number of Photons (DD)','Number of Photons (DD par)','Number of Photons (DD perp)',...
    '','Lifetime D [ns]','','','','','',...
    'Anisotropy D','Anisotropy D'};
br4_parameters_BB = {'Number of Photons (DA par)','Number of Photons (DA perp)','Number of Photons (DA)','Number of Photons (DA par)','Number of Photons (DA perp)',...
    '','','','','',''};
by4_parameters_BB = {'Number of Photons (AA par)','Number of Photons (AA perp)','Number of Photons (AA)','Number of Photons (AA par)','Number of Photons (AA perp)',...
    '','Lifetime A [ns]','','','','','',...
    'Anisotropy A','Anisotropy A'};

% assign the data
bur_data = zeros(size(DataArray,1),numel(bur_parameters));
for i = 1:numel(bur_parameters)
    if ~isempty(bur_parameters_BB{i})
        bur_data(:,i) = DataArray(:,strcmp(ParameterNames,bur_parameters_BB{i}));
    end
end
if isfield(BurstData{file},'BID')
    % burst IDs (start/stop photon numbers) exist
    bur_data(:,1:2) = BurstData{file}.BID;
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
if ~exist([PathName filesep 'Info'],'dir')
    mkdir([PathName filesep 'Info']);
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