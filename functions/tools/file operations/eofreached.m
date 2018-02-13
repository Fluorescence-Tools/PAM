function tf = eofreached(fid)
% eofreached returns true if the end of the file is reached
    % ----------------------------------------------------------------------------------------------
    %
    %                                       eofreached
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/eofreached.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf = eofreached(fid)
    % 
    % DESCRIPTION
    % -----------
    % tf = eofreached(fid) returns true if the end of the file is reached. The file should be
    % specified by its file identifier.
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
    
    % try to return the current position in the file
    try currpos = ftell(fid);
        
    catch ME
        % an error has occurred
        
        % display the error
        errorbox(ME.message, 'Bad identifier', [mfilename ':' ME.identifier]);
        
    end
    
    if currpos == -1
        % the current position could not be determined
        
        % return false
        tf = false;
        
        % stop the function
        return
        
    end
    
    % go to the end of the file
    fseek(fid, 0, 'eof');
    
    % check whether the location of the end of the file is the same as the
    % current location
    tf =  currpos == ftell(fid);
    
    % go back to the original position
    fseek(fid, currpos, 'bof');

end % end of function 'eofreached'