%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Load *.bur file  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Burst_Data_Callback(obj,~,filenames)
global BurstData UserValues BurstMeta PhotonStream BurstTCSPCData

if ~isempty(obj)
    h = guidata(obj);
else
    h = guidata(findobj('Tag','BurstBrowser'));
    obj = 'FileHistory';
end
% clear text from general axis
c = h.axes_general.Children;
del = false(size(c));
for i = 1:numel(c)
    if strcmp(c(i).Type,'text');
        del(i) = true;
    end
end
delete(c(del));

if obj ~= h.Append_File
    if ~isempty(BurstData) && UserValues.BurstBrowser.Settings.SaveOnClose
        %%% Ask for saving
        choice = questdlg('Save Changes?','Save before closing','Yes','Discard','Cancel','Discard');
        switch choice
            case 'Yes'
                Save_Analysis_State_Callback([],[]);
            case 'Cancel'
                return;
        end
    end
end
    
if obj ~= h.DatabaseBB.List
    LSUserValues(0);
    %%% check if there are subfolders
    subdir = dir(UserValues.File.BurstBrowserPath);
    subdir = subdir([subdir.isdir]);
    subdir = subdir(3:end); %%% remove '.' and '..' folders
    if isempty(subdir) %%% no subfolders, move one folder up
        path = fullfile(UserValues.File.BurstBrowserPath,'..',filesep);
    else 
        path = UserValues.File.BurstBrowserPath;
    end
    switch obj
        case {h.Load_Bursts, h.Append_File}
            switch obj
                case h.Load_Bursts %%% load once from one folder
                    [FileName,pathname,FilterIndex] = uigetfile({'*.bur','*.bur file';'*.kba','*.kba file from old PAM'}, 'Choose a file', path, 'MultiSelect', 'on');
                    if FilterIndex == 0
                        return;
                    end
                    if ischar(FileName)
                        FileName = {FileName};
                    end
                    %%% make pathname to cell array
                    for i = 1:numel(FileName)
                        PathName{i} = pathname;
                    end
                case h.Append_File
                    %%% query multiple files (only allow  *.bur files)
                    [FileName,pathname,FilterIndex] = uigetfile({'*.bur','*.bur file'}, 'Choose a file', path, 'MultiSelect', 'on');
                    if ischar(FileName)
                        FileName = {FileName};
                    end
                    %%% make pathname to cell array
                    for i = 1:numel(FileName)
                        PathName{i} = pathname;
                    end
                    while FilterIndex ~= 0 %%% query for more files until cancel is selected
                        [fn,pn,FilterIndex] = uigetfile({'*.bur','*.bur file'}, 'Choose a file', path, 'MultiSelect', 'on');
                        if FilterIndex ~= 0
                            if ischar(fn)
                                fn = {fn};
                            end
                            FileName = [FileName;fn];
                            for i = 1:numel(fn)
                                PathName{end+1} = pn;
                            end
                        end
                    end
            end
            
        case h.Load_Bursts_From_Folder
            %%% Choose a folder and load files from all subfolders
            %%% only consider one level downwards
            FileName = cell(0);
            PathName = cell(0);
            pathname = uigetdir(path,'Choose a folder. All *.bur files from direct subfolders will be loaded.');
            if pathname == 0
                return;
            end
            subdir = dir(pathname);
            subdir = subdir([subdir.isdir]);
            subdir = subdir(3:end); %%% remove '.' and '..' folders
            if isempty(subdir) %%% no subfolders
                return;
            end
            for i = 1:numel(subdir)
                files = dir([pathname filesep subdir(i).name]);
                if ~isempty(files) %%% ensure that there are files in this subfolder
                    for j = 1:numel(files)
                        if ~( strcmp(files(j).name,'.') || strcmp(files(j).name,'..') )
                            if strcmp(files(j).name(end-3:end),'.bur') %%% check for bur extension
                                FileName{end+1} = files(j).name;
                                PathName{end+1} = [pathname filesep subdir(i).name];
                            end
                        end
                    end
                end
            end
            if isempty(FileName)
                %%% no files have been found
                return;
            end
            FilterIndex = 1; %%% Only bur files supported
        case 'FileHistory'
            pathname = fileparts(filenames{1});
        otherwise
            pathname = UserValues.File.BurstBrowserPath;
    end
elseif obj == h.DatabaseBB.List
    %%% get Filelist from Database
    PathName = BurstMeta.Database(h.DatabaseBB.List.Value,2);
    FileName = BurstMeta.Database(h.DatabaseBB.List.Value,1);
    FilterIndex = 1;
    pathname = PathName{1};
else
    pathname = UserValues.File.BurstBrowserPath;
end

UserValues.File.BurstBrowserPath=pathname;
LSUserValues(1);

%%% Reset FCS buttons (no *.aps loaded anymore!)
%h.CorrelateWindow_Button.Enable = 'off';
%h.CorrelateWindow_Edit.Enable = 'off';
%%% Load data
switch obj
    case {h.Load_Bursts,h.DatabaseBB.List,h.Load_Bursts_From_Folder}
        Load_BurstFile(PathName,FileName,FilterIndex);
        %%% Enable append file
        h.Append_File.Enable = 'on';
    case h.Append_File
        Load_BurstFile(PathName,FileName,FilterIndex,1)
    otherwise %%% loaded from recent file list
        if nargin > 2
            for i = 1:numel(filenames)
                [PathName{i},FileName{i},ext] = fileparts(filenames{i});
                FileName{i} = [FileName{i},ext];
            end
            Load_BurstFile(PathName,FileName,1);
        end
        %%% Enable append file
        h.Append_File.Enable = 'on';
