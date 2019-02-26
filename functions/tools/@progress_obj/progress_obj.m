classdef progress_obj < handle
% progress_obj is an object that provides an easy-to-use interface for multiple waitbars
    % ----------------------------------------------------------------------------------------------
    %
    %                                       progress_obj
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/@progress_obj/progress_obj.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % wb = progress_obj
    % 
    % DESCRIPTION
    % -----------
    % wb = progress_obj creates a new waitbar
    % 
    % 
    % copyright 2017
    % ==============================================================================================
    
    
    % NOTES
    % -----
    %  * when no parent is defined, a dedicated figure will be created. This figure has 
    %    'handlevisibility' set to 'off' and its 'tag' has the format 'PROGRESS_BAR_x' where x is
    %    one or multiple digits.
    %  * Each figure holding a waitbar should have the field 'progress_obj', holding one or multiple
    %    progress_obj objects.
    
    
    properties (SetObservable)
        parent              % the handle of the parent holding the waitbar. This can be a figure or 
                            % uipanel. If mode is set to 'statusbar', the waitbar will be created at
                            % the bottom of the figure using java. Otherwise, a waitbar will be
                            % shown in the figure or uipanel.
        mode@char = 'waitbar';  % The mode of the waitbar: 'waitbar' or 'statusbar'. waitbar resembles
                                % matlab's waitbar, except that it can be a child of a uipanel.
        combine_bars = true;    % when set to true, several bars will be shown in a single frame, either a
                                % figure or a uipanel.
        reduce_calls = true;    % when set to true, the number of calls will be reduced by keeping track 
                                % of elapsed time since the previous call.
        min_elapsed_time@double scalar = 0.2; % set the minimum time that should have elapsed since the 
                                              % last call (in seconds) before the waitbar is updated.
        fraction = 0;  % the fraction of the waitbar that has to be filled, between 0 and 1, or empty ([]).
        message = '';  % the text message shown along the bar
        message_in_bar = false; % display the message inside the waitbar. Works only with javabar
