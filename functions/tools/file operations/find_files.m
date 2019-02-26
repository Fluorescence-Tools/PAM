function flist = find_files(varargin)
% find_files returns all files of the specified folder
    % ----------------------------------------------------------------------------------------------
    %
    %                                        find_files
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/find_files.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % flist = find_files
    % flist = find_files(folder)
    % flist = find_files(..., 'extension', ext)
    % flist = find_files(..., '-recursive')
    % flist = find_files(..., 'fullpath', 'on'/'off')
    %
    % DESCRIPTION
    % -----------
    % flist = find_files lets the user interactively select a folder and returns all files in that
    % folder, ignoring all subfolders.
    % 
    % flist = find_files(folder) returns all files in folder. folder can be a single folder or a
    % cell array of folders. subfolders are ignored by default.
    %
    % flist = find_files(..., 'extension', ext) lets the user specify the extension of the files.
    % Examples are '*.m', '*.doc'. By default, all files are returned.
    % 
    % flist = find_files(..., '-recursive') also returns files in subfolders.
    % 
    % flist = find_files(..., 'fullpath', 'on'/'off') returns the full path to the files when set to
    % 'on'. By default, only the file names are returned ('off').
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2018
    % ==============================================================================================
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin > 7 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [0 7], nargout, 1, mfilename);
    else
        % parse input arguments
        opts = parse_ipt(varargin{:});
    end
    
    if isempty(opts.folder)
        % no folder given
        
        % let the user select a folder
        folder = uigetdir;
        
        if folder == 0
            % the user selected cancel
            flist = [];
            return
        end
        
    else
        % the function is supplied with a folder
        folder = opts.folder;
    end
        
    
    % EXECUTION
    % ---------
    
    if opts.recursive
        % also the subfolders have to be searched
        if iscell(folder)
            % several folders are specified
            
            % create empty list of folders
            Children = cell(0);
            
            % get Children of each folder
            for m = 1 : length(folder)
                temp = fsubfolder(folder{m});
                
                % add to folders list
                Children(end+1:end+length(temp),1) = temp;
            end
            
            Children = unique(Children);
                        
            % create empty list
            flist = cell(0);

            for m = 1 : length(Children)

                % get files in folder
                temp = GetFiles(Children{m}, opts);

                % save files to list
                flist(end+1:end+length(temp),1) = temp;
            end
            
        else
            % only one folder is specified
            
            % get all subfolders
            Children = find_folders(folder, 'fullpath', 'on', '-recursive');
                        
            % get all files from the folder
            flist = GetFiles(folder, opts);

            for m = 1 : length(Children)

                % get files in folder
                temp = GetFiles(Children{m}, opts);

                % save files to list
                flist(end+1:end+length(temp),1) = temp;
            end
            
        end
        
    else
        % the subfolders have to be ignored
        
        % get all files from the folder
        flist = GetFiles(folder, opts);
        
    end
    
    % remove duplicates
    flist = unique(flist, 'stable');
    
end % end of function 'find_files'


%% -------------------------------------------------------------------------------------------------
function Fout = GetFiles(Folder, opts)
    % this function uses dir to return only files from a directory
    
    if isempty(opts.extension)
        % no extension is given. Get all files
        Fout = dir(Folder);
        
    else
        % a custom (list of) extension(s) is given
        
        if iscell(opts.extension)
            % a custom list of extensions is given
            
            % create an empty structure
            Fout = struct;
            
            for m = 1 : length(opts.extension)
                % get of each extension the corresponding files
                temp = dir(fullfile(Folder, opts.extension{m}));
                
                if numel(fieldnames(Fout)) == 0
                    Fout = temp;
                else
                    Fout(length(Fout)+1:length(Fout)+length(temp)) = temp;
                end
            end
            
        else
            % only one extension is given
            Fout = dir(fullfile(Folder, opts.extension));
            
        end
    end
    
    % remove all folders
   	Fout([Fout(:).isdir]) = [];
        
    % get all names
    Fout = sort({Fout(:).name})';
    
    if opts.fullpath
        % the full path to each file has to be returned
        for m = 1 : length(Fout)
            Fout{m} = fullfile(Folder, Fout{m});
        end
    end
    
