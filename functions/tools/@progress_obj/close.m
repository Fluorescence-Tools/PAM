function close(obj)
% close deletes the waitbar and closes the figure if required
    % ----------------------------------------------------------------------------------------------
    %
    %                                        close
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/@progress_obj/close.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % close(obj)
    % 
    % DESCRIPTION
    % -----------
    % close(obj) deletes the waitbar and closes the figure if required
    %
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % no parsing of input argument required
    
    
    % EXECUTION
    % ---------
    
    if obj.isvalid
        % the figure exists
        
        if isprop(obj.parent, 'progress_obj')
            % remove the object from the list of objects
            obj.parent.progress_obj(obj.parent.progress_obj == obj) = [];
            obj.progressbar  = [];
            obj.cancel_btn   = [];
            obj.message_text = [];
            
        else
            warning(['progress_obj:' mfilename ':NoObjList'], 'No list with progress_obj found in the figure. This is an abnormal situation.')
        end
        
        % update the figure and close if necessary
        obj.update_and_resize;
        
    end


end % end of function 'close'