function tf = isunit(Unit)
% isunit returns true if the argument is a valid unit for graphical objects
    % ----------------------------------------------------------------------------------------------
    %
    %                                         isunit
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/isunit.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf = isunit('Unit')
    %
    % DESCRIPTION
    % -----------
    % tf = isunit('Unit') returns true if the argument is a valid MATLAB unit. Possible values are
    % 'centimeters', 'pixels', 'normalized', 'inches', 'points', and 'characters'.
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
    
    tf = ischar(Unit) && any(strcmpi(Unit, {'centimeters', 'pixels', 'normalized', 'inches', 'points', 'characters'}));

end % end of function 'isunit'