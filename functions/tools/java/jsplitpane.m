function [panel1, panel2, splitpane, JSLID] = jsplitpane(varargin)
% jsplitpane creates an interactive splitpane holding two uipanels remaining full functionality
    % ----------------------------------------------------------------------------------------------
    %
    %                                      jsplitpane
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/java/jsplitpane.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % [panel1, panel2, splitpane] = jsplitpane
    % [panel1, panel2, splitpane] = jsplitpane(parent)
    % [panel1, panel2, splitpane] = jsplitpane(panel1, panel2)
    % [panel1, panel2, splitpane] = jsplitpane(parent, panel1, panel2)
    % [panel1, panel2, splitpane] = jsplitpane(..., 'parameter', 'parameter value')
    % [panel1, panel2, splitpane, JSLID] = ...
    % 
    % DESCRIPTION
    % -----------
    % [panel1, panel2, splitpane] = jsplitpane creates an interactive splitpane in the current
    % figure holding two uipanels remaining full functionality, although their real parent is a
    % javacomponent. panel1 and panel2 are the graphics handles to the two created uipanels and
    % splitpane is the javawrapper of the JSplitPane.
    %
    % [panel1, panel2, splitpane] = jsplitpane(parent) creates the splitpane in the defined parent.
    % Parent has to be a graphics handle.
    % 
    % [panel1, panel2, splitpane] = jsplitpane(panel1, panel2) uses the two previously defined
    % uipanels panel1 and panel2 as the components for the splitpane.
    % 
    % [panel1, panel2, splitpane] = jsplitpane(parent, panel1, panel2) combines the functionality of
    % the previous two syntaxes. Note that the order of input argument is important.
    % 
    % [panel1, panel2, splitpane] = jsplitpane(..., 'parameter', 'parameter value') allows the user
    % to set optional parameters. These parameters are:
    %   parent          graphics handle     The parent that will hold the splitpane.
    %   panel1          graphics handle     The first panel of the splitpane.
    %   panel2          graphics handle     The second panel of the splitpane.
    %   resizeweight    scalar [0 1]        Fractional covarage of the splitpane by the first panel
    %                                       upon the first visualization. resizeweight has to be a
    %                                       value from the interval [0 1]. The default value is 0.5.
    %   orientation     horizontal/vertical The orientation can be horizontal (the panels appear
    %                                       next to each other), or vertical (the panels appear
    %                                       above and below each other).
    %   continuouslayout {true}/false       Update the content of the panes during interactive
    %                                       modification of the splitpane (true) or not (false).
	%   dividerthickness  positive scalar   The thickness of the divider (in pixels). Default value
	%                                       is 8.
    % 	bordertype      {'none'}/'etched'   The bordertype of the splitpane.
    % 
    % [panel1, panel2, splitpane, JSLID] = ... returns the handled java handle of the JSplitPane as
    % fourth optional output argument.
    % 
    % TODO
    % ----
    %   * prevent changes to position
    % 
    % MODIFICATIONS
    % -------------
    %   * 31-Aug-2015 08:29:18 (Nick)
    %       Real java handle is now stored in handled java-matlab handle in the field 'java_handle'
    % 
    % Copyright 2014-2015
    % ==============================================================================================
    
   
    % INITIALIZATION
    % --------------
    
    % check number of input and output arguments
    if nargin > 19 || nargout > 4
        % use chknarg to generate error
        chknarg(nargin, [0 19], nargout, [0 4], mfilename);
    else
        opts = parseipt(varargin{:});
    end
    
    
    % EXECUTION
    % ---------
    
    if isempty(opts.parent)
        % no parent defined
        % if one of the panels is defined, its parent will be used
        if ~isempty(opts.panel1)
            opts.parent = opts.panel1.Parent;
        elseif ~isempty(opts.panel2)
            opts.parent = opts.panel2.Parent;
        else
            % no handles defined. Just use the current figure
            opts.parent = gcf;
        end
    end
    
    % check the existence of the first panel. If no panel is defined, a new uipanel will be created.
    if isempty(opts.panel1)
        panel1 = uipanel(opts.parent, 'bordertype', 'none');
    else
        panel1 = opts.panel1;
        % make sure that this panel is in the specified panel
        panel1.Parent = opts.parent;
    end
    % get the java handles of the first uipanel
    jpanel1 = uipanel2java(panel1);
    
    % check the existence of the second panel. If no panel is defined, a new uipanel will be created.
    if isempty(opts.panel2)
        panel2 = uipanel(opts.parent, 'bordertype', 'none');
    else
        panel2 = opts.panel2;
        % make sure that this panel is in the specified panel
        panel2.Parent = opts.parent;
    end
    % get the java handles of the first uipanel
    jpanel2 = uipanel2java(panel2);
    
    % update the graphics to get it ready for the java stuff
    drawnow();
    
    % create the java component
    jslid = javaObjectEDT('javax.swing.JSplitPane', opts.orientation, opts.continuouslayout, jpanel1{1}, jpanel2{1});
    
    % set some properties of the splitpane
    jslid.setResizeWeight(opts.resizeweight);
    
    % place the component in the figure using a javawrapper
    [jslid, splitpane] = javacomponent(jslid, [0 0 200 200], opts.parent);
    
    
    % convert the java handle to a matlab-based java handle
    JSLID = handle(jslid, 'callbackproperties');
    
    % set the units and position of the splitpane to fill the parent
    splitpane.Units = 'normalized';
    splitpane.Position = [0 0 1 1];
    
    % store the java handle in a new dynamic property of the splitpane handle
    if ~isprop(splitpane, 'java_handle')
        splitpane.addprop('java_handle'); % create the field
    end
    splitpane.java_handle = JSLID;     % save the icsobj into this field so that it is always available
    
    % react to any change too the splitpane by updating the size of the panels
    set(JSLID, 'PropertyChangeCallback',  @(~,~) copy_javacoords2matlab(JSLID, {panel1 jpanel1{1}; panel2 jpanel2{2}}), 'OneTouchExpandable', true)
    
    % the following rule is obsolete
