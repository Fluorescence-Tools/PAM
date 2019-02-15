function txtL = txtlength(H, Str, Units)
% txtlength returns the necessary width to display a string
    % ----------------------------------------------------------------------------------------------
    %
    %                                          txtlength
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/txtlength.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % space = txtlength(uicontrol_handle)
    % space = txtlength(handle, strng)
    % space = txtlength(handle, strng, Units)
    % 
    % DESCRIPTION
    % -----------
    % space = txtlength(uicontrol_handle) returns the width necessary to display the string in the
    % uicontrol object. The width is returned in the current units of the object.
    % 
    % space = txtlength(handle, strng) returns the necessary width to display the string strng in
    % the figure or uipanel with handle handle. The width will be returned in the default units of
    % the UI component.
    % 
    % space = txtlength(handle, strng, Units) returns the width in units Units. Possible units are
    % 'centimeters', 'pixels', 'normalized', 'inches', 'points' and 'characters'.
    % 
    % REMARKS
    % -------
    % The width of the string is measured by actually creating a graphical element holding the text.
    % This is very time consuming. Consider strwidth instead for time critical applications.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin < 1 || nargin > 3 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [1 3], nargout, [0 1], mfilename);
            
    % Parse input arguments
    elseif nargin == 1
        if ~any(strcmpi(get(H, 'type'), {'uicontrol' 'text'}))
            % The first input argument has to be a valid handle to a
            % uicontrol element
            errorbox('The first input argument has to be a valid handle of a uicontrol element.', 'Input argument not valid', 'id', [mfilename ':NotValidH']);
            
        end
        
    elseif ~isfigorpanel(H)
        % The first input argument has to be a valid handle
        errorbox('The first input argument has to be a valid handle of a figure or uipanel.', 'Input argument not valid', 'id', [mfilename ':NotValidH']);
        
    elseif ~ischar(Str)
        % The second input argument has to be a valid handle
        errorbox('The second input argument has to be a character string.', 'Input not a string', 'id', [mfilename ':IptNotStr']);
        
    elseif nargin == 3
        % the units are given
        if ~isunit(Units)
            % the units are not correct
            errorbox('The third input argument has to be a valid units specification.', 'Invalid Units', 'id', [mfilename ':UnitsNotValid']);
            
        end
        
    end
    
    
    % EXECUTION
    % ---------
    
    if nargin == 1 
        % get the length of the text    
        Xtnt = get(H, 'extent');
        txtL = Xtnt(3);
        
    else
        % create temporary textbox into handle
        if nargin ~= 3
            txt = uicontrol('Style', 'text', 'Parent', H, 'String', Str, 'Visible', 'off');
            
        else
            txt = uicontrol('Style', 'text', 'Parent', H, 'String', Str, 'Visible', 'off', 'Units', Units);
            
        end
        
        % get the length of the text    
        Xtnt = get(txt, 'extent');
        txtL = Xtnt(3);
        
        % delete the temporary textbox
        delete(txt);
        
    end
    
end % end of main function 'txtlength'