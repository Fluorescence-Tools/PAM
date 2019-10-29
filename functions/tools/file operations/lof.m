function L = lof(filename)
% lof returns the length of the file
    % ----------------------------------------------------------------------------------------------
    %
    %                                           lof
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/lof.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % L = lof(filename)
    % 
    % DESCRIPTION
    % -----------
    % L = lof(filename) returns the length of the file. filename should specify the full path to the
    % file.
    % 
    % 
    % copyright 2008-2017
    % ==============================================================================================
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin ~= 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
        
    elseif ~isfile(filename)
        % the file does not exist
        errorbox(sprintf('The file ''%s'' does not exist.', filename), 'Bad file name', 'id', [mfilename ':BadFile']);
        
    elseif isempty(fileparts(filename))
        % only the name is specified, without the full path. This is not allowed, because MATLAB
        % does not know where to create the new file
        errorbox(sprintf('The full path to the file ''%s'' is not specified. This information is necessary to use the correct file.', filename), 'No full path specified', 'id', [mfilename ':BadFullPathToFile']);
        
    end
    
    
    % EXECUTION
    % ---------
    
    % get the file information from the file
    temp = dir(filename);
    
    if length(temp) ~= 1
        % no file information found
        
        % return NaN
        L = NaN;
        
        return
        
    else
        % get the length from the file information
        L = temp.bytes;
        
    end
    
end % end of function 'lof'