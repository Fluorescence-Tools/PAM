function chknarg(nin, inlim, nout, outlim, fcnname)
% chknarg checks the number of input and output arguments
    % ----------------------------------------------------------------------------------------------
    %
    %                                          chknarg
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/support%20fcns/chknarg.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % chknarg(nargin, IN, nargout, OUT)
    % chknarg(nargin, IN, nargout, OUT, mfilename)
    %
    % DESCRIPTION
    % -----------
    % chknarg(nargin, IN, nargout, OUT) checks the number of input and output arguments. The number
    % of input arguments is defined in nargin and the number of output arguments is defined in
    % nargout. IN and OUT can be scalars to set a fixed number of arguments, or they can be a two
    % element vector to define the limits of the number of arguments, or they can be vectors
    % defining the allowed number of arguments. When the number of input or output arguments are
    % invalid, an error is thrown and an error message box is shown.
    %
    % chknarg(nargin, IN, nargout, OUT, mfilename) contains an optional fifth input argument
    % mfilename. This argument should contain the name of the function calling chknarg. Note that
    % whitespaces are removed from this name. Upon an invalid argument number, this name is used as
    % part of the error identifier.
    % 
    % REMARKS
    % -------
    % For functions that are frequently used and that need to be fast, it is better to use if
    % constructs. Yet, chknarg might still be usefull to generate the appropriate error.
    %
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % Parse input arguments
    if nargin < 4 || nargin > 5 || nargout ~= 0
        % number of input arguments is incorrect. Use chknarg to generate error
        chknarg(nargin, [4 5], nargout, 0, mfilename);
        
    elseif ~isscalar(nin)
        % the first input argument should be a scalar
        errorbox('The first input argument specifying the current number of input arguments, should be a scalar.', 'Input not a scalar', [mfilename ':IptNotScalar']);
        
    elseif ~isvector(inlim)
        % the second input argument should be a vector
        errorbox('The second input argument specifying either the limits of the number of input arguments or the allowed number of input arguments, should be a vector.', 'Limits not a vector', [mfilename ':BadLimits']);
        
    elseif ~isscalar(nout)
        % the third output argument should be a scalar
        errorbox('The third input argument specifying the current number of output arguments, should be a scalar.', 'Output not a scalar', [mfilename ':OutputNotScalar']);
        
    elseif ~isvector(outlim)
        % the fourth output argument should be a vector
        errorbox('The fourth input argument specifying either the limits of the number of output arguments or the allowed number of output arguments, should be a vector.', 'Limits not a vector', [mfilename ':BadLimits']);
        
    elseif nargin == 5
        % an optional fifth element is given
        if ~ischar(fcnname)
            % the fifth input argument should be a string
            errorbox('The optional fifth input argument specifying the function name, should be a string.', 'Function name not a string', [mfilename ':fcnnameNoStr']);
        
        else
            % remove all whitespaces from the function name
            fcnname = regexprep(fcnname, ' ', '');
            
        end
        
    else
        % set default value of function name
        fcnname = '';
        
    end
    
    
    % EXECUTION
    % ---------
    
    if isscalar(inlim)
        % only one number of input arguments is allowed
        chkn('in', nin, inlim, inlim, fcnname);
        
    elseif numel(inlim) == 2
        % the limits of the number of input arguments are given.
        chkn('in', nin, inlim(1), inlim(2), fcnname);
        
    else
        % a vector of elements is given
        chklistn('in', nin, inlim, fcnname);
        
    end
    
    if isscalar(outlim)
        % only one number of output arguments is allowed
        chkn('out', nout, outlim, outlim, fcnname);
        
    elseif numel(outlim) == 2
        % the limits of the number of output arguments are given.
        chkn('out', nout, outlim(1), outlim(2), fcnname);
        
    else
        % a vector of elements is given
        chklistn('out', nout, outlim, fcnname);
        
    end
    
end % end of function 'chknarg'
%% =================================================================================================



