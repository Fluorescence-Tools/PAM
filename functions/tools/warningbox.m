function warningbox(varargin)
% warningbox shows a warning message box and throws a corresponding warning
    % ----------------------------------------------------------------------------------------------
    %
    %                                       warningbox
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/warningbox.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % warningbox(Msg, Title) 
    % warningbox(Msg, Title, 'id', 'Warning Identifier')
    % warningbox(..., 'createmode', 'mode')
    % warningbox(..., 'wait', 'Value')
    % 
    % DESCRIPTION
    % -----------
    % warningbox(Msg, Title) displays a modal warning message box with message string Msg and title
    % string Title. After the user presses the ok button, a warning message is printed in the
    % command window with message Msg.
    %     
    % warningbox(Msg, Title, 'id', 'Warning Identifier') adds a warning identifier as specified in
    % 'Warning Identifier' to the warning message in the command window.
    %     
    % warningbox(..., 'createmode', 'mode') allows to set the creation mode of the warning message
    % box. Valid strings for 'mode' are 'modal' and 'non-modal'. By default, 'modal' is used.
    %
    % warningbox(..., 'wait', 'Value') allows the user to decide whether he wants the function to
    % wait untill the user closes the message box ('on' {default}), or whether he wants the function
    % to proceed irrespective of the user's behavior ('off').
    %
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    chknarg(nargin, [2 8], nargout, 0, mfilename);

    % Parse input arguments
    ParsObj              = inputParser;    % creat input parser object
    ParsObj.FunctionName = mfilename;      % save the function name to report upon error
    ParsObj.addRequired('MsgStrng', @ischar); % error message string
    ParsObj.addRequired(   'Title', @ischar); % title of the error message dialog box
    ParsObj.addParamValue(         'ID',      '', @ischar);                                      % error identifier
    ParsObj.addParamValue( 'createmode', 'modal', @(x) any(strcmpi(x, {'modal', 'non-modal'}))); % create mode
    ParsObj.addParamValue(       'wait',    'on', @(x) any(strcmpi(x, {'on', 'off'})));
    ParsObj = iptparsing(ParsObj, varargin{:}); % validate input arguments
    
   
    % EXECUTION
    % ---------
    
    % show error message box
    if strcmpi(ParsObj.Results.wait, 'on')
        % Let the code pause untill the user closes the warning message
        uiwait(warndlg(ParsObj.Results.MsgStrng, ParsObj.Results.Title, ParsObj.Results.createmode));
    else
        % let the code continue
        warndlg(ParsObj.Results.MsgStrng, ParsObj.Results.Title, ParsObj.Results.createmode)
    end

    % replace some characters so sprintf prints them nicely
    MsgString = regexprep(ParsObj.Results.MsgStrng, {'\\'}, {'\\\\'});
    
    % throw error
    if isempty(ParsObj.Results.ID)
        % no identifier given
        warning('\n\n%s\n', MsgString); %#ok<WNTAG>
    else
        % identifier given
        k = strfind(ParsObj.Results.ID, ':');
        if isempty(k)
            % if the identifier does not contain a colon (':'), is will be
            % considered to be a message string. In that case, only the
            % identifier will be shown. Do precent this, an extra colon is
            % added to the identifier.
            warning([ParsObj.Results.ID ':temp'], '\n\n%s\nID: %s\n', MsgString, ParsObj.Results.ID); %#ok<SPERR>
        else
            warning(ParsObj.Results.ID, sprintf('\n\n%s\nID: %s\n', MsgString, ParsObj.Results.ID)); %#ok<SPWRN,SPERR>
        end
    end
    
end % end of function 'warningbox'