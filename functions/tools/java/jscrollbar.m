function [scrollbar, j_scrollbar] = jscrollbar(varargin)
% jscrollbar creates a pure java scrollbar
    % ----------------------------------------------------------------------------------------------
    %
    %                                       jscrollbar
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/java/jscrollbar.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % j_scrollbar = jscrollbar
    % j_scrollbar = jscrollbar(parent)
    % j_scrollbar = jsplitpane(..., 'parameter', 'parameter value')
    % [scrollbar, j_scrollbar] = ...
    % 
    % DESCRIPTION
    % -----------
    % j_scrollbar = jscrollbar creates a full java scrollbar in the current figure. j_scrollbar is
    % the java handle.
    %
    % j_scrollbar = jscrollbar(parent) creates a full java scrollbar in the defined parent. parent
    % can be a figure or uipanel.
    % 
    % j_scrollbar = jsplitpane(..., 'parameter', 'parameter value') allows the user to set optional
    % parameters. These parameters are:
    %   parent          graphics handle     The parent that will hold the scrollbar. parent can be a
    %                                       figure or uipanel.
    %   javacomponent   on/{off}            false uses plain java while true (default) places the
    %                                       object in a jawawrapper using matlab's javacomponent.
    %                                       This results in the creation of two panels surrounding
    %                                       the scrollbar
    %   orientation     horizontal/vertical The orientation of the scrollbar
    %   minimum         scalar integer      Minimum value of scrollbar
    %   maximum         scalar integer      Maximum value of scrollbar
	%   value           scalar integer      The initial value of the scrollbar
    %   extent          scalar integer      The extent of the scrollbar's thumb
    %   blockincrement  scalar integer      The increment used when the bar is clicked
    %   unitincrement   scalar integer      The increment used when the user clicks an arrow
    %   enabled         {on}/off            Enable the scrollbar (on) or disable it (off)
    %   tag             string              The tag of the scrollbar (stored in the name field)
    %   tooltip         string              The tooltip of the scrollbar
    % 
    % [scrollbar, j_scrollbar] = ... returns twice the handled java handle of the scrollbar in case
    % 'javacomponent' is set to 'off'. Otherwise, scrollbar is the javawrapper and j_scrollbar is
    % the handled java handle.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2014-2015
    % ==============================================================================================
    
   
    % INITIALIZATION
    % --------------
    
    % check number of input and output arguments
    if nargin > 25 || nargout > 4
        % use chknarg to generate error
        chknarg(nargin, [0 19], nargout, [0 4], mfilename);
    else
        opts = parseipt(varargin{:});
    end

    
    % EXECUTION
    % ---------
    
    if isempty(opts.parent)
        % no parent defined. Use the current figure
        opts.parent = gcf;
    end
    
    % create the java component
    % JScrollBar(int orientation, int value, int extent, int min, int max)
    j_scrollbar = javaObjectEDT('javax.swing.JScrollBar', opts.orientation, opts.value, opts.extent, opts.minimum, opts.maximum+opts.extent);
    
    
    if ~opts.matlab_handle
        % don't use javacomponent
        
        % java handle of parent required
        switch lower(opts.parent.Type)
            case 'figure'
                jparent = figure2java(opts.parent);
            case 'uipanel'
                jparent = uipanel2java(opts.parent);
        end
        % add the scrollbar
        jparent{end}.add(j_scrollbar);
        % convert the java handle to a matlab-based java handle
        j_scrollbar = handle(j_scrollbar, 'callbackproperties');
        scrollbar = j_scrollbar;
        % make the scrollbar visible
        j_scrollbar.setVisible(true);
        
        j_scrollbar.setLocation(50,200);
        if opts.orientation
            j_scrollbar.setSize(20,200);
        else
            j_scrollbar.setSize(200,20);
        end
        % make sure the the scrollbar is clearly visible
        j_scrollbar.revalidate
        
    else
        % use javacomponent. This will result in two extra panels surrounding the scrollbar
        
        % place the component in the parent using a javawrapper
        [j_scrollbar, scrollbar] = javacomponent(j_scrollbar, [0 0 200 200], opts.parent);
      	
        % set the units and position of the splitpane to fill the parent
        scrollbar.Units = 'normalized';
        scrollbar.Position = [0 0 1 1];
        
        % convert the java handle to a matlab-based java handle
        j_scrollbar = handle(j_scrollbar, 'callbackproperties');
        
        % store the java handle in a new dynamic property of the splitpane handle
        if ~isprop(scrollbar, 'java_handle')
            scrollbar.addprop('java_handle'); % create the field
        end
        scrollbar.java_handle = j_scrollbar;     % save the icsobj into this field so that it is always available
    end
    
    % set the block increment
    j_scrollbar.BlockIncrement = opts.blockincrement;
    
    % set the unit increment
    j_scrollbar.UnitIncrement = opts.unitincrement;
    
    if ~isempty(opts.tag)
        % set the tag
        j_scrollbar.Name = opts.tag;
    end
    
    if ~isempty(opts.tooltip)
        % set the tooltip
        j_scrollbar.ToolTipText = opts.tooltip;
    end
    
    j_scrollbar.Enabled = opts.enabled;
    
    if ~isempty(opts.callback)
        % set the calue changed callback
        j_scrollbar.AdjustmentValueChangedCallback = opts.callback;
    end

