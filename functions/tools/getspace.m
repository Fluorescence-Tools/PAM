function varargout = getspace(handle, units)
% getspace returns the available space in the uipanel or figure
    % ----------------------------------------------------------------------------------------------
    %
    %                                        getspace
    % 
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/getspace.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % Space = getspace(handle)
    % Space = getspace(handle, 'units')
    % [width, height] = ...
    %
    % DESCRIPTION
    % -----------
    % Space = getspace(handle) returns a two-element vector with the available width and height of
    % the figure or uipanel defined in handle. These dimensions are returned in the units of the
    % figure or uipanel.
    % 
    % Space = getspace(handle, 'units') returns the available space in the units defined by 'units'.
    % Possible dimension units are 'centimeters', 'pixels', 'normalized', 'inches', 'points', and
    % 'characters'.
    %
    % [width, height] = ... returns the available width in the first output argument and the
    % available height in the second output argument.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
 	% check number of input and output arguments
    if nargin < 1 || nargin > 2 || nargout > 2
        % use chknarg to generate error
        chknarg(nargin, [1 2], nargout, [0 2], mfilename);        
        
    % Parse input arguments
    elseif ~isfigorpanel(handle)
        % The first input argument has to be a valid handle
        errorbox('The first input argument has to be a valid handle of a figure or uipanel.', 'Input argument not valid', 'id', [mfilename ':NotValidHandle']);
        
    elseif nargin == 2
        % the units are defined
        if ~isunit(units)
            % the units are not correct
            errorbox('The second input argument has to be a valid units specification.', 'Invalid Units', 'id', [mfilename ':UnitsNotValid']);
        end
        
    else
        % no units defined
        units = handle.Units;
        
    end
    
    
    % EXECUTION
    % ---------
    
    % get the java handles of the object
    if isfig(handle)
        % the object is a figure
        try
            j_handles = figure2java(handle);
        catch ME
            drawnow();
            j_handles = figure2java(handle);
        end
        j_handle  = j_handles{end};
    else
        % the object is a uipanel
        j_handles = uipanel2java(handle);
        j_handle  = j_handles{end};
    end
    
    % get the bounds of the object in pixels
    temp = j_handle.getBounds;
    
    % get the width and height of the object
    pos = [temp.getWidth, temp.getHeight];
    
    if ~strcmpi(units, 'pixels')
        % the dimensions have to be converted to a different unit
        switch lower(units)
            case 'normalized'
                pos = [1 1];
            case 'centimeters'
                pos = pixels2cm(pos);
            case 'inches'
                pos = cm2inch(pixels2cm(pos));
            otherwise
                errorbox('The units ''points'' and ''characters'' are not supported yet by this function.', 'Unsupported units', [mfilename ':UnsupportedUnits'])
        end
    end
        
    % save available space into output argument(s)
    if nargout == 2
        varargout{1} = pos(1);
        varargout{2} = pos(2);
    else
        varargout{1} = pos;
    end
    
end % end of function 'getspace'