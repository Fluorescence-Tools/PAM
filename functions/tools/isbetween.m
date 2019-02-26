function tf = isbetween(val, Range, Option)
% isbetween returns true if a value is within a specified range
    % ----------------------------------------------------------------------------------------------
    %
    %                                         isbetween
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/isbetween.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % tf = isbetween(Val, [Minimum Maximum])
    % tf = isbetween(Val, [Minimum Maximum], 'exclusive')
    %
    % DESCRIPTION
    % -----------
    % tf = isbetween(Val, [Minimum Maximum]) returns true if Val is an element of the interval
    % [Minimum Maximum], including the bounds.
    %
    % tf = isbetween(Val, [Minimum Maximum], 'exclusive') returns true if Val belongs to the
    % interval [Minimum Maximum], with exclusion of the bounds.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % =====================================================================
    
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin < 2 || nargin > 3 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [2 3], nargout, 1, mfilename);
    
    elseif ~isnumeric(val)
        % val should be a scalar
        errorbox('The value should be a scalar', 'Value is not a scalar.', [mfilename ':BadValue']);
        
    elseif size(Range,2) ~= 2
        % the Range should be a row vector
        errorbox('The Range should be a sorted two-element vector or a n-by-2 matrix.', 'Bad Range', [mfilename ':BadRange']);
        
    elseif nargin == 3
        if ~strcmpi(Option, 'exclusive')
            errorbox(sprintf('The optional input argument should be ''exclusive''.'), 'Bad optional input argument', [mfilename ':BadExclusive']);
        else
            inclusive_tf = false;
        end
        
    else
        inclusive_tf = true;
    end
        
   
    % EXECUTION
    % ---------
    
    if inclusive_tf
        
        tf = val >= Range(:,1) & val <= Range(:,2);
        
        return
        
    else
        
        tf = val > Range(:,1) & val < Range(:,2);
        
        return
    end
    
end % end of function 'isbetween'