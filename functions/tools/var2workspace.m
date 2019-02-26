function var2workspace(varargin)
% var2workspace assigns variables from the current workspace down into the base MATLAB workspace
    % ---------------------------------------------------------------------
    %
    %                       var2workspace
    %
    % ---------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/support%20fcns/var2workspace.m $
    %
    % ---------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % var2workspace(var1, var2, ...)
    % var2workspace('var1', 'var2', ...)
    % 
    % DESCRIPTION
    % -----------
    % var2workspace(var1, var2, ...)copies variables from the current
    % matlab workspace down to the base matlab workspace. The function can
    % be used while in a debugging session, to retain the value of a
    % variable, saving it into the base matlab workspace. The function can
    % also be used to return a specific variable, avoiding the use of a
    % return argument (for whatever reason you might have.)
    % 
    % var2workspace('var1', 'var2', ...) accepts the name of the variables
    % instead of the variables themselves.
    % 
    % ACKNOWLEDGEMENT
    % ---------------
    % This function is based on the function PUTVAR of John D'Errico,
    % release 2.0.
    % 
    % copyright 2010-2014
    % =====================================================================
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargout > 0
        % incorrect number of input arguments
        chknarg(nargin, [0 Inf], nargout, 0, mfilename);
    
    elseif nargin < 1
        % no variables requested for the assignment,
        % so this is a no-op
        return
    
    end
    
    
    % EXTENSION
    % ---------
    
    % get the list of variable names in the caller workspace.
    % callervars will be a cell array that lists the names of all
    % variables in the caller workspace.
    callervars = evalin('caller','who');
    
    % likewise, basevars is a list of the names of all variables
    % in the base workspace.
    basevars = evalin('base','who');
    
    % loop over the variables supplied
    for m = 1:nargin
        
        % get the input name of the current variable
        iptname = inputname(m);
        
        % get the value 
        var_val = varargin{m};
        
        if ~isempty(iptname)
            % The current variable has a name, so assign this variable
            % into the base workspace
            
            % First though, check to see if the variable is already there.
            % If it is, we will need to set a warning.
            if any(strcmp(iptname,basevars))
%                 warningbox(sprintf('Input variable #%1.f (%s) already exists in the base workspace. It will be overwritten.', m, iptname), 'Variable overwritten', 'id', [mfilename ':overwrite'], 'wait', 'off');
                warning([mfilename ':overwrite'], 'Input variable #%1.f (%s) already exists in the base workspace. It will be overwritten.', m, iptname)
            end
            
            % assign the variable in base work space with the given name
            assignin('base',iptname,var_val)
            
        elseif ischar(var_val) && any(strcmp(var_val,callervars))
            % the i'th variable was a character string, that names
            % a variable in the caller workspace. We can assign
            % this variable into the base workspace.

            % First though, check to see if the variable is already there.
            % If it is, we will need to set a warning.
            iptname = var_val;
            if any(strcmp(iptname,basevars))
%                 warningbox(sprintf('Input variable #%1.f (%s) already exists in the base workspace. It will be overwritten.', m, iptname), 'Variable overwritten', 'id', [mfilename ':overwrite'], 'wait', 'off');
                warning([mfilename ':overwrite'], 'Input variable #%1.f (%s) already exists in the base workspace. It will be overwritten.', m, iptname)
            end
            
            % extract the indicated variable contents from
            % the caller workspace.
            var_val = evalin('caller',iptname);

            % do the assign into the indicated name
            assignin('base',iptname,var_val);

        else
            % we cannot resolve this variable
%             warningbox(sprintf('The input variable #%1.f was not assigned in the base workspace since no caller workspace variable was available for that input.', m), 'Variable overwritten', 'id', [mfilename ':NoVar'], 'wait', 'off');
            warning([mfilename ':NoVar'], 'The input variable #%1.f was not assigned in the base workspace since no caller workspace variable was available for that input.', m)
            
        end

    end
    
end % end of function 'var2workspace'