%     set(JSLID, 'PropertyChangeCallback',  @(~,~) adjustpanels(panel1, panel2, jpanel1{1}, jpanel2{1}, jslid), 'OneTouchExpandable', true)
    
    % set the thickness of the divider bar
    JSLID.setDividerSize(opts.dividerthickness);
    
    % set the border
    if strcmpi(opts.bordertype, 'none')
        bord = javaObjectEDT(javax.swing.BorderFactory.createEmptyBorder);
    else % 'etched'
        bord = javaObjectEDT(javax.swing.BorderFactory.createEtchedBorder);
    end
    jslid.setBorder(bord);
    
    % perform a first update of the panels.
    JSLID.PropertyChangeCallback();
    JSLID.Visible = true;
    
end % end of function 'jsplitpane'


%% -------------------------------------------------------------------------------------------------
function opts = parseipt(varargin)
    % parseipt parses the input arguments of the main function
    
    opts.parent = []; % the handle of the parent that will hold the jsplitpanel
    opts.panel1 = []; % handle to the first panel of the splitpane
    opts.panel2 = []; % handle to the second panel of the splitpane
    opts.resizeweight = 0.5; % fractional covarage of the splitpane by the first panel upon the first visualization. resizeweight has to be a value from the interval [0 1]. 
    opts.orientation = false; % The orientation can be false (horizontal split: the panels appear next to each other), or true (vertical split: the panels appear above and below each other)
    opts.continuouslayout = true; % Update the content of the panes during interactive modification of the splitpane (true) or not (false. 
    opts.dividerthickness = 8; % the thickness of the divider, in pixels
    opts.bordertype = 'none'; % the type of the border of the splitpane. The options are 'none' or 'etched'
    
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
    elseif numel(temp) == 2
        % two handles defined. These are the panels of the splitpane
        opts.panel1 = temp{1};
        opts.panel2 = temp{2};
    elseif numel(temp) == 3
        % parent and two panels defined (in this order)
        opts.parent = temp{1};
        opts.panel1 = temp{2};
        opts.panel2 = temp{3};
    else
        % more than 3 graphics handles defined. This is not allowed.
        errorbox('There are more than three graphics handles defined. This is not allowed.', 'Too many graphics handles', [mfilename ':2ManyGraphics']);
    end
    
    % initialise the counter for the while loop
    cntr = 0;
    V    = length(varargin);
    while cntr < V
        % increase the counter
        cntr = cntr + 1;
        
        switch lower(varargin{cntr})
            case {'parent' 'paren', 'pare' 'par'}
                if ~(isgraphics(varargin{cntr+1}) && isfigorpanel(varargin{cntr+1}))
                    % bad parent handle
                    errorbox('The specified parent is not appropriate.', 'Bad parent', [mfilename ':BadParent']);
                else
                    opts.parent = varargin{cntr+1};
                    cntr = cntr + 1;
                end
            case {'panel1' 'pan1'}
                if ~(isgraphics(varargin{cntr+1}) && ispanel(varargin{cntr+1}))
                    % bad handle of the first panel
                    errorbox('The specified first panel is not appropriate.', 'Bad panel1', [mfilename ':BadPanel1']);
                else
                    opts.panel1 = varargin{cntr+1};
                    cntr = cntr + 1;
                end
            case {'panel2' 'pan2'}
                if ~(isgraphics(varargin{cntr+1}) && ispanel(varargin{cntr+1}))
                    % bad handle of the second panel
                    errorbox('The specified second panel is not appropriate.', 'Bad panel2', [mfilename ':BadPanel2']);
                else
                    opts.panel2 = varargin{cntr+1};
                    cntr = cntr + 1;
                end
            case {'resizeweight', 'weight'}
                if ~isscalar(varargin{cntr+1})
                    % bad resize weight
                    errorbox('The resize weight has to be a scalar between 0 and 1.', 'Bad resize weight', [mfilename ':BadRSWeight']);
                else
                    opts.resizeweight = between(varargin{cntr+1}, [0 1]);
                    cntr = cntr + 1;
                end
            case 'orientation'
                if ~any(strcmpi(varargin{cntr+1}, {'horizontal', 'vertical'}))
                    % bad orientation option
                    errorbox('The orientation has to be ''horizontal'' or ''vertical''.', 'Bad orientation option', [mfilename ':BadOrientation']);
                elseif strcmpi(varargin{cntr+1}, 'horizontal')
                    opts.orientation = true;
                    cntr = cntr + 1;
                else
                    opts.orientation = false;
                    cntr = cntr + 1;
                end
            case {'continuouslayout' 'continuous layout' 'continuous_layout'}
                if ~istforonoff(varargin{cntr+1})
                    % bad 'continuouslayout' option
                    errorbox('The continuouslayout has to be ''on'' or ''off''.', 'Bad continuouslayout option', [mfilename ':BadContLayout']);
                else
                    opts.continuouslayout = tforonoff2tf(varargin{cntr+1});
                    cntr = cntr + 1;
                end
            case 'dividerthickness'
                if ~isscalar(varargin{cntr+1})
                    % bad divider thickness option
                    errorbox('The divider thickness has to be a numeric scalar larger than 0.', 'Bad dividier thickness option', [mfilename ':BadDivThickness']);
                else
                    opts.dividerthickness = max(varargin{cntr+1}, 0);
                    cntr = cntr + 1;
                end
            case 'bordertype'
                if ~any(strcmpi(varargin{cntr+1}, {'none', 'etched'}))
                    % bad bordertype option
                    errorbox('The bordertype has to be ''none'' or ''etched''.', 'Bad bordertype option', [mfilename ':BadBorderType']);
                else
                    opts.bordertype = varargin{cntr+1};
                    cntr = cntr + 1;
                end
            otherwise
                % invalid parameter
                errorbox(['Parameter ''' lower(varargin{cntr}) ''' is invalid.'], 'Invalid optional parameter', [mfilename 'InvalidOptionalIpt']);
        end
        
    end
    
end % end of subfunction 'parseipt'


%% -------------------------------------------------------------------------------------------------
function adjustpanels(panel1,panel2, jpanel1, jpanel2, jslid)
    % adjustpanels updates the position of the uipanels via their handles such that the axes are
    % properly positioned. Not that this positioning is based on the positions as defined by the
    % JSplitPanel.
    
    % get the height an width of the sliderpanel. Not that these dimensions are in pixels, with the
    % offset in the top left corner.
    w = jslid.getWidth; h = jslid.getHeight;
    
    if ~isgraphics(panel1) || ~isgraphics(panel2)
        % the panels don't exist. Stop this resize function.
        return
    else
        % determine the matlab positions of the two panels
        pos1 = [(jpanel1.getLocation.x)/w, (h-jpanel1.getLocation.y-jpanel1.getHeight)/h, jpanel1.getWidth/w jpanel1.getHeight/h];
        pos2 = [(jpanel2.getLocation.x)/w, (h-jpanel2.getLocation.y-jpanel2.getHeight)/h, jpanel2.getWidth/w jpanel2.getHeight/h];
        
        if any(isnan([pos1, pos2]))
            % there is something wrong with the positions. Stop the resize function.
            return
        end
    end
    
    % set the positions
    panel1.Position = chkpos(pos1, 'norm');
    panel2.Position = chkpos(pos2, 'norm');
    
end % end of subfunction 'adjustpanels'