%         icon
%         level = 1
        
        show_cancel_btn@logical scalar = true; % when set to true, a cancel button will be shown for interactive stop of execution.
        
        % size_fig   % size of the figure holding the waitbar
    end
    
    properties (Dependent)
        isvalid     % returns true when the waitbar exists and the user did not choose to cancel the
                    % action
    end
    
    properties (Dependent, Hidden)
        parent_javahandle % returns the java handle of the parent, as a column cell array of handles
                          % in descending order of parents
    end
    
    properties (Hidden)
        time_last_call % This field is used to keep track of the time of the previous call.
        waitbar_type = 'java'; % the waitbar_type can be either 'java' or 'axes'. 
        stop@logical scalar = false; % when set to true, the user wants to stop the action that is being executed
        waitbar_location = 'northwest'; % controls the location of the waitbar, when mode is set to 'waitbar'.
                                        % 'north'	Top center edge of screen
                                        % 'south'	Bottom center edge of screen
                                        % 'east'	Right center edge of screen
                                        % 'west'	Left center edge of screen
                                        % 'northeast'	Top right corner of screen
                                        % 'northwest'	Top left corner of screen
                                        % 'southeast'	Bottom right corner of screen
                                        % 'southwest'	Bottom left corner
                                        % 'center'	Centered on screen
                                        % 'onscreen'	Nearest location to current location that is entirely on screen
       progressbar    % The handle to the actual waitbar. This can be a matlab handle or a java JProgressbar.
       cancel_btn     % the handle to the cancel button.
       message_text  % the handle to the cancel button.
    end
    
    
    methods
        
        function obj = progress_obj(varargin)
            
            if nargin == 1 && isa(varargin{1}, 'progress_obj')
                obj = varargin{1};
                
            else
                % parse input arguments
                obj.parse_ipt(varargin{:});
            end
            
            % initialize the progress bar.
            obj.init;
            
        end % end of constructor method 'progress_obj'
        
        
        %% -----------------------------------------------------------------------------------------
        function tf = get.isvalid(obj)
            % isvalid returns true when the waitbar exists and the user did not choose to cancel the
            % action
            
            tf = ~(obj.stop || isempty(obj.parent) || ~obj.parent.isvalid);
            
        end % end of subfunction 'get.isvalid'
        
        
        %% -----------------------------------------------------------------------------------------
        function j_parent = get.parent_javahandle(obj)
            % parent_javahandle returns the java handle of the parent, as a column cell array of
            % handles in descending order of parents.
            
            if obj.isvalid
                if isfig(obj.parent)
                    j_parent = figure2java(obj.parent);
                else
                    j_parent = uipanel2java(obj.parent);
                end
            else
                % no valid parent
                j_parent = [];
            end
            
        end % end of subfunction 'get.parent_javahandle'
        
        
    end
    
    methods (Hidden)
        
        %% -----------------------------------------------------------------------------------------
        function tf = logical(obj)
            % returns the isvalid value when the object is cast into a logical value.
            
            tf = obj.isvalid;
            
        end % end of subfunction 'logical'
        
        
        %% -----------------------------------------------------------------------------------------
        function tf = not(obj)
            % returns the opposite of the isvalid value. In this way, the object works with the
            % tilde operator.
            
            tf = ~obj.isvalid;
            
        end % end of subfunction 'not'
        
        
        %% -----------------------------------------------------------------------------------------
        function obj = halt(obj)
            % indicates that the update of the object has ended
            
            obj.stop = true;
            
        end % end of subfunction 'halt'
        
        
        %% -----------------------------------------------------------------------------------------
        function obj = parse_ipt(obj, varargin)
            % parsing the input arguments and returning a structure with fixed fields
            
            % set default values
            fraction_set = false;
            message_set  = false;
            
            if isempty(varargin)
                % no special action required
                return
                
            else
                c = 1;
                if isstruct(varargin{c})
                    % do nothing
                elseif isnumeric(varargin{c}) && (isempty(varargin{c}) || isscalar(varargin{c}))
                    % first input argument is a fraction
                    if isempty(varargin{c})
                        % no fraction defined. Set the bar to indeterminate
                        obj.fraction = [];
                        fraction_set = true;
                    else
                        % fraction defined
                        obj.fraction = max(0, min(varargin{c},1));
                        fraction_set = true;
                    end
                elseif ischar(varargin{c})
                    % a message is defined
                    obj.message = varargin{c};
                    message_set = true;
                else
                    c = c-1;
                end
                
                if c < length(varargin)
                    c = c + 1;
                    if ~fraction_set && isnumeric(varargin{c}) && (isempty(varargin{c}) || isscalar(varargin{c}))
                        % first input argument is a fraction
                        if isempty(varargin{c})
                            % no fraction defined. Set the bar to indeterminate
                            obj.fraction = [];
                        else
                            % fraction defined
                            obj.fraction = max(0, min(varargin{c},1));
                        end
                    elseif ~message_set && ischar(varargin{c}) && ~isprop(obj, varargin{c}) && ~strcmp(varargin{c}, '-force_update')
                        % a message is defined
                        obj.message = varargin{c};
                    else
                        c = c-1;
                    end
                end
                    
                L = length(varargin); % total number of input arguments
                while c < L
                    % increase the counter
                    c = c + 1;
                    
                    if isstruct(varargin{c})
                        % convert structure to cell array as it were individual input arguments.
                        temp = struct2cellwfieldnames(varargin{c});
                        varargin = [varargin(1:(c-1)) temp varargin((c+1):end)];
                        c    = c - 1;            % reset the counter
                        L    = length(varargin); % reset the total number of input arguments
                        continue
                    end
                    
                    % parse through all remaining parameter - parameter value pairs
                    switch lower(varargin{c})
                        case 'mode'
                            if ~any(strcmpi(varargin{c+1}, {'waitbar', 'statusbar'}))
                                errorbox('The option ''mode'' has to be either ''waitbar'' or ''statusbar''.', 'Bad ''mode'' option', [mfilename ':BadModeIpt']);
                            else
                                obj.mode = lower(varargin{c+1});
                                c = c + 1;
                            end
                            
                        case 'combine_bars'
                            if ~istforonoff(varargin{c+1})
                                errorbox('The option ''combine_bars'' should be a logical scalar or ''on''/''off''.', 'Bad ''combine_bars'' option', [mfilename ':BadComBarsIpt']);
                            else
                                % convert to a logical
                                obj.combine_bars = tforonoff2tf(varargin{c+1});
                                c = c + 1; % increase the counter
                            end
                            
                        case 'reduce_calls'
                            if ~istforonoff(varargin{c+1})
                                errorbox('The option ''reduce_calls'' should be a logical scalar or ''on''/''off''.', 'Bad ''reduce_calls'' option', [mfilename ':BadRedCallsIpt']);
                            else
                                % convert to a logical
                                obj.reduce_calls = tforonoff2tf(varargin{c+1});
                                c = c + 1; % increase the counter
                            end
                            
                        case 'message_in_bar'
                            if ~istforonoff(varargin{c+1})
                                errorbox('The option ''message_in_bar'' should be a logical scalar or ''on''/''off''.', 'Bad ''message_in_bar'' option', [mfilename ':BadMsgInBarIpt']);
                            else
                                % convert to a logical
                                obj.message_in_bar = tforonoff2tf(varargin{c+1});
                                c = c + 1; % increase the counter
                            end
                            
                        case 'show_cancel_btn'
                            if ~istforonoff(varargin{c+1})
                                errorbox('The option ''show_cancel_btn'' should be a logical scalar or ''on''/''off''.', 'Bad ''message_in_bar'' option', [mfilename ':BadShowCnclBtnIpt']);
                            else
                                % convert to a logical
                                obj.show_cancel_btn = tforonoff2tf(varargin{c+1});
                                c = c + 1; % increase the counter
                            end
                            
                        case 'waitbar_location'
                            if ~any(strcmpi(varargin{c+1}, {'north' 'south'	'east' 'west' 'northeast' 'northwest' 'southeast' 'southwest' 'center' 'onscreen'}))
                                errorbox('The option ''waitbar_location'' has to be a valid location.', 'Bad ''waitbar_location'' option', [mfilename ':BadWbLocIpt']);
                            else
                                obj.waitbar_location = lower(varargin{c+1});
                                c = c + 1;
                            end
                            
                        case 'min_elapsed_time'
                            if ~isscalar(varargin{c+1})
                                errorbox('The option ''reduce_calls'' should be a valid scalar', 'Bad ''min_elapsed_time'' option', [mfilename ':BadMinElapsedTIpt']);
                            else
                                % convert to a logical
                                obj.min_elapsed_time = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
                            
                        otherwise
                            % parameter not recognized
                            errorbox(['The parameter ''' varargin{c} ''' is not supported by ' mfilename '.'], 'Optional parameter not supported', [mfilename ':BadOptionalIpt']);
                            
                    end
                    
                end % end of while loop
                
            end % end of large if
            
        end % end of method 'parse_ipt'
        
    end
        
    
    methods (Static, Hidden)
        
        
        
        
        %% -----------------------------------------------------------------------------------------
        function [list, serial_number] = get_all_waitbar_figs
            % get_all_waitbar_figs returns a list with the handle of all existing waitbar figures.
            % The second, optional output argument will be a vector holding the serial number of
            % each waitbar figure.
            
            list = findall(0, 'type', 'figure', '-and', 'handlevisibility', 'off', '-and', '-regexp', 'tag', 'PROGRESS_BAR_');
            
            if nargout == 2
                % The optional output is requested.
                if isempty(list)
                    serial_number = [];
                else
                    x = regexp({list.Tag}', 'PROGRESS\_BAR\_(\d*)', 'once', 'tokens');
                    serial_number = str2double([x{:}]');
                end
            end
            
        end % end of subfunction 'get_all_waitbar_figs'
        
        
    end
    
    
end % end of classdefinition of 'progress_obj'