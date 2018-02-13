function obj = update(obj, varargin)
% update updates the fraction of the waitbar and the accompanying message.
    % ----------------------------------------------------------------------------------------------
    %
    %                                           update
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/@progress_obj/update.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % update(obj, fraction)
    % update(obj, message)
    % update(obj, fraction, message)
    % update(..., '-force_update')
    % update(obj)
    % 
    % DESCRIPTION
    % -----------
    % update(obj, fraction) updates the waitbar to match the specified fraction. Fraction has to
    % be a member of the interval [0 1], or an empty numerical matrix ([]). When the property
    % reduce_calls is set to true, the interface is only updated when the time since the last call
    % is larger than the interval specified in the property min_elapsed_time.
    % 
    % update(obj, message) updates the message accompanying the waitbar to match the specified
    % message. Message has to be a valid string.
    % 
    % update(obj, fraction, message) updates both the waitbar and the accompanying text.
    % 
    % update(..., '-force_update') always updates the interface, irrespective of the value stored in
    % the property reduce_calls.
    % 
    % update(obj) updates the complete waitbar interface.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin < 1 || nargin > 4 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [1 4], nargout, [0 1], mfilename);
        
    else
        
        % set default values
        force_update = false;
        msg_set      = false;
        fraction_set = false;
        
        % initialize the counter
        c = 0;
        while c < length(varargin)
            % increase the counter
            c = c + 1;
            
            if isnumeric(varargin{c}) && (isempty(varargin{c}) || isscalar(varargin{c}))
                % this input argument is a fraction
                
                fraction     = varargin{c};
                fraction_set = true;
                
            elseif strcmpi(varargin{c}, '-force_update')
                varargin(strcmpi(varargin, '-force_update')) = [];
                force_update = true;
                
            elseif ischar(varargin{c})
                % a message is defined
                obj.message = varargin{c};
                msg_set = true;
            end
        
        end
    end
    
    
    % EXECUTION
    % ---------
    
    % Make sure the minimum elapsed time is passed.
    if obj.reduce_calls && ~force_update
        % check time since previous call. If this is shorter than the minimum elapsed time, the
        % function will halt and return
        
        if toc(obj.time_last_call) > obj.min_elapsed_time
            % more than the minimum elapsed time is elapsed.
            % update the time of the last call to the current time.
            obj.time_last_call = tic;
        else
            % the minimum elapsed time is not elapsed
            % cancel the update
            return
        end
        
    end
    
    if fraction_set && ~msg_set
        if isempty(fraction)
            % no fraction defined. Set the bar to indeterminate
            if ~isempty(obj.fraction)
                obj.progressbar{1,2}.setIndeterminate(true);
            end
            obj.fraction = fraction;
        else
            if ~isempty(obj.fraction)
                obj.progressbar{1,2}.setIndeterminate(false);
            end
            % fraction defined
            obj.fraction = max(0, min(fraction,1));
            obj.progressbar{1,2}.setValue(obj.fraction*100);
        end
    elseif fraction_set
        % fraction defined
      	obj.fraction = max(0, min(fraction,1));
        obj.progressbar{1,2}.setValue(obj.fraction*100);
    end
    
    if msg_set || (~msg_set && ~fraction_set)
        % perform a general update
        obj.update_and_resize;
    else
        % update the interface without executing callbacks
        drawnow('nocallbacks');
    end
    
end % end of function 'update'