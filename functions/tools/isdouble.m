function tf = isdouble(x)
% isdouble returns true if the input variable is in the double format
    % ----------------------------------------------------------------------------------------------
    %
    %                                       isdouble
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/isdouble.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf = isdouble(x)
    % 
    % DESCRIPTION
    % -----------
    % tf = isdouble(x) returns true if the input variable is in the double format.
    %
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin < 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
    end
    
    
    % EXECUTION
    % ---------
    
    % get the class of the variable x and compare with 'double'
    tf = isa(x, 'double');
    
end % end of function 'isdouble'