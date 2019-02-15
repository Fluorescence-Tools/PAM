function folderlist = find_folders(varargin)
% find_folders returns all first-level subfolders in the defined folder
    % ----------------------------------------------------------------------------------------------
    %
    %                                       find_folders
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/find_folders.m $
    % Original author: Nick Smisdom, Hasselt University / VITO
    % 
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % folderlist = find_folders(Directory)
    % folderlist = find_folders
    % folderlist = find_folders(..., 'fullpath', 'on')
    % folderlist = find_folders(..., '-recursive')
    % 
    % DESCRIPTION
    % -----------
    % folderlist = find_folders(Directory) returns all subfolders in the folder 'Directory'.
    %
    % folderlist = find_folders returns all subfolders in the folder that the user selects. 
    % 
    % folderlist = find_folders(..., 'fullpath', 'on') returns the absolute path to the folders.
    % 
    % folderlist = find_folders(..., '-recursive') recursively returns all subfolders. This options
    % is only active when fullpath is 'on'.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % set default values
    fullpath = false;
    folder   = [];
    
    % check number of input and output arguments
    if nargin > 4 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [0 4], nargout, 1, mfilename);
    end
    
    if any(strcmpi(varargin, '-recursive'))
        % set the value to indicate the recursive action
        recursive = true;
        % remove this options from the list of input arguments
        varargin(strcmpi(varargin, '-recursive')) = [];
    else
        recursive = false;
    end
    
    L = length(varargin);
    c = 0;
    while c < L
        c = c + 1;
        if ischar(varargin{c}) && isdir(varargin{c})
            folder = varargin{c};
            
        elseif strcmpi(varargin{c}, 'fullpath')
            if ~istforonoff(varargin{c+1})
                errorbox('The option ''fullpath'' has to be ''on'' or ''off''.', 'Bad fullpath option', [mfilename ':BadFullPathOptn']);
            else
                fullpath = tforonoff2tf(varargin{c+1});
                c = c + 1;
            end
        
        elseif istforonoff(varargin{c})
            fullpath = tforonoff2tf(varargin{c});
            
        else
            errorbox(['Input argument n°' num2str(c) ' is neither a folder nor a valid option.'], 'Bad input argument', [mfilename ':BadIpt']);
        end
        
    end
    
    if isempty(folder)
        % the folder is not defined
        % let the user select a folder
        folder = uigetdir('', 'Select the folder of which the first-level subfolders should be found');
        
        if folder == 0
            % The user has decided to stop the function (clicked on 'cancel')
            folderlist = [];
            return
            
        elseif ~isdir(folder)
            % the parent is not a folder
            folderlist = [];
            return
        end
        
    end
    
    
    % EXECUTION
    % ---------
    
    folderlist = getsubfolders(folder, recursive, fullpath);
    
    if fullpath
        folderlist = sort(folderlist);
    end
    
end % end of function 'find_folders'


%% -------------------------------------------------------------------------------------------------
function list = getsubfolders(folder, recursive, fullpath)
    % getsubfolders returns the first level subfolders as a column cell array
    
    % get the complete content of the defined folder
    temp_folders = dir(folder);
    
    % remove the entries '..' and '.'
    temp_folders(strcmpi({temp_folders(:).name}, '.') | strcmpi({temp_folders(:).name}, '..')) = [];
    
    % keep only the directories
    temp_folders = temp_folders([temp_folders(:).isdir]);
    
    if isempty(temp_folders)
        list = {};
        return
    end
    
    % get the folder names
    temp_folders = {temp_folders(:).name};
    
    if fullpath
        % construct the full paths of the folders
        list = cell(length(temp_folders),1);
        for m = 1 : length(temp_folders)
            list{m,1} = fullfile(folder, temp_folders{m});
        end
    else
        list = temp_folders';
    end
    
    if recursive && fullpath
        list2 = cell(length(list),1);
        for m = 1 : length(list)
            list2{m} = getsubfolders(list{m}, recursive, fullpath);
        end
        list = cat(1, list{:}, list2{:});
    end

end % end of subfunction 'getsubfolders'