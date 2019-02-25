function onoff = tf2onoff(tf)
% tf2onoff returns 'on' or 'off' dependent on the value of logical tf
    % ----------------------------------------------------------------------------------------------
    %
    %                                         tf2onoff
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/support%20fcns/tf2onoff.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % onoff = tf2onoff(tf)
    % 
    % DESCRIPTION
    % -----------
    % onoff = tf2onoff(tf) returns 'on' when tf is true and 'off' when tf is false. tf can be a
    % logical value or 0 or 1.
    % 
    % Copyright 2010-2017
    % ==============================================================================================
    
    
    % INITIALIZATION
    % --------------

    if nargin ~= 1 || nargout > 1
        chknarg(nargin, 1, nargout, [0 1], mfilename);
    end
    
    % EXECUTION
    % ---------
    
    if tf
        onoff = 'on';
    else
        onoff = 'off';
    end

end % end of function 'tf2onoff'