function closewb
% closewb closes all waitbars
    % ---------------------------------------------------------------------
    %
    %                           closewb
    %
    % ---------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/closewb.m $
    %
    % ---------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % closewb
    %
    % DESCRIPTION
    % -----------
    % closewb closes all waitbars created using waitbar
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2014
    % =====================================================================

    % INITIALISATION
    % --------------
    
     % check number of input and output arguments
    if nargin > 0 || nargout > 0
        % use chknarg to generate error
        chknarg(nargin, 0, nargout, 0, mfilename);
        
    end
        
    
    % EXECUTION
    % ---------
    
    % waitbars can be identified as figures with the tag 'TMWWaitbar'
    
    % find waitbars and close them
    close(findobj(allchild(0), 'flat', 'tag', 'TMWWaitbar', '-and', 'type', 'figure'))
    
end % end of function 'closewb'