function file = selectfile(varargin)
% selectfile allows the user to select a file and returns its full path
    % ----------------------------------------------------------------------------------------------
    %
    %                                        selectfile
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-17 14:45:42 +0100 (Wed, 17 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 14 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/selectfile.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % filename = selectfile
    % filename = selectfile(folder)
    % filename = selectfile('extension', EXT)
    % filename = selectfile('extension', EXT, 'extensionTitle', ExtTitle)
    % filename = selectfile(..., 'parameter', 'parameter value')
    %
    % DESCRIPTION
    % -----------
    % filename = selectfile lets the user interactively select a file using a dialog box. Upon
    % selection, the full name of the file name is returned. If the user chooses to cancel the
    % function, 0 is returned.
    % 
    % filename = selectfile(folder) opens a dialog box in the folder as specified by folder. If
    % folder is a filename or a full path to a file, the function checks whether this file exists
    % and its full path is returned. If this file does not exist, 0 is returned.
    % 
    % filename = selectfile('extension', EXT) let the user select only files with the extension as
    % specified in EXT. EXT can be a string or a cell array of strings.
    % 
    % filename = selectfile('extension', EXT, 'extensionTitle', ExtTitle) allows for a specification
    % of the extensions. If EXT is a cell array, ExtTitle should also be a cell array with similar dimensions.
    % 
    % filename = selectfile(..., 'parameter', 'parameter value') allows the user to set optional
    % parameters:
    %   'MultiSelect'           'on'/{'off'}    let the user select multiple files. filename will
    %                                           consequently be a cell array of strings.
    %   'combine_extensions'    {'on'}/'off'    creates an entry that allows the user to select a
    %                                           file with all possible extensions defined.
    %   'tryfoldericobadfile'   {'on'}/'off'    tries to derive a valid folder in case that the
    %                                           specified file does not exist.
    % 
    % EXAMPLE
    % -------
    % 
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2018
    % ==============================================================================================

    % INITIALISATION
    % --------------
    
    % parse input arguments
    if nargin > 11 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [0 11], nargout, [0 1], mfilename);
    else
        opts = parse_ipt(varargin{:});
    end
    
    
    % EXECUTION
    % ---------
    
    % parse extensions
    [selection, dlgtitle] = parseexts(opts);
    
    % did the user enter a filename
    if iscellstr(opts.folder)
        % a cell array of filenames
        
        % all filenames should be valid files
        if any(~isfile(opts.folder))
            tf = ~isfile(opts.folder);
            txt = 'All defined filenames should be valid files. The following files are invalid:';
            for m = 1 : length(tf)
                if tf(m)
                    txt = [txt char([13 10]) sprintf('%2.0f', m) ') ' opts.folder{m}]; %#ok<AGROW>
                else
                    continue
                end
            end
            errorbox(txt, 'Bad Files', [mfilename ':BadCellFiles']);
        else
            file = opts.folder(:);
        end
        
    elseif isempty(opts.folder)
        % no file or folder specified, ask the user to select a file
        
        % show dialog box
        [filename, folder] = uigetfile(selection, dlgtitle, 'MultiSelect', opts.multiselect);
        
        % Covert file name to full path
        file = convertfile2fullpathcell(filename, folder);
        
    elseif isdir(opts.folder)
        % The user has inserted a directory
        
        % show dialog box
        [filename, folder] = uigetfile(selection, dlgtitle, opts.folder, 'multiselect', opts.multiselect);
        
        % Covert file name to full path
        file = convertfile2fullpathcell(filename, folder);
        
    elseif isfile(opts.folder)
        % the user has given a filename that exists
        
        % save full filename to output argument
        [~,mess] = fileattrib(opts.folder);
        
        if isstruct(mess)
            file = mess.Name;
        elseif strcmpi(strtrim(mess), 'The system cannot find the file specified.')
            file = which(opts.folder);
        else
            errorbox(['The file ''' opts.folder ''' does not exist.'], 'Unknown File', [mfilename ':UnknownFile']);
        end
        
    else
        if opts.tryfoldericobadfile
            % try to find a valid folder form the defined name
            oldfolder = opts.folder;
            for m = 1 : 5
                [opts.folder, ~] = fileparts(opts.folder);
                if isdir(opts.folder)
                    file = selectfile(opts);
                    break
                else
                    continue
                end
            end
            if ~isvar('file')
                errorbox(['The file ''' oldfolder ''' does not exist.'], 'Unknown File', [mfilename ':UnknownFile']);
            end
        else
            errorbox(['The file ''' opts.folder ''' does not exist.'], 'Unknown File', [mfilename ':UnknownFile']);
        end
    end
    
end % end of function 'selectfile'



%% -------------------------------------------------------------------------------------------------
function opts = parse_ipt(varargin)
    % parse_ipt parses the input arguments of the main function 'selectfile'. Explanation of input
    % arguments can be found in the description of the main function
    
    % set default values
    opts.folder         = '';
    opts.extension      = '';
    opts.extensiontitle = '';
    opts.multiselect    = 'off';
    opts.combineext     = true;  % by default combine extensions to one entry
    opts.tryfoldericobadfile = true; % by default, try to find folder if file does not exist.
    
    if mod(nargin,2) && ~isstruct(varargin{1})
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
            case {'folder' 'file' 'files' 'folders'}
                if ~isempty(varargin{cntr+1}) && (~ischar(varargin{cntr+1}) && ~iscellstr(varargin{cntr+1}))
                    % the file name has to be a valid character string
                    errorbox('The optional parameter value ''folder'' has to be a valid string or cell array of strings.', 'Bad option ''folder''', [mfilename ':BadFolder']);
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
            case {'extensiontitle' 'title' 'exttitle', 'extension_title', 'extension title' 'ext title'}
                if ~(ischar(varargin{cntr+1}) || (iscellstr(varargin{cntr+1}) && isvector(varargin{cntr+1})))
                    % the extension title has to be a valid character string
                    errorbox('The optional parameter value ''extensiontitle'' has to be a valid character string or a cell array of strings.', 'Bad option ''extensiontitle''', [mfilename ':BadExtensionTitle']);
                else
                    opts.extensiontitle = varargin{cntr+1};
                end
            case 'multiselect'
                if ~istforonoff(varargin{cntr+1})
                    % the multiselect option can be a logical scalar or 'on' or 'off'
                    errorbox('The ''multiselect'' option can be either a logical scalar, ''on'' or ''off''.', 'Bad option ''multiselect''', [mfilename ':BadMultiSelect']);
                else
                    opts.multiselect = tforonoff2onoff(varargin{cntr+1});
                end
          	case {'combineext' 'combineextensions' 'combine extensions' 'combine_extensions'}
                if ~istforonoff(varargin{cntr+1})
                    % the combineext option can be a logical scalar or 'on' or 'off'
                    errorbox('The ''combineext'' option can be either a logical scalar, ''on'' or ''off''.', 'Bad option ''combineext''', [mfilename ':BadCombineExt']);
                else
                    opts.combineext = tforonoff2tf(varargin{cntr+1});
                end
            case 'tryfoldericobadfile'
                if ~istforonoff(varargin{cntr+1})
                    % the tryfoldericobadfile option can be a logical scalar or 'on' or 'off'
                    errorbox('The ''tryfoldericobadfile'' option can be either a logical scalar, ''on'' or ''off''.', 'Bad option ''tryfoldericobadfile''', [mfilename ':Badtryfoldericobadfile']);
                else
                    opts.tryfoldericobadfile = tforonoff2tf(varargin{cntr+1});
                end
                
            otherwise
                % parameter not recognized
            	errorbox(sprintf('Invalid parameter ''%s''.', varargin{cntr}), 'Optional parameter not valid', [mfilename ':NotValidOptionalIpt']);
        end
        
        % increase the counter
        cntr = cntr + 1;
        
    end % end of loop through optional input arguments
    
end % end of subfunction 'parse_ipt'


% -------------------------------------------------------------------------
function [extlist, dlgtitle] = parseexts(opts)
    % this function parses the extensions
    
    ext      = opts.extension;
    exttitle = opts.extensiontitle;
    
    if isempty(ext)
        % no extension given
        extlist  = {'*.*', 'All Files'};
        dlgtitle = 'Select a file';
        return
    
    elseif ~iscellstr(ext)
        % make ext to be a cell array
        ext = {ext};
    end
    
    if ~isempty(exttitle)
        % also titles of the extensions given
        
        if ~iscellstr(exttitle)
            % make exttitle to be a cell array
            exttitle = {exttitle};
        end
        
        % the cell array with titles has to be of equal length
        if length(exttitle) ~= length(ext)
            errorbox(sprintf('The titles of the extensions should also be a cell array with %1.0f elements.', length(ext)), 'Bad extension titles', [mfilename ':BadEXTTitles']);
        end
        
    else
        % create cell array with empty titles
        exttitle = cell(size(ext));
    end
    
    % allocate memory
    extlist = cell(length(ext),2);
    extlist(:,1) = ext(:);
    extlist(:,2) = exttitle(:);
    
    % create dialogue title
    if isempty(extlist)
        % create default list
        extlist = '*.*';
    end
    
    if size(extlist,1)==1 && ~isempty(extlist{1,2})
       % create custom title
       
       % find bracket
       k = regexp(extlist{1,2}, '\(', 'once');
       
       if isempty(k) || k<2
           % create default title
           dlgtitle = 'Select a file';
       
       else
           dlgtitle = ['Select a ' extlist{1,2}(1:k-2)];
       end
       
    else
        % create default title
       	dlgtitle = 'Select a file';
    end
    
    if opts.combineext
        % make an entry combining all extensions
        extlist = addcombinedfileextensions(extlist);
    end
    
end % end of subfunction 'parseexts'


%% -------------------------------------------------------------------------------------------------
function fullfilename = convertfile2fullpathcell(filename, folder)
    % this function converts a single file to its full path. If filename is a cell, the output will
    % also be a cell array.
    
    if iscell(filename)
        % filename is a cell array of file names
        fullfilename = cellfun(@(x) fullfile(folder, x), filename(:), 'uniformoutput', false);
    
    elseif filename == 0
        % no file selected
        % return zero
        fullfilename = false;
        
    else
        % only a single file selected
        % convert it to the full path
        fullfilename = fullfile(folder, filename);
    end
    
end % end of subfunction 'convertfile2fullpathcell'