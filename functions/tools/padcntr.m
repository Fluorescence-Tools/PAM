function Str = padcntr(Cntr, varargin)
% padcntr pads a number with zeros untill the specified number of digits is reached
    % ----------------------------------------------------------------------------------------------
    %
    %                                          padcntr
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/padcntr.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % Str = padcntr(Number)
    % Str = padcntr(Number, length)
    % Str = padcntr(..., 'Padder', S)
    %
    % DESCRIPTION
    % -----------
    % Str = padcntr(Number) converts the number Number to a string and pads this string with zeros
    % untill three characters are present. If the number is longer than three characters, only the
    % last three numbers are used. A warning message is shown to inform the user about this problem.
    % Number can be either a scalar or a vector of a numbers. If the numbers are not integers, they
    % are rounded to be so.
    %
    % Str = padcntr(Number, length) pads the number with zeros untill length number of characters
    % are present. By default, length is 3.
    % 
    % Str = padcntr(..., 'Padder', S) pads the number with the character entered in S.
    %
    % MODIFICATIONS
    % -------------
    % 
    % 
    % Copyright 2008-2016
    % ==============================================================================================

    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin < 1 || nargin > 4 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [1 4], nargout, 1, mfilename);
    
    end
    
    if ~isscalar(Cntr)
        errorbox('The number has to be a scalar', 'Bad Number', [mfilename ':BadNumber']);
    end
        
    switch nargin 
        case 1
            NDigits =   3;
            Padder  = '0';
            
        case 2
            NDigits = varargin{1};
            if ~isscalar(NDigits)
                errorbox('The number of digits has to be a scalar', 'Bad Number', [mfilename ':BadNumber']);
            end
            Padder  = '0';
            
        case 3
            NDigits = 3;
            if ~strcmpi(varargin{1}, 'padder')
                errorbox('The name of the parameter option is ''Padder''.', 'Bad parameterr', [mfilename ':Badparameter']);
            end
            Padder = varargin{2};
            if ~ischar(Padder) || numel(Padder)~=1
                errorbox('Invalid padding character', 'Invalid padding character', [mfilename ':BadPadChar']);
            end
            
        case 4
            if isscalar(varargin{1})
                % the second input argument is a scalar. This is the length
                % of the output string
                NDigits = varargin{1};
                
                if ~strcmpi(varargin{2}, 'padder')
                    % the third input argument should specify the parameter
                    % 'Padder'
                    errorbox('The name of the parameter option is ''Padder''.', 'Bad parameterr', 'id', [mfilename ':Badparameter']);
                end
                Padder = varargin{3};
                if ~ischar(Padder) || numel(Padder)~=1
                    errorbox('Invalid padding character', 'Invalid padding character', [mfilename ':BadPadChar']);
                end
                
            elseif ~strcmpi(varargin{1}, 'padder')
                % the third input argument should specify the parameter
                % 'Padder'
                errorbox('The name of the parameter option is ''Padder''.', 'Bad parameterr', [mfilename ':Badparameter']);
            
            else
                Padder = varargin{2};
                if ~ischar(Padder) || numel(Padder)~=1
                    errorbox('Invalid padding character', 'Invalid padding character', [mfilename ':BadPadChar']);
                end
                
                NDigits = varargin{3};
                if ~isscalar(NDigits)
                    errorbox('The number of digits has to be a scalar', 'Bad Number', [mfilename ':BadNumber']);
                end
            end
    end
    
    
    % EXECUTION
    % ---------
    
    % convert scalar to string
    Str = num2str(Cntr, '%.0f');

    if length(Str) > NDigits
        % there are more digits than necessary. Remove the unnecessary digits
        warningbox(sprintf('There are more digits than defined by the length (%1.f). Only the last %1.f number(s) will be used.', obj.Length, obj.Length), 'Number too long', 'id', [mfilename ':NumberTooLong'], 'wait', 'off', 'createmode', 'non-modal');

        if NDigits > 1
            Str = Str(end-(NDigits-1):end);
        else
            Str = Str(end);
        end
    else
        % pad the number
        while length(Str) ~= NDigits
             Str = [Padder Str]; %#ok<AGROW>
        end
    end
            
end % end of function 'padcntr'