function out = off
% off returns the string 'off'
    % ----------------------------------------------------------------------------------------------
    %
    %                                            off
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/support%20fcns/off.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % out = off
    % 
    % DESCRIPTION
    % -----------
    % out = off returns the string 'off'. This function is created to prevent an error when 'off' is
    % given as an input for a function, but when the user forgot the parentheses.
    % 
    % Copyright 2010-2017
    % ==============================================================================================
    
    
    % INITIALIZATION
    % --------------
    
    % no initialization required
    
	
    % EXECUTION
    % ---------
    
    out = 'off';
    
end % end of function 'off'