%% -------------------------------------------------------------------------------------------------
function chkn(prefix, nargs, low, high, fcnname)
    % this function performs the actual testing of the number of arguments
    
    if nargs < low
        % not enough arguments
        
        % create message id
        msgid = sprintf('%s:TooFew%sputs', fcnname, ufirstlrest(prefix));
        
        % create message title
        msgtitle = sprintf('Too few %sput arguments', prefix);
        
        % create function string to insert in message
        if isempty(fcnname)
            % no function name given. USe empty string
            fcnstr = [];
            
        else
            % place function name between quotes
            fcnstr = sprintf('''%s'' ', fcnname);
            
        end
        
        if low == 1
            % create first part of the message in case only one argument is
            % required
            msg1 = sprintf('The function %sexpected at least 1 %sput argument', fcnstr, prefix);
            
        else
            % several input arguments expected.
            msg1 = sprintf('The function %sexpected at least %d %sput arguments', fcnstr, low, prefix);
            
        end
        
        if nargs == 1
            % create second part of the message string in case only one
            % argument is given
            msg2 = sprintf('but was called instead with 1 %sput argument.', prefix);
            
        else
            % create second part of the message string in case several
            % argument are given
            msg2 = sprintf('but was called instead with %d %sput arguments.', nargs, prefix);
        end
        
        % show error message
        errorbox(sprintf('%s\n%s', msg1, msg2), msgtitle, 'id', msgid);
        
  	elseif nargs > high
        % not enough arguments
        
        % create message id
        msgid = sprintf('%s:TooMany%sputs', fcnname, ufirstlrest(prefix));
        
        % create message title
        msgtitle = sprintf('Too many %sput arguments', prefix);
        
        % create function string to insert in message
        if isempty(fcnname)
            % no function name given. USe empty string
            fcnstr = [];
            
        else
            % place function name between quotes
            fcnstr = sprintf('''''%s'''' ', fcnname);
            
        end
        
        if high == 1
            % create first part of the message in case only one argument is
            % required
            msg1 = sprintf('The function %sexpected at most 1 %sput argument', fcnstr, prefix);
            
        else
            % several input arguments expected.
            msg1 = sprintf('The function %sexpected at most %d %sput arguments', fcnstr, high, prefix);
            
        end
        
        if nargs == 1
            % create second part of the message string in case only one
            % argument is given
            msg2 = sprintf('but was called instead with 1 %sput argument.', prefix);
            
        else
            % create second part of the message string in case several
            % argument are given
            msg2 = sprintf('but was called instead with %d %sput arguments.', nargs, prefix);
        end
        
        % show error message
        errorbox(sprintf('%s\n%s', msg1, msg2), msgtitle, 'id', msgid);
        
    end
    
end % end of subfunction 'chkn'


%% -------------------------------------------------------------------------------------------------
function chklistn(prefix, nargs, list, fcnname)
    % this function performs the actual testing of the number of arguments
    
    if ~any(nargs == list)
        % the number of arguments is not allowed
        
        % create message id
        msgid = sprintf('%s:BadNumber%sputs', fcnname, ufirstlrest(prefix));
        
        % create message title
        msgtitle = sprintf('BAd number of %sput arguments', prefix);
        
        % create function string to insert in message
        if isempty(fcnname)
            % no function name given. USe empty string
            fcnstr = [];
            
        else
            % place function name between quotes
            fcnstr = sprintf('''''%s'''' ', fcnname);
            
        end
        
        % create list of allowed numbers
        t = sprintf('%d, ', list(1));
        for m = 2 : length(list)
            if m == length(list)
                t = [t sprintf('or %d', list(m))]; %#ok<*AGROW>
            else
                t = [t sprintf('%d, ', list(m))];
            end
        end
        
        % create first part of the message
        msg1 = sprintf('The function %sexpected %s %sput argument', fcnstr, t, prefix);
        
        if nargs == 1
            % create second part of the message string in case only one
            % argument is given
            msg2 = sprintf('but was called instead with 1 %sput argument.', prefix);
            
        else
            % create second part of the message string in case several
            % argument are given
            msg2 = sprintf('but was called instead with %d %sput arguments.', nargs, prefix);
        end
        
        % show error message
        errorbox(sprintf('%s\n%s', msg1, msg2), msgtitle, 'id', msgid);
        
    end
    
end % end of subfunction 'chklistn'


%% -------------------------------------------------------------------------------------------------
function strout = ufirstlrest(strin)
    % this function capitalizes the first letter of the input string
    
    if length(strin) > 1
        strout = [upper(strin(1)) lower(strin(2:end))];
    end
    
end % end of subfunction 'ufirstlrest'