function tf = isinmatfile(filename, name)
% isinmatfile returns true if the variable is in the .mat file
    % ----------------------------------------------------------------------------------------------
    %
    %                                        isinmatfile
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/isinmatfile.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    %
    % SYNTAX
    % ------
    % tf = isinmatfile(filename, name)
    % 
    % DESCRIPTION
    % -----------
    % tf = isinmatfile(filename, name) returns true if the variable is in the .mat file.
    %
    % MODIFICATIONS
    % -------------
    %
    % Copyright 2008-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
        
    % check number of input and output arguments
    if nargin ~= 2 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 2, nargout, [0 1], mfilename);
        
    % Parse input arguments
    elseif ~isfile(filename)
        % the first input argument should specify a valid .mat file
        errorbox('The first input argument should specify a valid .mat file.', 'Invalid .mat file', 'id', [mfilename ':InvalidMatFile']);
        
    elseif ~ischar(name) && ~iscellstr(name)
        % the second input argument should be a character string specifying the name of the
        % variable, or a cell string array specifying the name of several variables
        errorbox(['The second input argument should be a character string specifying '...
                  'the name of the variable, or a cell string array specifying '...
                  'the name of several variables.'], 'Invalid variable name', 'id', [mfilename ':InvalidVarName']);
              
    end
    
    
    % EXECUTION
    % ---------
    
    if iscell(name)
        % a cell string array with the name of several variables is given
        
        % first, get the name of all variables present in the mat file
        list = who('-file', filename);
        
        % perform the actual function for each cell of the array
        tf = cellfun(@(x) any(strcmp(list, x)), name);
        
    else
        % only one name is specified
        tf = any(strcmp(who('-file', filename), name));
        
    end
        
end % end of function 'isinmatfile'