function tf = isfile(filename)
% isfile returns true if the argument is a valid file
    % ----------------------------------------------------------------------------------------------
    %
    %                                          isfile
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/isfile.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf = isfile(filename)
    %
    % DESCRIPTION
    % -----------
    % tf = isfile(filename) returns true if the argument is the name of an existing file.
    % 
    % EXAMPLE
    % -------
    % 
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin ~= 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
        
    end
    
    
    % EXECUTION
    % ---------
    
    if isempty(filename)
        % the filename is empty. Return false
        tf = false;
        return
    
    elseif ~iscell(filename)
        % slow procedure
        tf = any(exist(filename, 'file') == [2 3 4 6]);
        
        if ~tf
            % the file appears not to exist

            % get the information of the file
            f = dir(filename);

            if isempty(f)
                % the file indeed does not exist
                tf = false;

            elseif length(f) > 1 || f.isdir
                % the file is a directory

                tf = false;

            else
                % the file exists
                tf = true;

            end
        end
    else
        tf = cellfun(@isfile, filename);
        
    end

end % end of function 'isfile'