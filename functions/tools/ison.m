function tf = ison(Str)
% ison returns true if the argument string is 'on'
    % ----------------------------------------------------------------------------------------------
    %
    %                                          ison
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/support%20fcns/ison.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf = ison(Str)
    %
    % DESCRIPTION
    % -----------
    % tf = ison(Str) returns true if the argument is 'on'.
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
    
    tf = ischar(Str) && strcmpi(Str, 'on');
    
end % end of function 'ison'