end
if isempty(BurstData)
    Progress(1,h.Progress_Axes,h.Progress_Text);
    return;
end

BurstMeta.SelectedFile = 1;
%%% Update Figure Name
BurstMeta.DisplayName = BurstData{1}.FileName;

%%%update file history with new files
%%% add files to file history
for i = 1:numel(FileName)
    file = fullfile(PathName{i},FileName{i});
    if strcmp(file(end-3:end),'.bur')
        h.DatabaseBB.FileHistory.add_file(file);
    end
end

% set default to efficiency and stoichiometry
if any(BurstData{1}.BAMethod == [1,2,5]) %%% Two-Color MFD
    %find positions of FRET Efficiency and Stoichiometry in NameArray
    posE = find(strcmp(BurstData{1}.NameArray,'FRET Efficiency'));
    %%% Compatibility check for old BurstExplorer Data
    if sum(strcmp(BurstData{1}.NameArray,'Stoichiometry')) == 0
        BurstData{1}.NameArray{strcmp(BurstData{1}.NameArray,'Stochiometry')} = 'Stoichiometry';
    end
    posS = find(strcmp(BurstData{1}.NameArray,'Stoichiometry'));
elseif any(BurstData{1}.BAMethod == [3,4]) %%% Three-Color MFD
    posE = find(strcmp(BurstData{1}.NameArray,'FRET Efficiency GR'));
    posS = find(strcmp(BurstData{1}.NameArray,'Stoichiometry GR'));
end

if BurstData{1}.APBS == 1
    %%% Enable the donor only lifetime checkbox
    h.DonorLifetimeFromDataCheckbox.Enable = 'on';
end

%%% Enable DataBase Append Loaded Files
h.DatabaseBB.AppendLoadedFiles.Enable = 'on';
%%% Reset Plots
Initialize_Plots(2);

%%% Switches GUI to 3cMFD or 2cMFD format
if BurstData{1}.BAMethod ~= 5
    SwitchGUI(BurstData{1}.BAMethod,1); %%% force update
else
    SwitchGUI(BurstData{1}.BAMethod,1); %%% force update
end
%%% Initialize Parameters and Corrections for every loaded file
for i = 1:numel(BurstData)
    BurstMeta.SelectedFile = i;
    %%% Initialize Correction Structure
    UpdateCorrections([],[],h);
    %%% Add Derived Parameters
    AddDerivedParameters([],[],h);
    %%% ensure that Cut data is available
    UpdateCuts();
    %%% Update BVA tab
    UpdateBVATab([],[],h);
end
BurstMeta.SelectedFile = 1;

%%% reset lifetime ind selection to normal
if numel(h.lifetime_ind_popupmenu.String) > 4
    h.lifetime_ind_popupmenu.String = h.lifetime_ind_popupmenu.String(1:4);
    h.lifetime_ind_popupmenu.Value = 1;
end
%%% check if phasor data is present
if any(strcmp(BurstData{1}.NameArray,'Phasor: gD'))
    h.lifetime_ind_popupmenu.String{end+1} = '<html>g<sub>D</sub> vs s<sub>D</sub></html>';
end
if any(strcmp(BurstData{1}.NameArray,'Phasor: gA'))
    h.lifetime_ind_popupmenu.String{end+1} = '<html>g<sub>A</sub> vs s<sub>A</sub></html>';
end
    
%%% Set Parameter list after all parameters are defined
set(h.ParameterListX, 'String', BurstData{1}.NameArray);
set(h.ParameterListX, 'Value', posE);

set(h.ParameterListY, 'String', BurstData{1}.NameArray);
set(h.ParameterListY, 'Value', posS);

if isfield(BurstMeta,'fFCS')
    BurstMeta = rmfield(BurstMeta,'fFCS');
end
if isfield(BurstMeta,'Data')
    BurstMeta = rmfield(BurstMeta,'Data');
end

%%% Update Species List
UpdateSpeciesList(h);
h = guidata(h.BurstBrowser);drawnow;

%%% Apply correction on load
if UserValues.BurstBrowser.Settings.CorrectionOnLoad == 1
    for i = 1:numel(BurstData)
        BurstMeta.SelectedFile = i;
        ApplyCorrections([],[],h,0);
    end
else %%% indicate that no corrections are applied
    h.ApplyCorrectionsButton.ForegroundColor = [1 0 0];
end
BurstMeta.SelectedFile = 1; % select first file again

UpdateCutTable(h);
UpdateCuts();

ChangePlotType(h.PlotContourLines) 
ChangePlotType(h.PlotTypePopumenu) 
Update_fFCS_GUI(gcbo,[]);
UpdateGUIOptions(h.LifetimeMode_Menu,[],h);

function Files = GetMultipleFiles(FilterSpec,Title,PathName)
FileName = 1;
count = 0;
PathName= fullfile(PathName,'..',filesep);%%% go one layer above since .*bur files are nested
Files = [];
while FileName ~= 0
    [FileName,PathName] = uigetfile(FilterSpec,Title, PathName, 'MultiSelect', 'on');
    if ~iscell(FileName)
        if FileName ~= 0
            count = count+1;
            Files{count,1} = FileName;
            Files{count,2} = PathName;
        end
    elseif iscell(FileName)
        for i = 1:numel(FileName)
            if FileName{i} ~= 0
                count = count+1;
                Files{count,1} = FileName{i};
                Files{count,2} = PathName;
            end
        end
        FileName = FileName{end};
    end
    PathName= fullfile(PathName,'..',filesep);%%% go one layer above since .*bur files are nested
end