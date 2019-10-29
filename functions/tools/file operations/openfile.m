function [FileID, filename, msg] = openfile(varargin)
% openfile opens a file and returns the file identifier
    % ----------------------------------------------------------------------------------------------
    %
    %                                        openfile
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/openfile.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % FileId = openfile
    % FileId = openfile(folder)
    % FileId = openfile(..., 'extension', EXT)
    % FileId = openfile(..., 'extensionTitle', ExtTitle)
    % [FileId, filename, msg] = openfile(...)
    %
    % DESCRIPTION
    % -----------
    % FileId = openfile lets the user select a file and tries to open it. An error is thrown upon an
    % invalid file or when the file can not be opened correctly.
    %
    % FileId = openfile(folder) let the user select a file in the folder as specified by folder. If
    % folder is a filename or a full path to a file, the function checks whether this file exists.
    % If this file does not exist, 0 is returned. Finally, the function tries to open the file.
    %
    % FileId = openfile('extension', EXT) let the user select only files with the extension as
    % specified by the string EXT. EXT can either be of the format 'ext', '.ext' or '*.ext'.
    %
    % FileId = openfile('extensionTitle', ExtTitle) allows for a specification of the extension.
    % 
    % [FileId, filename, msg] = openfile(...) returns the name of the file in the first optional
    % output argument. The second optional output argument returns an error message. In case a total
    % of 3 output arguments is requested, no error will be thrown when the file could not be opened.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    if mod(nargin,2) && isfile(varargin{1})
        % the number of input arguments is odd. The first input argument has to be a valid filename
        % Try to open the file first, before executing the rest of this function. This is the
        % time-saving approach.
        
        filename = varargin{1};
        
        % try to open the file
        [FileID, msg] = fopen(filename, 'r','l');
            
    else
        
        % let the user select a file
        filename = selectfile(varargin{:}, 'multiselect', 'off');
        % note that selectfile accepts identical input arguments.
        
        if numel(filename) == 1 && filename == 0
            FileID = 0;
            msg = 'The user did not select a file.';
            
        else
            % try to open the file
            [FileID, msg] = fopen(filename, 'r','l');
            
        end
    
    end
    
    if FileID == -1 && nargout ~= 3
        % the file is not opened correctly
        
        % file did not open correctly
        errorbox(['The file ''' filename ''' could not be opened correctly.'], 'Unable to open file', [mfilename ':FileCouldNotBeOpened']);
        
    end
    
end % end of function 'openfile'