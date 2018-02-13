function str_w = strwidth(ghandle, str)
% strwidth returns the necessary width to display a string, expressed in pixels
    % ----------------------------------------------------------------------------------------------
    %
    %                                       strwidth
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/strwidth.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % str_w = strwidth(ghandle, str)
    % 
    % DESCRIPTION
    % -----------
    % str_w = strwidth(ghandle, str) returns the width necessary to display the string in the
    % graphical object defined by the handle in the first input argument ghandle. The width is
    % returned in pixels.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin < 1 || nargin > 2 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [1 2], nargout, [0 1], mfilename);
            
    % Parse input arguments
    elseif ~ishandle(ghandle) || ~ghandle.isvalid
        % The first input argument has to be a valid handle to a graphical element
        errorbox('The first input argument has to be a valid graphical handle', 'Input argument not valid', [mfilename ':NotValidH']);
    
    elseif ~ischar(str)
        % The second input argument has to be a valid handle
        errorbox('The second input argument has to be a character string.', 'Input not a string', [mfilename ':IptNotStr']);
        
    end
    
    
    % EXECUTION
    % ---------
    
    if isprop(ghandle, 'jv_strwidth')
        % this object has already been used. Use the same method as previously stored.
        try
            str_w = ghandle.jv_strwidth.stringWidth(str);
        catch ME
            warning([mfilename ':JavaFailed'], ['The java based approach to determine the display width of a string failed. txtlength is used instead.' newline 'Reason of failing is:' newline '    ' ME.identifier newline '    ' ME.message]);
            str_w = txtlength(ghandle, str, 'pixels');
        end
        return
    end
    
    switch ghandle.Type
        case 'figure'
            jh = figure2java(ghandle);            
        case 'uipanel'
            jh = uipanel2java(ghandle);            
        case 'uicontrol'
            jh = uicontrol2java(ghandle);
        otherwise
            errorbox(['The type of the graphical element (''' ghandle.Type ''') is not supported.'], 'Unsupported graphical type', [mfilename ':BadGraphType']);
    end
    
    try
        % get the width of the text
        str_w = jh{end}.getFontMetrics(jh{end}.getFont).stringWidth(str);
        
        if ~isprop(ghandle, 'jv_strwidth')
            % the field 'jvhandle' does not exist yet.
            ghandle.addprop('jv_strwidth');
        end
        ghandle.jv_strwidth = jh{end}.getFontMetrics(jh{end}.getFont);
        
    catch ME
        warning([mfilename ':JavaFailed'], ['The java based approach to determine the display width of a string failed. txtlength is used instead.' newline 'Reason of failing is:' newline '    ' ME.identifier newline '    ' ME.message]);
        str_w = txtlength(ghandle, str, 'pixels');
    end
    
end % end of function 'strwidth'