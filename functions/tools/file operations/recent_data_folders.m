function [folders_list, dates] = recent_data_folders(new_folders)
% recent_data_folders returns the most recently accessed data folders
    % ----------------------------------------------------------------------------------------------
    %
    %                                   recent_data_folders
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/recent_data_folders.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % folders = recent_data_folders
    % [folders, dates] = recent_data_folders
    % ... = recent_data_folders(folder)
    % 
    % DESCRIPTION
    % -----------
    % folder = recent_data_folders returns the most recently accessed data folders. Only existing
    % folders are returned.
    % 
    % [folders, dates] = recent_data_folders also returns the date at which each data folder was
    % last accessed.
    % 
    % ... = recent_data_folders(folder) ads the folder defined in folder to the list of recently
    % accessed folders. folder can be a string or a cellstring.
    %
    % REMARKS
    % -------
    % The file 'recent_data_folders.txt', created in the folder returned by history_folder, holds
    % all recently used folders. These folders are stored using the format 'date_of_saving
    % folder_path', where the whitespace represents a tab. The file also holds a brief description
    % of the file on the first line, and a description of the columns on the second line.
    % 
    % Copyright 2017
    % ==============================================================================================
    
    
    % INITIALIZATION
    % --------------
    
    % check number of input and output arguments
    if nargin > 1 || nargout > 2
        % use chknarg to generate error
        chknarg(nargin, [0 1], nargout, [0 2], mfilename);
    end
    
    
    % EXECUTION
    % ---------
    
    % define the name of the file holding the recent folders
    filename = fullfile(history_folder, 'recent_data_folders.txt');
    
    % get folders already stored in the file
    if ~isfile(filename)
        % the file doesn't exist
        old_folders = {datestr(now) fileparts(fileparts(user_folder))};
    else
        % the file exists. Read the most recent folders
        old_folders = read_recent_folders(filename);
    end
    
    if nargin > 0
        if ischar(new_folders)
            % a single folder is defined
            if ~isdir(new_folders)
                % the new folder does not exist
                folders_list = old_folders;
            else
                % the new folder exists
                % remove duplicate folders
                tf = ismember(old_folders(:,2), new_folders);
                old_folders(tf,:) = [];
                % concatenate folders
                folders_list = [{datestr(now) new_folders}; old_folders];
            end
        else
            % multiple folders are defined
            
            % convert the cell array to a column cell array
            new_folders = new_folders(:);
            
            % remove non-existing folders
            new_folders(~cellfun(@isdir, new_folders)) = [];
            
            % remove duplicates
            new_folders = unique(new_folders, 'stable');
            
            % remove duplicate folders
            for m = 1 : length(new_folders)
                tf = ismember(old_folders(:,2), new_folders{m});
                old_folders(tf,:) = [];
            end
            
            % add current date to new_folders
            new_folders = [repmat({datestr(now)}, length(new_folders),1),  new_folders];
            
            % concatenate folders
            folders_list = [new_folders; old_folders];
            
        end
        
        % limit the maximum number of folders
        if length(folders_list) > 200
            folders_list(201:end,:) = [];
        end
        
        % write the recent folder to the file
        write_recent_folders(filename, folders_list);
        
    else
        folders_list = old_folders;
    end
    
    % prepare output
    dates = folders_list(:,1);
    folders_list = folders_list(:,2);
    
end % end of function 'recent_data_folders'



%% -------------------------------------------------------------------------------------------------
function write_recent_folders(filename, folders_list)
    % this function writes the (existing) folders to the file
    
    % set the line break character
    lb = char([13 10]);
    
    % create the header
    txt = ['This file holds all folders that were recently accessed by the user.' lb 'access date' char(9) 'folder name' lb];
    
    if isempty(folders_list)
        % no folder defined
        folders_list = {datestr(now) fileparts(fileparts(user_folder))};
        
    else
        % remove non-existing folders before writing the file
        folders_list(~cellfun(@isdir, folders_list(:,2)),:) = [];
        
        if isempty(folders_list)
            folders_list = {datestr(now) fileparts(fileparts(user_folder))};
        end
    end
    
    % convert cell array of folders to string with folders separated by char([13 10]);
    folders_list(:,3)   = {char([13 10])};
    folders_list(end,3) = {''};
    folders_list(:,4)   = {char(9)};
    folders_list        = folders_list(:, [1 4 2 3])';
    txt                 = [txt folders_list{:}];
    
    % open the file for writing
    fid = fopen(filename, 'w', 'l');
    
    % close the file properly upon any error, or just at the end
    cleanup = onCleanup(@() fclose(fid));
    
    % write folders to file
    fwrite(fid, txt, 'char');
    
    % close the file
    clear cleanup

end % end of subfunction 'write_recent_folders'


%% -------------------------------------------------------------------------------------------------
function folders = read_recent_folders(filename)
    % this function reads the folders stored in the file and returns only valid, existing folders.
    % folders is a 2-column cell array with the dates of storage in the first column, and the actual
    % folders in the second column.
    
    % open the file for reading
    fid = fopen(filename, 'r', 'l');
    
    % close the file properly upon any error, or just at the end
    cleanup = onCleanup(@() fclose(fid));
    
    % read folders from the file
    data = fread(fid, '*char')';
    
    % close the file
    clear cleanup
    
    % convert string of folders to column cell array
    folders = strsplit(data, {char([13 10]), char(9)})';
    
    % remove the first 2 lines
    folders(1:3) = [];
    
    folders = reshape(folders, 2, [])';
    
    % remove non-existing folders
    folders(~cellfun(@isdir, folders(:,2)),:) = [];
    
end % end of subfunction 'read_recent_folders'