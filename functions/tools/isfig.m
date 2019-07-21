function tf = isfig(Fig)
% isfig returns true if the object is a figure
	% ----------------------------------------------------------------------------------------------
    %
    %                                          isfig
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/isfig.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % tf = isfig(Fig)
    %
    % DESCRIPTION
    % -----------
    % tf = isfig(Fig) returns true if the argument is a figure.
    % 
    % copyright 2008-2017
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
    
    tf = ~isempty(Fig) && ishghandle(Fig) && strcmpi(get(Fig, 'type'), 'figure');

end % end of function 'isfig'