function tf = isodd(x)
% isodd returns true if the input is an odd integer value
    % ---------------------------------------------------------------------
    %
    %                               isodd
    %
    % ---------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/isodd.m $
    %
    % ---------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf = isodd(x)
    %
    % DESCRIPTION
    % -----------
    % tf = isodd(x) returns true if the input is an odd integer value.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2014
    % =====================================================================

    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin ~= 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
    end
    
    
    % EXECUTION
    % ---------
    
    if isnumeric(x)
        % the input argument is numeric. Note that a cell array holding
        % exclusively numbers is not considered as being numeric.
        tf = rem(x,2) == 1;
    else
        % the input is not numeric
        if ischar(x)
            % the input is a character string
            tf = 0;
        else
            % return false
            tf = false(size(x));
        end
    end
    
end % end of function 'isodd'