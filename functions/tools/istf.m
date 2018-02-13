function tf_result = istf(tf)
% istf returns true if the input is a logical or a value equal to 1 or 0
    % ----------------------------------------------------------------------------------------------
    %
    %                                           istf
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/support%20fcns/istf.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf_result = istf(tf)
    %
    % DESCRIPTION
    % -----------
    % tf_result = istf(tf) returns true if the input is a logical value or a value equal to 1 or 0.
    % tf can be any matrix.
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
    
    tf_result = all(~ischar(tf) & (islogical(tf) | tf==0 | tf==1));
    
end % end of function 'istf'