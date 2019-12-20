function errorbox(varargin)
% errorbox shows an error message box and throws a corresponding error
    % ----------------------------------------------------------------------------------------------
    %
    %                                      errorbox
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/errorbox.m $
    % 
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % errorbox(Msg)
    % errorbox(Msg, option)
    % errorbox(MsgStruct)
    % errorbox(MsgStruct, option)
    % errorbox(..., 'parameter', 'parameter value')
    % 
    % DESCRIPTION
    % -----------
    % errorbox(Msg) displays a modal error message box with message string Msg. After the user
    % presses the ok button, an error message is printed in the command window with message Msg.
    % 
    % errorbox(Msg, option) allows the user to set extra options. These options are:
    %   title       A string (with white spaces) that is used as the title of the errordialog box.
    %   identifier  A string (without white spaces) that represents the identifier of the error.
    %   createmode  The string 'modal' or 'non-modal' that determines the creation mode of the error
    %               dialog box.
    % Note that these options can also be combined.
    %   
    % errorbox(MsgStruct) accepts the same structure as the matlab function error. The scalar error
    % structure input msgStruct should have at least one of the fields 'message', 'identifier', or
    % 'stack'. When the MsgStruct input includes a stack field, the stack field of the error will be
    % set according to the contents of the stack input. When specifying a stack input, use the
    % absolute file name and the entire sequence of functions that nests the function in the stack
    % frame. This is the same as the string returned by dbstack('-completenames'). If MsgStruct is
    % an empty structure, no action is taken and error returns without exiting the function.
    %     
    % errorbox(MsgStruct, option) allows the user to set extra options, the same as described for
    % 'errorbox(Msg, option)'.
    %
    % errorbox(..., 'parameter', 'parameter value') Lets the user set extra options as a
    % parameter-parameter value pair. Valid options are:
    %   title       string                  A string that is used as the title of the errordialog
    %                                       box. 
    %   identifier  string                  A string (preferably without white spaces) that
    %                                       represents the identifier of the error.
    %   createmode  {'modal'}/'non-modal'   the creation mode of the error dialog box.
    %
    % EXAMPLES
    % --------
    % msg = 'I guess something went wrong.';
    % errorbox(msg);
    %
    % msg = 'I guess something went wrong.';
    % title = 'Can I get your attention?';
    % id = 'BadNews';
    % errorbox(msg, title, id);
    % 
    % MODIFICATIONS
    % -------------
    %   02-Oct-2014 15:29:51
    %       * enable the function to receive an MsgStruct identical to the function 'error'.
    %       * use of ME.throwAsCaller to let this function disappear from the error list.
    %       * different input argument parsing to make the calls to this function more flexible.
    %         Before, this function made still use of inputParser object. id and createmode can now
    %         be entered as a single parameter or as a parameter-parameter value pair.
    % 
    % TODOs:
    % ------
    %   * show the stack of filenames in the error dialogue.
    %
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================

    % INITIALISATION
    % --------------
    
    % set default values
    msgstruct  = struct('message', [], 'identifier', []); % empty message structure
    msgtitle   =      ''; % empty title message
    createmode = 'modal'; % by default, a modal dialogue box is used.
    
    % check number of input and output arguments
    if  nargin < 1 || nargin > 6 || nargout > 0
        % use chknarg to generate error
        chknarg(nargin, [1 6], nargout, 0, mfilename);
        
    elseif isstruct(varargin{1})
        % the first input argument is a structure. This structure should hold at least on of the
        % fields 'message', 'identifier', or 'stack'. A fourth optional field is 'title'.
        if ~any(ismember(lower(fieldnames(varargin{1})), {'message'; 'identifier'; 'stack'}))
            errorbox(sprintf('The message structure should holds at least one of these fields):\n\t''message''\n\t''identifier''\n\t''stack'''), 'Bad error message structure', [mfilename: 'BadErrMsgStruct']);
        
        elseif isempty(varargin{1})
            return;
            
        else
            msgstruct = varargin{1};
            % remove this input argument
            varargin(1) = [];
        end
        
    elseif ~ischar(varargin{1})
        errorbox('The first input argument has to be a valid message string or an error MsgStruct.', 'Bad error message', [mfilename ':BadErrMsg']);
        
    else
        % save the message string
        msgstruct.message = varargin{1};
        % remove this input argument
        varargin(1) = [];
        
    end
    
    cntr = 0;
    L    = length(varargin);
    % parse through the remaining input arguments
    while cntr < L
        % increase the counter
        cntr = cntr + 1;
        
        if ~ischar(varargin{cntr})
            errorbox('The input arguments all have to be a valid string.', 'Bad input argument', [mfilename ':BadIptArg']);
        end
        
        switch lower(varargin{cntr})
            case {'id', 'identifier'}
                % part of a parameter - parameter value argument pair: identifier
                cntr = cntr + 1;
                if ~ischar(varargin{cntr})
                    errorbox('The input arguments all have to be a valid string.', 'Bad input argument', [mfilename ':BadIptArg']);
                else
                    msgstruct.identifier = varargin{cntr};
                end
                
            case 'createmode'
                % part of a parameter - parameter value argument pair: createmode
                cntr = cntr + 1;
                if ~ischar(varargin{cntr}) || ~any(strcmpi(varargin{cntr}, {'modal', 'non-modal'}))
                    errorbox('The value of parameter ''createmode'' has to be either ''modal'' or ''non-modal''.', 'Bad createmode argument', [mfilename ':BadCreateMode']);
                else
                    createmode = lower(varargin{cntr});
                end
                
            case 'title'
                % part of a parameter - parameter value argument pair: identifier
                cntr = cntr + 1;
                if ~ischar(varargin{cntr})
                    errorbox('The title has to be a valid string.', 'Bad title', [mfilename ':BadTitle']);
                else
                    msgtitle = varargin{cntr};
                end
                
            otherwise
                % it is a string, but is it createmode, identifier, or title?
                
                if any(strcmpi(varargin{cntr}, {'modal', 'non-modal'}))
                    % it is a createmode
                    createmode = lower(varargin{cntr});
                    
                elseif any(':' == varargin{cntr})% || any(' ' == varargin{cntr})
                    % it is an identifier
                    if isfield(msgstruct, 'identifier') && ~isempty(msgstruct.identifier)
                        msgtitle = msgstruct.identifier;
                        msgstruct.identifier = varargin{cntr};
                    else
                        msgstruct.identifier = varargin{cntr};
                    end
                    
                else
                    %it is a title
                    msgtitle = varargin{cntr};
                end
        end
        
    end
    
    if isempty(msgtitle)
        % create default title
        msgtitle = 'An error has occurred';
    end
    if ~isfield(msgstruct, 'message') || isempty(msgstruct.message)
        % create default message
        msgstruct.message = 'An error has occurred.';
    end
    if isfield(msgstruct, 'identifier') && isempty(msgstruct.identifier)
        % no identifier specified. Remove the field.
        msgstruct = rmfield(msgstruct, 'identifier');
    end
    
    % EXECUTION
    % ---------
    
    try
        % throw error
        error(msgstruct);
        
    catch ME
        % show the error message in a  dialogue box
        uiwait(errordlg(msgstruct.message, msgtitle, createmode));
        
        % TODO: show stack in errorbox
        ME.throwAsCaller
    end
    
end % end of function 'errorbox'