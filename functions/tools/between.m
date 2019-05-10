function NewVal = between(val, Range)
% between limits a value to a specified range
    % ----------------------------------------------------------------------------------------------
    %
    %                                          between
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/between.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % NewVal = between(Val, [Minimum Maximum])
    %
    % DESCRIPTION
    % -----------
    % NewVal = between(Val, [Minimum Maximum]) returns a value NewVal that is equal to Val if it is
    % an element of the interval [Minimum Maximum]. If this is not the case, this value is equal to
    % Minimum when its value is smaller than Minimum or it is equal to Maximum when its value is
    % bigger than Maximum.
    %
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin ~= 2 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 2, nargout, 1, mfilename);
    
    elseif ~isnumeric(val) || ~isvector(val)
        errorbox('The value should be a numeric vector', 'Value is not a scalar.', 'id', [mfilename ':BadValue']);
        
    elseif numel(Range) ~= 2
        errorbox('The Range should be a sorted two-element vector.', 'Bad Range', 'id', [mfilename ':BadRange']);
    end
    
    % make sure Range is properly sorted
    if ~issorted(Range)
        Range = sort(Range);
    end
   
    
    % EXECUTION
    % ---------
    
    % make sure the value is within the range
    NewVal = max(min(val, Range(2)), Range(1));
    
end % end of function 'between'