function tf = istforonoff(in)
% istforonoff returns true if the argument is one of the strings 'on' or 'off' or when it is a logical value
    % ----------------------------------------------------------------------------------------------
    %
    %                                       istforonoff
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/support%20fcns/istforonoff.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf = istforonoff(ipt)
    %
    % DESCRIPTION
    % -----------
    % tf = istforonoff(ipt) returns true if the argument is either 'on' or 'off', or a logical
    % value (0 or 1).
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
    
    tf = all(istf(in)) || isonoff(in);
    
end % end of function 'istforonoff'