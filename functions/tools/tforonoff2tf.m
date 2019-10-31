function tf = tforonoff2tf(in)
% tforonoff2tf returns true if the argument is 'on' or true or 1
    % ----------------------------------------------------------------------------------------------
    %
    %                                     tforonoff2tf
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/support%20fcns/tforonoff2tf.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf = tforonoff2tf(ipt)
    %
    % DESCRIPTION
    % -----------
    % tf = tforonoff2tf(ipt) returns true if the argument is either 'on' or a logical value (0 or 1).
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
        tf = in;
    else
        tf = ison(in);
    end
    
end % end of function 'tforonoff2tf'