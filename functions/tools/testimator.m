function t = testimator(varargin)
% testimator keeps track of the elapsed time and estimates the time left
    % ----------------------------------------------------------------------------------------------
    %
    %                                         testimator
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/testimator.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % time_log = testimator(total_steps)
    % time_log = testimator(time_log, processed_steps)
    % 
    % DESCRIPTION
    % -----------
    % time_log = testimator(total_steps) creates a new time_log structure. Total_steps is a scalar
    % defining the number of total steps. This structure keeps track of the time since the creation
    % of this new structure.
    % 
    % time_log = testimator(time_log, processed_steps) uses a previously created or updated time_log
    % structure and the given number of processed steps since the creation of the time_log
    % structure. It returns an updated time_log structure.
    % 
    % REMARKS
    % -------
    % A time_log structure holds the following fields:
    %   * start     integer number returned by the function tic the first time the time_log
    %               structure is created
    %   * etl       estimated time left (s). Empty when no appropriate information is available
    %   * te        time elapsed since creation of the structure
    %   * events    a matrix storing a row for each call the number of processed steps since the
    %               last call, the elapsed time since the last call and the time (in s) per step
    %               since the last call.
    %   * total     total number of steps
    %   * ratio     ratio of processed steps to the number of total steps. This can directly be used
    %               as value for the waitbar.
    %   * txt       string showing the time that is left
    % 
    % Copyright 2010-2017
    % ==============================================================================================
    
    % INITIALIZATION
    % --------------
    
    % check number of input and output arguments
    if nargin < 1 || nargin > 2 || nargout > 1
        % use chknarg to throw error when these numbers are invalid
        chknarg(nargin, [1 2], nargout, [0 1], mfilename);
    
    
    % EXECUTION
    % ---------
    
    elseif nargin == 1
        % only one input argument. A new time_log structure needs to be
        % created.
        
        % Make sture the unique input argument is a positive scalar
        if ~isscalar(varargin{1}) || varargin{1} < 1
            errorbox('The input argument defining the total number of steps has to be a positive scalar.', 'Bad total steps', 'id', [mfilename ':BadNTotSteps']);
        end
                
        % create a new time_log structure
        
        % save current time
        t.start  = tic;
        t.etl    = [];
        t.te     = [];
        t.events = [];
        t.total  = varargin{1};
        t.ratio  = [];
        t.txt    = '';
        
        % return this matrix and stop the function
        return
        
    else
        % there are two input arguments. The time_log structure needs to be
        % updated.
        
        % Make sure the input arguments are correct.
        if ~isstruct(varargin{1})
            errorbox('The first input argument has to be a time_log structure.', 'Bad time_log structure', 'id', [mfilename ':BadTimelogStruc']);
        elseif ~isscalar(varargin{2}) || varargin{2} < 0
            errorboxt('The second input argument defining the processed number of steps has to be a positive scalar or zero.', 'Bad N Processed steps', 'id', [mfilename ':BadNProcessedSteps']);
        end
        
        % save time_log structure to output variable
        t = varargin{1};
        
        % When no steps are processed, return 
        if varargin{2} == 0, return; end
        
        % get the current time
        t.te = toc(t.start);
        
        % calculate the processed ratio
        t.ratio = varargin{2}/t.total;
        
        % save current event to event matrix
        if isempty(t.events)
            t.events = [varargin{2} t.te t.te/varargin{2}];
        else
            t.events(end+1,1:2) = [varargin{2}-t.events(end,1) t.te-t.events(end,2)];
            t.events(end,3) = t.events(end,2)/t.events(end,1);
        end
        
        % calculate the estimated time left. Average over the last three
        % steps
        ix = max(1, size(t.events,1)-2);
                
        t.etl = (t.total-varargin{2})*mean(t.events(ix:end,3));
        
        % create string showing the estimated time left
        if isempty(t.etl)
            t.txt = '';
        else
            
            txt = '';
            % convert time to hours, minutes and seconds
            if t.etl > 3600
                H = floor(t.etl/3600);
                t.etl = t.etl - H*3600;
                txt = sprintf('%1.0f h ', H);
            end
            
            if t.etl > 60
                Min = floor(t.etl/60);
                t.etl = t.etl - Min*60;
                txt = [txt sprintf('%1.0f min ', Min)];
            end
            
            txt = [txt sprintf('%1.0f s', t.etl)];
            t.txt = sprintf(' (%s left)', txt);
        end
        
    end
    
end % end of function 'testimator'