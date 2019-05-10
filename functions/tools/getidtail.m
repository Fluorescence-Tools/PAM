function tail = getidtail(id)
% getidtail returns the trailing part of the error identifier
    % ----------------------------------------------------------------------------------------------
    %
    %                                          getidtail
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/support%20fcns/getidtail.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % idtail = getidtail
    % 
    % DESCRIPTION
    % -----------
    % idtail = getidtail returns the trailing part of the error identifier, preceded by a colon.
    % 
    % Copyright 2015-2017
    % ==============================================================================================
    
    % INITIALIZATION
    % --------------

    if nargin ~= 1 || nargout > 1
        chknarg(nargin, 1, nargout, [0 1], mfilename);
    elseif ~ischar(id)
        % the input argument has to ba a valid string of characters
        errorbox('The input argument has to be a valid string of characters, representing an error identifier.', 'Invalid identifier', [mfilename 'BadId']);
    end
    
    
    % EXECUTION
    % ---------
    
    % find the last colon in the error identifier
    ix = strfind(id, ':');
    
    % return this colon together with the text following this colon.
    tail = id(ix(end):end);

end % end of function 'getidtail'