end % end of function 'jscrollbar'

%% -------------------------------------------------------------------------------------------------
function opts = parseipt(varargin)
    % parseipt parses the input arguments of the main function
    
    % set default values
    opts.parent         =    []; % the handle of the parent that will hold the jscrollbar
    opts.matlab_handle  = false; % place the object in a jawawrapper using matlab's javacomponent
    opts.orientation    = false; % orientation of the scrollbar: false is horizontal, true is vertical
    opts.minimum        =     1; % minimum value of scrollbar
    opts.maximum        =   100; % maximum value of scrollbar
    opts.value          =     1; % the value of the scrollbar
    opts.extent         =    []; % the extent of the scrollbar's thumb
    opts.blockincrement =    []; % the increment used when the bar is clicked
    opts.enabled        =  true; % enable the scrollbar (true) or not (false
    opts.tag            =    ''; % the tag of the scrollbar
    opts.tooltip        =    ''; % the tooltip of the scrollbar
    opts.unitincrement  =    []; % the increment when the user clicks an arrow
    opts.callback       =    []; % the function that is executed when the value of the scrollbar is change
    
    if nargin > 0 && isscalar(varargin{1}) && isgraphics(varargin{1})
        if ~isfigorpanel(varargin{1})
            errorbox('The specified parent is not appropriate.', 'Bad parent', [mfilename ':BadParent']);
        else
            % the first input argument is a graphics handle
            opts.parent = varargin{1};
            varargin(1) = [];
        end
    end
    
    L = length(varargin); % total number of input arguments
    c = 0;                % counter to keep track of input argument
    
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
        
        switch lower(varargin{c})
            case {'parent' 'paren', 'pare' 'par'}
                if ~(isgraphics(varargin{c+1}) && isfigorpanel(varargin{c+1}))
                    % bad parent handle
                    errorbox('The specified parent is not appropriate.', 'Bad parent', [mfilename ':BadParent']);
                else
                    opts.parent = varargin{c+1};
                    c = c + 1;
                end
            case 'orientation'
                % orientation of the scrollbar: false is horizontal, true is vertical
                if ~any(strcmpi(varargin{c+1}, {'horizontal', 'vertical'}))
                    % bad orientation option
                    errorbox('The orientation has to be ''horizontal'' or ''vertical''.', 'Bad orientation option', [mfilename ':BadOrientation']);
                elseif strcmpi(varargin{c+1}, 'horizontal')
                    opts.orientation = false;
                    c = c + 1;
                else
                    opts.orientation = true;
                    c = c + 1;
                end
            case {'matlab_handle', 'javacomponent', 'matlabhandle', 'matlabh', 'matlab_h'}
                % place the object in a jawawrapper using matlab's javacomponent
                if ~istforonoff(varargin{c+1})
                    errorbox(['The option ''' varargin{c} ''' has to be logical, ''on'' or ''off''.'], 'Bad javacomponent option', [mfilename ':BadJavaComp']);
                else
                    opts.matlab_handle = tforonoff2tf(varargin{c+1});
                    c = c + 1;
                end
            case {'minimum' 'min'}
                % minimum value of scrollbar
                if ~isnumeric(varargin{c+1}) || ~isscalar(varargin{c+1})
                    errorbox(['The option ''' varargin{c} ''' has to be a numeric scalar integer.'], 'Bad minimum option', [mfilename ':BadMin']);
                else
                    opts.minimum = round(varargin{c+1});
                    c = c + 1;
                end
            case {'maximum' 'max'}
                % maximum value of scrollbar
                if ~isnumeric(varargin{c+1}) || ~isscalar(varargin{c+1})
                    errorbox(['The option ''' varargin{c} ''' has to be a numeric scalar integer.'], 'Bad maximum option', [mfilename ':BadMax']);
                else
                    opts.maximum = round(varargin{c+1});
                    c = c + 1;
                end
            case {'value' 'val'}
                % value of scrollbar
                if ~isnumeric(varargin{c+1}) || ~isscalar(varargin{c+1})
                    errorbox(['The option ''' varargin{c} ''' has to be a numeric scalar integer.'], 'Bad value option', [mfilename ':BadVal']);
                else
                    opts.value = round(varargin{c+1});
                    c = c + 1;
                end
            case {'extent', 'visibleamount', 'visible_amount'}
                % the extent of the scrollbar's thumb
                if ~isnumeric(varargin{c+1}) || ~isscalar(varargin{c+1})
                    errorbox(['The option ''' varargin{c} ''' has to be a numeric scalar integer.'], 'Bad extent option', [mfilename ':BadExtent']);
                else
                    opts.extent = round(varargin{c+1});
                    c = c + 1;
                end
            case {'blockincrement', 'block_increment', 'block'}
                % the increment used when the bar is clicked
                if ~isnumeric(varargin{c+1}) || ~isscalar(varargin{c+1})
                    errorbox(['The option ''' varargin{c} ''' has to be a numeric scalar integer.'], 'Bad blockincrement option', [mfilename ':BadBlockIncrement']);
                else
                    opts.blockincrement = round(varargin{c+1});
                    c = c + 1;
                end
            case {'unitincrement', 'unit_increment', 'unit'}
                % the increment when the user clicks an arrow
                if ~isnumeric(varargin{c+1}) || ~isscalar(varargin{c+1})
                    errorbox(['The option ''' varargin{c} ''' has to be a numeric scalar integer.'], 'Bad unitincrement option', [mfilename ':BadUnitIncrement']);
                else
                    opts.unitincrement = round(varargin{c+1});
                    c = c + 1;
                end
            case {'enable', 'enabled'}
                % enable the scrollbar (true) or not (false)
                if ~istforonoff(varargin{c+1})
                    errorbox(['The option ''' varargin{c} ''' has to be logical, ''on'' or ''off''.'], 'Bad enabled option', [mfilename ':BadEnabled']);
                else
                    opts.enabled = tforonoff2tf(varargin{c+1});
                    c = c + 1;
                end
            case {'tag' 'name'}
                % the tag of the scrollbar
                if ~ischar(varargin{c+1})
                    errorbox(['The option ''' varargin{c} ''' has to be logical, ''on'' or ''off''.'], 'Bad tag option', [mfilename ':BadTag']);
                else
                    opts.tag = varargin{c+1};
                    c = c + 1;
                end
            case {'tooltip'}
                % the tooltip of the scrollbar
                if ~ischar(varargin{c+1})
                    errorbox(['The option ''' varargin{c} ''' has to be logical, ''on'' or ''off''.'], 'Bad tooltip option', [mfilename ':BadTooltip']);
                else
                    opts.tooltip = varargin{c+1};
                    c = c + 1;
                end
            case {'callback'}
                % the function that is executed when the value of the scrollbar changes
%                 if ~ischar(varargin{c+1})
%                     errorbox(['The option ''' varargin{c} ''' has to be logical, ''on'' or ''off''.'], 'Bad tooltip option', [mfilename ':BadTooltip']);
%                 else
                    opts.callback = varargin{c+1};
                    c = c + 1;
%                 end
            otherwise
                % invalid parameter
                errorbox(['Parameter ''' lower(varargin{c}) ''' is invalid.'], 'Invalid optional parameter', [mfilename 'InvalidOptionalIpt']);
        end
        
    end
    
    if opts.minimum > opts.maximum
        errorbox('The minimum value of the scrollbar has to be equal to or larger than the maximum value.', 'Bad scrollbar range', [mfilename ':BadRange'])
    end
    
    % make sure that the value is within the range, otherwise adjust it
    opts.value = min(max(opts.value, opts.minimum), opts.maximum);
    
    range = floor(opts.maximum-opts.minimum)+1;
    if isempty(opts.extent)
        % set a proper value for the extent
        opts.extent = max(1, floor(range/20));
    end
    
    if isempty(opts.blockincrement)
        opts.blockincrement = max(1, range/10);
    else
        opts.blockincrement = min(range, opts.blockincrement);
    end
    
    
    if isempty(opts.unitincrement)
        opts.unitincrement = 1;
    else
        opts.unitincrement = min(range, opts.unitincrement);
    end
    
end % end of subfunction 'parseipt'