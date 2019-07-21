function tf = isfigorpanel(FigPan)
% isfigorpanel returns true if the object is a figure or a uipanel
    % ----------------------------------------------------------------------------------------------
    %
    %                                       isfigorpanel
    % 
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/isfigorpanel.m $
    % Original author: Nick Smisdom, Hasselt University / VITO
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf = isfigorpanel(FigPan)
    %
    % DESCRIPTION
    % -----------
    % tf = isfigorpanel(FigPan) returns true if the argument is a figure or a uipanel.
    % 
    % EXAMPLE
    % -------
    % 
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
    
    tf = ~isempty(FigPan) && ishghandle(FigPan) && any(strcmpi(FigPan.Type, {'figure' 'uipanel'}));

end % end of function 'isfigorpanel'