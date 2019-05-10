function h_wb = javabar(x, varargin)
% javabar creates a java-based waitbar
    % ----------------------------------------------------------------------------------------------
    %
    %                                        javabar
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/javabar.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % h_wb = javabar(x)
    % h_wb = javabar(x, h_wb)
    % h_wb = javabar(..., 'parameter', 'parameter value')
    % 
    % DESCRIPTION
    % -----------
    % h_wb = javabar(x) creates a java-based waitbar of fractional length x. The handle of the java
    % waitbar is returned in h_wb. When x is set to empty, a scolling waitbar will be shown.
    % 
    % h_wb = javabar(x, h_wb) updates the java waitbar defined by handle h_wb to fractional length
    % x.
    % 
    % h_wb = javabar(..., 'parameter', 'parameter value') allows the user to set extra optional
    % parameters. These parameters are:
    %   * showstr   true/{false}    Show fractional length in percent
    %   * color     [r g b]         Determines the color of the waitbar. This option only works when
    %                               showstr is set to true.
    %   * msg       string          Message shown in the bar. showstr is always set to true in this case.
    %   * any valid uicontrol options like units, position, etc.
    % 
    % NOTES
    % -----
    % When java is not supported, a simple waitbar is created instead. This waitbar resembles the
    % actions of the javawaitbar as much as possible.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================

    % INITIALISATION
    % --------------
    
    % set default values
    h_wb      = [];    % the handle of the waitbar
    showstr   = false; % show current progress in %
    color     = [];    % default color will be used
    extraipt  = {};    % list of extra input arguments
    msg       = '';    % message shown in the bar
    
    % check number of input and output arguments
    if nargin < 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
    
        % Parse input arguments
    elseif ~isscalar(x) && ~isempty(x)
        % the first input argument should be a scalar holding the
        % fractional length of the waitbar, or it can be empty.
        errorbar('The first input argument should be a scalar holding the fractional length of the waitbar, or it can be empty.', 'Bad fractional length', 'id', [mfilename ':Badx']);
    elseif nargin > 1
        % more than one input argument specified
        
        if ~mod(nargin,2)
            % a handle should be specified as second input argument
            if ~ishandle(varargin{1})
                errorbox('The second input argument should be valid handle', 'Bad handle', 'id', [mfilename ':BadHandle'])
            else
                h_wb = varargin{1};
                varargin(1) = [];
            end
        end
        
        for m = 1 : 2: length(varargin)
            switch lower(varargin{m})
                case 'showstr'
                    if ~istf(varargin{m+1})
                        errorbox(sprintf('The option ''showstr'' has to be a logical value.'), 'Bad showstr option', 'id', [mfilename ':BadShowstr']);
                    else
                        showstr = varargin{m+1};
                    end
                case 'msg'
                    if ~ischar(varargin{m+1})
                        errorbox(sprintf('The option ''msg'' has to be a valid character string.'), 'Bad msg option', 'id', [mfilename ':BadMsg']);
                    else
                        msg     = varargin{m+1};
                        showstr = true;
                    end
                case 'color'
                    if ~(numel(varargin{m+1}) == 3 && all(isbetween(color, [0 1])))
                        errorbox(sprintf('The option ''color'' has to be a valid color definition.'), 'Bad color option', 'id', [mfilename ':BadColor']);
                    else
                        color = varargin{m+1};
                    end
                otherwise
                    extraipt(size(extraipt,2)+1:size(extraipt,2)+2) = varargin(m:m+1);
            end
        end
    end
    
    
    % EXECUTION
    % ---------
    
    if ~usejavacomponent
        % java is not supported on this platform
        
        % this is a back-up plan to prevent the code from stopping. Inform
        % the user about this event
        warning('javabar:nojava', 'Java can not be used. A back-up procedure is used.\nClick <a href="matlab:warning(''off'',''javabar:nojava'');">here</a> to hide this warning in the future')
        
        % make sure x is a non-empty value between 0 and 100
        if isempty(x),x=0;else x = max(min(x,1),0)*100;end;
        
        
        if isempty(h_wb)
            % create a simple waitbar, similar to the matlab built-in waitbar
            
            % get the parent
            [wb_parent, extraipt] = fndparent(extraipt);
            
            % get the position of the waitbar
            [wb_pos, ~] = fndposition(extraipt, wb_parent);
            
            % make sure a color is specified. If not, replace by a default
            % color
            if isempty(color)
                color = [1 0 0];
            end
            
            % create the axes
            h_wb = axes('Parent',wb_parent, ...
                        'XLim',[0 100],...
                        'YLim',[0 1],...
                        'Box','on', ...
                        'Units','centimeters',...
                        'Position',wb_pos,...
                        'XTickMode','manual',...
                        'YTickMode','manual',...
                        'XTick',[],...
                        'YTick',[],...
                        'XTickLabelMode','manual',...
                        'XTickLabel',[],...
                        'YTickLabelMode','manual',...
                        'YTickLabel',[],...
                        'Visible', 'off');

            % Use the patch implementation
            xpatch = [0 x x 0];
            ypatch = [0 0 1 1];
            xline = [100 0 0 100 100];
            yline = [0 0 1 1 0];
            patch(xpatch,ypatch,color, 'Parent', h_wb, 'EdgeColor',color,'EraseMode','none');
            l = line(xline,yline,'EraseMode','none');
            set(l,'Color',get(h_wb,'XColor'));
            
            % put the title in the axes
            set(get(h_wb,'title'), 'position', [50 0, 1],...
                                   'String',     msg,...
                                   'Visible',    'on');
            
            % show the waitbar
            set(h_wb, 'Visible', 'on');
            
        else
            % a handle of a waitbar is given
            
            if isempty(findobj(h_wb, 'flat', 'type', 'axes'))
                % the handle is not a valid waitbar
                errorbox('The specified handle does not refer to a valid waitbar.', 'Bad handle', 'id', [mfilename ':BadHandle']);
            end
            
            % set the patch Xdata to the new value
            set(findobj(h_wb, 'type', 'patch'), 'Xdata', [0 x x 0])
            
            if nargin > 2
                set(get(h_wb,'title'), 'String', msg)
            end            
            
        end
        % stop the function from executing the rest of this file
        return
        
    elseif isempty(h_wb)
        % no handle given. Create a new bar
        
        % invoke the jave object constructor
        jw = javaObjectEDT('javax.swing.JProgressBar');
        
        % get the parent
        [wb_parent, extraipt] = fndparent(extraipt);
        
        % get the position of the waitbar
        [wb_pos, extraipt] = fndposition(extraipt, wb_parent);
        
        % create the waitbar
        [jw h_wb] = javacomponent(jw, wb_pos, wb_parent);
        
        % adjust the value of the waitbar
        if isempty(x)
            % no value specified
            jw.setIndeterminate(true);
        else
            jw.setIndeterminate(false);
            % update the bar length
            jw.setValue(x*100);
        end
        
        % show progress in waitbar as string?
        jw.setStringPainted(showstr);
        
        if jw.isStringPainted
            % adjust color if requested
            if ~isempty(color)
                jw.setForeground(java.awt.Color(color(1), color(2), color(3)));
            end
            
            % show message string
            jw.setString(msg);
        end
        
        % get the available position
        if ~(~isempty(extraipt) && any(strcmpi(extraipt, 'position')))
            % no position defined. Just use default position
            axNorm=[.05 .3 .9 .2]; % optimal normalized position

            % get the available space in the parent
            [w h] = getspace(wb_parent', 'centimeters');

            % calculate the default position
            wb_pos = [w*axNorm(1) h*axNorm(2) min(w*axNorm(3), 8.57) min(h*axNorm(3), 0.45)];
            
            % set the new position
            set(h_wb, 'units', 'centimeters', 'position', wb_pos);
        end
        
        % set optional properties of the javacontainer
        extraipt = [{'units', 'centimeters'} extraipt];
        set(h_wb, extraipt{:});
        
    else
        % update the existing bar
        
        if isempty(findobj(h_wb, 'flat', 'type', 'hgjavacomponent'))
            % the handle is not a valid waitbar
            errorbox('The specified handle does not refer to a valid waitbar.', 'Bad handle', 'id', [mfilename ':BadHandle']);
        else
            jw= get(h_wb, 'JavaPeer');
        end
        
        % update the value of the waitbar
        if isempty(x)
            % no value specified
            jw.setIndeterminate(true);
        else
            jw.setIndeterminate(false);
            % update the bar length
            jw.setValue(max(min(x,1),0)*100);
        end
        
        if nargin > 2 && jw.isStringPainted
            % update message string
            jw.setString(msg);            
        end
        
        % stop the function
        return
    end
    
end % end of function 'javabar'
% =========================================================================

%  SUBFUNCTIONS
%  ------------
%   * full_lags
%   * qlags

% -------------------------------------------------------------------------
function [wb_pos, extraipt] = fndposition(extraipt, wb_parent)
    % fndposition searches for a position input amongst the extra input
    % arguments
    
    if ~isempty(extraipt) && any(strcmpi(extraipt, 'position'))
        % the user inserted a position
        
        % get the indices of the word position and the position vector
        position_ix = find(strcmpi(extraipt, 'position'), 1, 'first');
        position_vec_ix = position_ix + 1;
        
        % save the position vector in new variable
        wb_pos = extraipt{position_vec_ix};
        
        % remove the items from the extra input arguments list
        extraipt([position_ix position_vec_ix]) = [];
        
    else
        % no position specified. Create a default position vector
        
        axNorm=[.05 .3 .9 .2]; % optimal normalized position
        
        % get the available space in the parent
        [w h] = getspace(wb_parent', 'centimeters');
      	
        % calculate the default position
        wb_pos = [w*axNorm(1) h*axNorm(2) min(w*axNorm(3), 8.57) min(h*axNorm(3), 0.45)];
       	
    end

end % end of subfunction 'fndposition'

% -------------------------------------------------------------------------
function [wb_parent, extraipt] = fndparent(extraipt)
    % fndparent searches for a parent input amongst the extra input
    % arguments
    
    if ~isempty(extraipt) && any(strcmpi(extraipt, 'parent'))
        % the user inserted a parent
        
        % get the indices of the word parent and its concommitant handle
        parent_ix = find(strcmpi(extraipt, 'parent'), 1, 'first');
        parent_handle_ix = parent_ix + 1;
        
        wb_parent = extraipt{parent_handle_ix};
        
        if isempty(wb_parent) || ~ishandle(wb_parent)
            % the specified parent does not exist
            errorbox('The handle to the parent is invalid.', 'Invalid parent', 'id', [mfilename ':InvalidParent']);
        end
        
        % remove the items from the extra input arguments list
        extraipt([parent_ix parent_handle_ix]) = [];
        
    else
        % no parent specified. Create a new, simple parent
        
        % determine the dimensions of the parent in cm (based on size of
        % the matlab default waitbar
        w = points2cm(270);     % preferred width
        h = points2cm(56.25);   % preferred height
        
        % create the parent
        wb_parent = newfig('position', [0 0 w h],...
                           'visible', 'off',...
                           'resize', 'off');
        % move the parent to the upper left corner
        movegui(wb_parent, 'northwest');
        
        % show the parent
        set(wb_parent, 'visible', 'on');
    end
    
end % end of subfunction 'fndparent'