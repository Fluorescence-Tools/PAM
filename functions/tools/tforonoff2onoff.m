function tf = tforonoff2onoff(in)
% tforonoff2onoff returns 'on' if the argument is 'on' or true or 1, and 'off' otherwise
    % ----------------------------------------------------------------------------------------------
    %
    %                                      tforonoff2onoff
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/support%20fcns/tforonoff2onoff.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf = tforonoff2onoff(ipt)
    %
    % DESCRIPTION
    % -----------
    % tf = tforonoff2onoff(ipt) returns 'on' if the argument is either 'on' true or 1, and 'off'
    % otherwise.
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
    
    if istf(in)
        tf = tf2onoff(in);
    elseif isonoff(in)
        tf = in;
    else
        errorbox('Not a valid option', 'invalid option', [mfilename ':BadOptn']);
    end
    
end % end of function 'tforonoff2onoff'