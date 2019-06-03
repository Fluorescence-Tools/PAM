function filename = persistent_folders(new_tf)
% persistent_folders returns the .mat file holding all persistent folders
    % ----------------------------------------------------------------------------------------------
    %
    %                                  persistent_folders
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/persistent_folders.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % filename = persistent_folders
    % filename = persistent_folders('new')
    %
    % DESCRIPTION
    % -----------
    % filename = persistent_folders returns the absolute path to the mat file that holds all
    % persistent folders. If this file does not exist, a new file will be created.
    % 
    % filename = persistent_folders('new') resets the file to the default. Basically, any input
    % argument triggers this reset.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2015
    % ==============================================================================================

    % INITIALISATION
    % --------------
        
    % check number of input and output arguments
    if nargin > 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [0 1], nargout, [0 1], mfilename);
        
    elseif nargin == 1
        % an optional arguments is given
        new_tf = true;
        
    else
        % no optional argument is given
        new_tf = false;
    end
    
    
    % EXECUTION
    % ---------
    
    % create the full path to the SaveLoadDirectories.mat file
    filename = fullfile(user_default_folder, 'persistent_folders.mat');
    
    if ~isfile(filename) || new_tf
        % the file does not exist yet or a new file has to be created
        mkpersistent_folders(filename);
    end
    
end % end of function 'persistent_folders'