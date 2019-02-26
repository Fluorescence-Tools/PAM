function tf = isvar(varname)
% isvar returns true if the variable exists in the workspace of the calling function
    % ----------------------------------------------------------------------------------------------
    %
    %                                           isvar
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/support%20fcns/isvar.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % tf = isvar(varname)
    % 
    % DESCRIPTION
    % -----------
    % tf = isvar(varname) returns true if the variable varname exists in the workspace of the
    % calling function. varname should be a string specifying the name of the variable of interest.
    %
    % REMARKS
    % -------
    % This function actually applies the code any(strcmp(varname, who)), where who returns the name
    % of all existing variables. Note that who should be executed in the workspace of the calling
    % function and not in the workspace of the isvar function. This is achieved using the evalin
    % function.
    % 
    % EXAMPLES
    % --------
    % To check whether the variable 'filename' exists in the workspace the following code can be
    % used:
    %    if isvar('filename')
    %        disp(sprintf('The variable ''filename'' is present'))
    %    else
    %        disp(sprintf('The variable ''filename'' is not present'))
    %    end
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
        
    elseif ~ischar(varname)
        % the input argument should be a valid stirng specifying the name of the variable
        errorbox('The input argument should be a valid string specifying the name of the variable', 'Bad variable name', 'id', [mfilename ':BadVarName']);
        
    end
    
    
    % EXECUTION
    % ---------
    
    % evalin is used to get the names of all variables that exist in the workspace of the caller
    % function. In this way, the user does not need to supply the function with this list.
    tf = any(strcmp(varname, evalin('caller', 'who')));
    
end % end of function 'isvar'