function str_h = strheight(ghandle)
% strheight returns the necessary height to display a string, expressed in pixels
    % ----------------------------------------------------------------------------------------------
    %
    %                                       strheight
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/strheight.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % str_h = strheight(ghandle)
    % 
    % DESCRIPTION
    % -----------
    % str_h = strheight(ghandle) returns the height necessary to display a string in the
    % graphical object defined by the handle in the first input argument ghandle. The height is
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
    if nargin ~= 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
            
    % Parse input arguments
    elseif ~ishandle(ghandle) || ~ghandle.isvalid
        % The first input argument has to be a valid handle to a graphical element
        errorbox('The first input argument has to be a valid graphical handle', 'Input argument not valid', [mfilename ':NotValidH']);
    
    end
    
    
    % EXECUTION
    % ---------
    
    if isprop(ghandle, 'jv_strwidth')
        % this object has already been used. Use the same method as previously stored.
        try
            str_h = ghandle.jv_strwidth.getHeight;
        catch ME
            warning([mfilename ':JavaFailed'], ['The java based approach to determine the display width of a string failed. txtlength is used instead.' newline 'Reason of failing is:' newline '    ' ME.identifier newline '    ' ME.message]);
            str_h = txtlength(ghandle, str, 'pixels');
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
        str_h = jh{end}.getFontMetrics(jh{end}.getFont).getHeight;
        
        if ~isprop(ghandle, 'jv_strwidth')
            % the field 'jvhandle' does not exist yet.
            ghandle.addprop('jv_strwidth');
        end
        ghandle.jv_strwidth = jh{end}.getFontMetrics(jh{end}.getFont);
        
    catch ME
        warning([mfilename ':JavaFailed'], ['The java based approach to determine the display width of a string failed. txtlength is used instead.' newline 'Reason of failing is:' newline '    ' ME.identifier newline '    ' ME.message]);
        str_h = txtlength(ghandle, str, 'pixels');
    end
    
end % end of function 'strheight'