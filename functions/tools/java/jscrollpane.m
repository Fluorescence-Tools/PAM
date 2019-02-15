function [innerpanel, parent, jscrollpane, JSCROLL] = jscrollpane(varargin)
% jscrollpane creates an interactive scrollpane holding a uipanel keeping its full functionality
    % ----------------------------------------------------------------------------------------------
    %
    %                                      jscrollpane
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/java/jscrollpane.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % [innerpanel, parent, jscrollpane] = jscrollpane
    % [innerpanel, parent, jscrollpane] = jscrollpane(parent)
    % [innerpanel, parent, jscrollpane] = jscrollpane(..., 'parameter', 'parameter value')
    % [innerpanel, parent, jscrollpane, JSCROLL] = ...
    % 
    % DESCRIPTION
    % -----------
    % [innerpanel, parent, jscrollpane] = jscrollpane creates an interactive scrollpane in the
    % current figure holding a uipanel remaining full functionality, although its real parent is a
    % javacomponent. innerpanel is the graphics handle to the uipanel within the scrollpane, while
    % parent is the graphics handle of the uipanel that holds the scrollpane. jscrollpane is the
    % javawrapper of the JScrollPane.
    %
    % [innerpanel, parent, jscrollpane] = jscrollpane(parent) creates the scrollpane in the defined
    % parent. parent has to be a graphics handle.
    % 
    % [innerpanel, parent, jscrollpane] = jscrollpane(..., 'parameter', 'parameter value') allows
    % the user to set optional parameters. These parameters are:
    %   parent          graphics handle     The parent that will hold the splitpane.
    %   wrapper     	{true}/false        When true, the jscrollpane is constructed in a new
    %                                       uipanel. Otherwise, it is constructed directly in the
    %                                       parent (false).
    %   minimumsize     [5 5]               minimum size (width and height) of the innerpanel (in
    %                                       cm). When its size gets smaller, scrollbars will appear.
    % 
    % [innerpanel, parent, jscrollpane, JSLID] = ... returns the handled java handle of the
    % JScrollPane as fourth optional output argument.
    % 
    % TODO
    % ----
    %   * store real java handle in handled java-matlab handle.
    % 
    % Copyright 2014
    % ==============================================================================================
    
   
    % INITIALIZATION
    % --------------
    
    % check number of input and output arguments
    if nargin > 7 || nargout > 4
        % use chknarg to generate error
        chknarg(nargin, [0 7], nargout, [0 4], mfilename);
    else
        opts = parseipt(varargin{:});
    end
    
    
    % EXECUTION
    % ---------
    
    if isempty(opts.parent)
        % no parent defined. Use the current figure
        opts.parent = gcf;
    end
    
    if opts.wrapper
        % create a uipanel to hold the scroll panel
        opts.parent = uipanel('parent', opts.parent, 'bordertype', 'none');
        % get the java handle of the parent
        jparent = uipanel2java(opts.parent);
    else
        % get the java handle of the parent
        switch lower(opts.parent.Type)
            case 'figure'
                jparent = figure2java(opts.parent);
            case 'uipanel'
                jparent = uipanel2java(opts.parent);
            case 'uitab'
                jparent = uitab2java(opts.parent);
            otherwise
                errorbox(['The graphics type ''' opts.parent.Type ''' is unsupported.'], 'Unsupported graphics type.', [mfilename 'UnsupportedGraphType']);
        end
    end
    
    % create a uipanel to represent the 'inner' scrollable uipanel
    innerpanel = uipanel('parent', opts.parent, 'bordertype', 'none');
    % make the panel a bit smaller to cope with the scroll bars.
    innerpanel.Units 	= 'centimeters';
    innerpanel.Position = chkpos(innerpanel.Position-[0 0 0.7 0.7]);
    innerpanel.Units    = 'pixels';
    
    % get the java handle of the innerpanel
    jinnerpanel = uipanel2java(innerpanel);
    
    % update the graphics to be able to find all java stuff
    drawnow();
    
    % place the component in the figure using a javawrapper
    jscroll = javaObjectEDT('javax.swing.JScrollPane', jinnerpanel{1});
    [JSCROLL, jscrollpane] = javacomponent(jscroll, [0 0 200 200], opts.parent);
    jparent{end}.add(JSCROLL);
    % make the panel visible
    jscroll.setVisible(true);
    
    % set the layout of the tabpanel
	jparent{end}.setLayout(javaObjectEDT('java.awt.GridLayout'));
    
    % set the minimum size of the innerpanel
    innerpanel.addprop('MinimumSize');
    innerpanel.MinimumSize = cm2pixels(opts.minimumsize);
  	
    % set the resize callback to update the size of the innerpanel
    set(JSCROLL, 'ComponentResizedCallback',  @(~,~) adjustpanel(innerpanel, jscroll, jscroll.getViewport))
    
    % update the panel
    JSCROLL.ComponentResizedCallback();
    drawnow();
    
    parent = opts.parent;
    
end % end of function 'jscrollpane'


%% -------------------------------------------------------------------------------------------------
function opts = parseipt(varargin)
    % parseipt parses the input arguments of the main function
    
    opts.parent      =    []; % the handle of the parent that will hold the jscrollpanel
    opts.wrapper     =  true; % construct the jscrollpanel in a new uipanel (true) or directly in the parent (false)
    opts.minimumsize = [10 10]; % minimum size (width and height) of the innerpanel (in cm).
    
    % create temporary cell array to store graphics handles
    temp = {};
    % initialise the counter for the while loop
    cntr = 0;
    V    = length(varargin);
    while cntr < V
        % increase the counter
        cntr = cntr + 1;
        
        if isgraphics(varargin{cntr})
            % the input argument is a graphics handle
            temp{cntr} = varargin{cntr}; %#ok<AGROW>
        else
            % the input is not a graphics handle. Stop the while loop.
            break
        end
    end
    varargin(1:numel(temp)) = [];
    
    if isempty(temp)
        % no graphics handle defined. Just proceed
    elseif numel(temp) == 1
        % only one handle defined. This has to be the parent.
        opts.parent = temp{1};
    else
        % more than 1 graphics handle defined. This is not allowed.
        errorbox('There is more than one graphics handle defined. This is not allowed.', 'Too many graphics handles', [mfilename ':2ManyGraphics']);
    end
    
    % initialise the counter for the while loop
    cntr = 0;
    V    = length(varargin);
    while cntr < V
        % increase the counter
        cntr = cntr + 1;
        
        switch lower(varargin{cntr})
            case {'parent' 'paren', 'pare' 'par'}
                if ~(isgraphics(varargin{cntr+1}) && isfigorpanel(varargin{cntr+1}) && strcmpi(varargin{cntr+1}.Type, 'uitab'))
                    % bad parent handle
                    errorbox('The specified parent is not appropriate.', 'Bad parent', [mfilename ':BadParent']);
                else
                    opts.parent = varargin{cntr+1};
                    cntr = cntr + 1;
                end
            case 'wrapper'
                if ~istforonoff(varargin{cntr+1})
                    errorbox('The option ''wrapper'' has to be ''on'' or ''off''.', 'Bad wrapper option', [mfilename ':BadWrapper']);
                else
                    opts.wrapper = tforonoff2tf(varargin{cntr+1});
                end
            case {'minimumsize' 'minimum size', 'minsize', 'min size'}
                if numel(varargin{cntr+1}) > 2 || isempty(varargin{cntr+1})
                    errorbox('The option ''minimumsize'' has to be a valid numeric two-element vector.', 'Bad minimum size option', [mfilename ':BadMinSize']);
                else
                    opts.minimumsize = duplicatescalar(varargin{cntr+1});
                end
            otherwise
                % invalid parameter
                errorbox(['Parameter ''' lower(varargin{cntr}) ''' is invalid.'], 'Invalid optional parameter', [mfilename 'InvalidOptionalIpt']);
        end
        
    end
    
end % end of subfunction 'parseipt'


%% -------------------------------------------------------------------------------------------------
function adjustpanel(panel, jscroll, jscroll_viewport)
    % adjustpanels updates the position of the internal uipanel via its handle such that the axes
    % are properly positioned. This makes the MinimumSize, PreferedSize and MaximumSize obsolete.
    
    if ~isgraphics(panel)
        % the panels don't exist. Stop this resize function.
        return
    else
        % get the height an width of the viewport. Not that these dimensions are in pixels, with the
        % offset in the top left corner.
        w = jscroll_viewport.getWidth;
        h = jscroll_viewport.getHeight;
        
        % determine the requested position of the panel
        [pos] = max([w h], panel.MinimumSize);
        
%         ix
        
        if any(isnan(pos))
            % there is something wrong with the positions. Stop the resize function.
            return
        elseif pos(1) > w
            if jscroll.getHorizontalScrollBarPolicy ~= jscroll.HORIZONTAL_SCROLLBAR_AS_NEEDED
                jscroll.setHorizontalScrollBarPolicy(jscroll.HORIZONTAL_SCROLLBAR_AS_NEEDED)
            end
        else
            if jscroll.getHorizontalScrollBarPolicy ~= jscroll.HORIZONTAL_SCROLLBAR_NEVER
                jscroll.setHorizontalScrollBarPolicy(jscroll.HORIZONTAL_SCROLLBAR_NEVER)
            end
        end
        
        if pos(2) > h
            if jscroll.getVerticalScrollBarPolicy ~= jscroll.VERTICAL_SCROLLBAR_AS_NEEDED
                jscroll.setVerticalScrollBarPolicy(jscroll.VERTICAL_SCROLLBAR_AS_NEEDED)
            end
        else
            if jscroll.getVerticalScrollBarPolicy ~= jscroll.VERTICAL_SCROLLBAR_NEVER
                jscroll.setVerticalScrollBarPolicy(jscroll.VERTICAL_SCROLLBAR_NEVER)
            end
        end
            
    end
    
    % set the position
    panel.Position = chkpos([panel.Position(1:2) pos] + [0 jscroll.getHorizontalScrollBar.isVisible.*jscroll.getHorizontalScrollBar.getHeight 0 0]);
    
end % end of subfunction 'adjustpanels'