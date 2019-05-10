function s = duplicatescalar(s)
% duplicatescalar returns a vector holding two copies of the scalar
    % ----------------------------------------------------------------------------------------------
    %
    %                                     duplicatescalar
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/duplicatescalar.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % s = duplicatescalar(s)
    % 
    % DESCRIPTION
    % -----------
    % S = duplicatescalar(s) returns a row vector S holding two copies of the scalar s. If s is not
    % a scalar, this function does not alter s and in that case S = s.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % first check the number of input and output arguments
    if nargin ~= 1 || nargout > 1
        chknarg(nargin, 1, nargout, [0 1], mfilename);
        
    
    % EXECUTION
    % ---------
    
    elseif isscalar(s)
        s = [s s]; 
    end
    
end % end of function 'duplicatescalar'