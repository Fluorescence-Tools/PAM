function folder = data_folder(folder)
% data_folder returns the data folder that was last used
    % ----------------------------------------------------------------------------------------------
    %
    %                                       data_folder
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/data_folder.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % folder = data_folder
    % folder = data_folder(newfolder)
    % folder = data_folder([])
    %
    % DESCRIPTION
    % -----------
    % folder = data_folder returns the last used data folder.
    % 
    % folder = data_folder(newfolder) allows the user to set a new folder. If the folder is invalid,
    % the last used data folder is returned.
    % 
    % folder = data_folder([]) lets the user interactively select a new folder.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
        
    % check number of input and output arguments
    if nargin > 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [0 1], nargout, [0 1], mfilename);
    end
    
    
    % EXECUTION
    % ---------
    
    if nargin==1 && ischar(folder) && ~isempty(folder) && isdir(folder)
        % the user has specified a new folder and this folder exists
        recent_data_folders(folder);
        return
    elseif nargin == 1 && isempty(folder)
        % interactive selection of a new data folder requested
        folder = data_folder(uigetdir(data_folder));
        return
    end
    
    % either no input argument is given or the user-specified folder does not exist
    
    % get the mage folder from the mat file
    folders = recent_data_folders;
    folder  = folders{1};
    
end % end of function 'data_folder'