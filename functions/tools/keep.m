function keep(varargin)
% keep deletes all variables from the caller workspace except those listed in the command
    % ----------------------------------------------------------------------------------------------
    %
    %                                           keep
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/keep.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % keep var1 var2 ...
    % keep('var1', 'var2', ...)
    % keep(var1, var2, ...)
    %
    % DESCRIPTION
    % -----------
    % keep var1 var2 ... deletes all variables from the caller workspace except those listed in the
    % command, in this case var1 and var2.
    %
    % keep('var1', 'var2', ...) deletes all variables from the caller workspace except those listed
    % in as a string between round brackets, in this case var1 and var2.
    % 
    % keep(var1, var2, ...) deletes all variables from the caller workspace except those passed
    % directly to this function, in this case var1 and var2.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [0 Inf], nargout, [0 1], mfilename);
    end
    
    
    % EXECUTION
    % ---------
    
    % create empty cell array to hold the variable names
    keep_list = {};
    
    % loop over the variables supplied
    for m = 1:nargin
        
        % get the input name of the current variable
        iptname = inputname(m);
        
        if ~isempty(iptname)
            % The current variable has a name, so assign this variable
            % into the list of variables that need to be kept
            keep_list{end+1,1} = iptname; %#ok<*AGROW>
        else
            % get the value 
            var_val = varargin{m};
            if ischar(var_val)
                % the i'th variable was a character string
                keep_list{end+1,1} = var_val;
            else
                % we cannot resolve this variable
                warning([mfilename ':BadVar'], 'The input variable #%1.f could not be kept.', m)
            end
        end
    end
    
    if ~isempty(keep_list)
        evalin('caller', [sprintf('clearvars(''-except''') sprintf(', ''%s''', keep_list{:}) ')'])
    end
    
end % end of function 'keep'