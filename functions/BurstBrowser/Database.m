function Database(obj,e,mode)
global UserValues BurstMeta BurstData
h = guidata(obj);

if mode == 0 %%% Checks, which key was pressed
    switch e.EventName
        case 'KeyPress'
            switch e.Key
                case 'delete'
                    mode = 2;
                case 'return'
                    %mode = 5;
            end
        case 'Action' %%% mouse-click
            switch get(gcbf,'SelectionType')
                case 'open' %%% double click
                    mode = 5;
            end
    end
end

switch mode
    case 1 %% Add files to database
        switch obj
            case h.DatabaseBB.AddFiles %% Open dialog to add files to database
                if isempty(BurstMeta.Database) %%% no data base loaded
                    if isempty(BurstData)
                        Path = UserValues.File.BurstBrowserPath;
                    else
                        Path = BurstData{BurstMeta.SelectedFile}.PathName;
                    end
                else
                    Path = BurstMeta.Database{h.DatabaseBB.List.Value,2};
                end
                Files = GetMultipleFiles({'*.bur','*.bur files'},'Choose files to add to DataBase',Path);
                if isempty(Files)
                    return;
                end
            case h.DatabaseBB.AppendLoadedFiles %% Add loaded files to database
                for i = 1:numel(BurstData) %%% loop over loaded files
                    Files{i,1} = BurstData{i}.FileName;
                    Files{i,2} = BurstData{i}.PathName;
                end
            case h.DatabaseBB.DatabaseFromFolder %% get files from all subfolders
                %%% Choose a folder and load files from all subfolders
                %%% only consider one level downwards
                FileName = cell(0);
                PathName = cell(0);
                path= fullfile(UserValues.File.BurstBrowserPath,'..',filesep);
                pathname = uigetdir(path,'Choose a folder. All *.bur files from direct subfolders will be added to the database');
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
                    files = files(3:end);
                    if ~isempty(files) %%% ensure that there are files in this subfolder
                        for j = 1:numel(files)
                            if ~files(j).isdir %%% is a file
                                %%% check for bur extension
                                [~,~,ext] = fileparts(files(j).name);
                                if strcmp(ext,'.bur') %%% check for bur extension
                                    FileName{end+1} = files(j).name;
                                    PathName{end+1} = [pathname filesep subdir(i).name];
                                end
                            else %%% is a folder, go one layer deeper
                                subfolder = [pathname filesep subdir(i).name filesep files(j).name];
                                files_subfolder = dir(subfolder);
                                files_subfolder = files_subfolder(3:end);
                                if ~isempty(files_subfolder)
                                    for k = 1:numel(files_subfolder)
                                        %%% check for bur extension
                                        [~,~,ext] = fileparts(files_subfolder(k).name);
                                        if strcmp(ext,'.bur') 
                                            FileName{end+1} = files_subfolder(k).name;
                                            PathName{end+1} = subfolder;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if isempty(FileName)
                    %%% no files have been found
                    return;
                end
                Files(:,1) = FileName;
                Files(:,2) = PathName;
                %%% remove existing database
                BurstMeta.Database = {};
                h.DatabaseBB.List.String = {};
                %%% set path
                UserValues.File.BurstBrowserPath = pathname;
        end  
        %%%check for existing files and append new files to database list
        new = true(size(Files,1),1);
        if ~isempty(BurstMeta.Database) % ensure database exists
            for i = 1:size(Files,1)
                exist_name = find(strcmp(Files{i,1},BurstMeta.Database(:,1)));
                if ~isempty(exist_name)
                    if any(strcmp(Files{i,2},BurstMeta.Database(exist_name,2)))
                        new(i) = false;
                    end
                end
            end
        end
        Files = Files(new,:);
        %% Add files to database
        % add new files to database
        for i = 1:size(Files,1)
            BurstMeta.Database{end+1,1} = Files{i,1};
            BurstMeta.Database{end,2} = Files{i,2};
            h.DatabaseBB.List.String{end+1} = [Files{i,1} ' (path:' Files{i,2} ')'];
        end
        if size(BurstMeta.Database, 1) > 0
            % reenable save
            h.DatabaseBB.Save.Enable = 'on';
        end
    case 2 %% Delete files from database
        %remove rows from list
        h.DatabaseBB.List.String(h.DatabaseBB.List.Value) = [];
        %remove rows from database
        BurstMeta.Database(h.DatabaseBB.List.Value, :) = [];
        h.DatabaseBB.List.Value = 1;
        if size(BurstMeta.Database, 1) < 1
            % no files are left
            h.DatabaseBB.Save.Enable = 'off';
        end
    case 3 %% Load database
        Path = UserValues.File.BurstBrowserDatabasePath;
        [FileName, Path] = uigetfile({'*.bdb', 'Burst Database file (*.bdb)';'*.dab','PAM Database file (*.dab)'}, 'Choose database to load',Path,'MultiSelect', 'on');
        if ~iscell(FileName)
            if  FileName == 0
                return;
            end
        end
        if ~iscell(FileName)
            FileName = {FileName};
        end
        %%% store path in BurstMeta
        UserValues.File.BurstBrowserDatabasePath = Path;
        DB = [];
        list_of_files = [];
        for i = 1:numel(FileName)
            db = load('-mat',fullfile(Path,FileName{i})); db = db.s;
            %%% do check of database
            % check for non *.bur files
            % check for non-existing files/invalid paths
            valid = true(size(db.database,1),1);
            for i = 1:size(db.database,1)
                if ~strcmp(db.database{i,1}(end-3:end),'.bur') || ~(exist([db.database{i,2} filesep db.database{i,1}],'file')==2)
                    valid(i) = false;
                end
            end
            if sum(valid) == 0
                disp('Database file does not contain *.bur files or files are not accessible.');
                return;
            end
            % remove invalid
            db.str = db.str(valid); db.database=db.database(valid,:);
            DB = [DB; db.database];
            list_of_files  = [list_of_files; db.str];
            clear db;
        end
        BurstMeta.Database = DB;
        h.DatabaseBB.List.String = list_of_files;
        h.DatabaseBB.List.Value = 1;
        if size(BurstMeta.Database, 1) > 0
            % reenable save
            h.DatabaseBB.Save.Enable = 'on';
        end
        LSUserValues(1);
    case 4 %% Save complete database
        Path = UserValues.File.BurstBrowserDatabasePath;
        [File, Path] = uiputfile({'*.bdb', 'Database file (*.bdb)'}, 'Save database', Path);
        if File == 0
            return;
        end
        s = struct;
        s.database = BurstMeta.Database;
        s.str = h.DatabaseBB.List.String;
        save(fullfile(Path,File),'s');
        %%% store path in UserValues
        UserValues.File.BurstBrowserDatabasePath = Path;
        LSUserValues(1);
    case 5 %% Loads selected files into BurstBrowser
        h.Progress.Text.String='Loading new files';
        Load_Burst_Data_Callback(obj,[]);
end
if mode ~= 5
    %%% Update UserValues
    UserValues.BurstBrowser.DatabaseString = h.DatabaseBB.List.String;
    UserValues.BurstBrowser.Database = BurstMeta.Database;
end