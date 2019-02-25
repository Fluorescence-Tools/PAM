function tf = ispanel(panel)
% ispanel returns true if the object is a uipanel
    % ----------------------------------------------------------------------------------------------
    %
    %                                        ispanel
    % 
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/ispanel.m $
    % Original author: Nick Smisdom, Hasselt University / VITO
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf = ispanel(panel)
    %
    % DESCRIPTION
    % -----------
    % tf = ispanel(panel) returns true if the argument is a uipanel.
    % 
    % EXAMPLE
    % -------
    % 
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2015
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
    
    tf = ~isempty(panel) && ishghandle(panel) && strcmp(panel.Type, 'uipanel');

end % end of function 'ispanel'