end % end of subfunction 'GetFiles'


%% -------------------------------------------------------------------------------------------------
function opts = parse_ipt(varargin)
    % parse_ipt parses the input arguments of the main function 'find_files'. Explanation of input
    % arguments can be found in the description of the main function
    
    % set default values
    opts.folder    = '';
    opts.extension = '';
    opts.recursive = false;
    opts.fullpath  = false;
    
    if any(strcmpi(varargin, '-recursive'))
        % set the value to indicate the recursive action
        opts.recursive = true;
        % remove this options from the list of input arguments
        varargin(strcmpi(varargin, '-recursive')) = [];
    end
    
    if mod(length(varargin),2) && ~isstruct(varargin{1})
        % odd number of input arguments. The first input argument has to define the folder
        opts.folder = varargin{1};
        % remove the first input argument from the list
        varargin(1) = [];
    end
    
    % initialize counter
    cntr = 0;
    % initialize values for the while loop
    L = length(varargin);
    
    while cntr < L
        cntr = cntr + 1;
        
        if isstruct(varargin{cntr})
            % convert structure to cell array as if it were individual input arguments.
            temp     = struct2cellwfieldnames(varargin{cntr});
            varargin = [temp varargin(2:end)];
            cntr     = cntr - 1;
            L        = length(varargin);
            continue
        end
        
        % parse through all remaining parameter - parameter value pairs
       	switch lower(varargin{cntr})
            case 'folder'
                if ~isempty(varargin{cntr+1}) && ~ischar(varargin{cntr+1})
                    % the folder has to be a valid character string
                    errorbox('The optional parameter value ''folder'' has to be a valid string.', 'Bad option ''folder''', [mfilename ':BadFolder']);
                else
                    if isempty(opts.folder)
                        % the filename is not set yet
                        opts.folder = varargin{cntr+1};
                    end
                end
            case {'ext' 'extension' 'extensions'}
                if ~(ischar(varargin{cntr+1}) || (iscellstr(varargin{cntr+1}) && isvector(varargin{cntr+1})))
                    % the extension has to be a valid character string
                    errorbox('The optional parameter value ''extension'' has to be a valid character string or a cell array of strings.', 'Bad option ''extension''', [mfilename ':BadExtension']);
                else
                    opts.extension = varargin{cntr+1};
                end
            case 'children'
                warning([mfilename ':ChildrenDepricated'], 'The use of the option ''children'' is depricated and will be removed in future releases. Use the option ''-recursive'' instead.')
                if ~istforonoff(varargin{cntr+1})
                    % the children option can be a logical scalar or 'on' or 'off'
                    errorbox('The ''children'' option can be either a logical scalar, ''on'' or ''off''.', 'Bad option ''children''', [mfilename ':BadChildren']);
                else
                    opts.recursive = tforonoff2tf(varargin{cntr+1});
                end
            case 'fullpath'
                if ~istforonoff(varargin{cntr+1})
                    % the fullpath option can be a logical scalar or 'on' or 'off'
                    errorbox('The ''fullpath'' option can be either a logical scalar, ''on'' or ''off''.', 'Bad option ''fullpath''', [mfilename ':BadFullPath']);
                else
                    opts.fullpath = tforonoff2tf(varargin{cntr+1});
                end
                
            otherwise
                % parameter not recognized
            	errorbox(sprintf('Invalid parameter ''%s''.', varargin{cntr}), 'Optional parameter not valid', [mfilename ':NotValidOptionalIpt']);
        end
        
        % increase the counter
        cntr = cntr + 1;
        
    end % end of loop through optional input arguments
    
end % end of subfunction 'parse_ipt'