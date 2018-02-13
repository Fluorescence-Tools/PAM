function Txt = startwithcapital(txt)
% startwithcapital returns the string with the first letter a capitalized 
    % ----------------------------------------------------------------------------------------------
    %
    %                                      startwithcapital
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/startwithcapital.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % Txt = startwithcapital
    %
    % DESCRIPTION
    % -----------
    % Txt = startwithcapital(txt) returns the input string with the first
    % letter capitalized.
    % 
    % NOTE
    % ----
    % This function will also remove leading and trailing whitespaces.
    % 
    % ACKNOWLEDGEMENTS
    % ----------------
    %
    % copyright 2008-2016
    % ==============================================================================================
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin ~= 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
    
    elseif isempty(txt)
        % the input string is empty. Return empty string and stop the
        % function
        
        Txt = '';
        return
        
    elseif ~ischar(txt) && ~iscellstr(txt)
        % the input argument has to be either empty, a valid character
        % string or a cell array of chracter strings
        errorbox('The input argument has to be either empty, a valid character string or a cell array of chracter strings.', 'Invalid string', 'id', [mfilename ':InvalidString'])
        
    end
    
    
    % EXECUTION
    % ----------
    
    % remove leading and trailing whitespaces
    txt = strtrim(txt);
    
    if iscell(txt)
        % the input arugment is a cell array
        
        % allocate memory
        Txt = txt;
        
        for m = 1 : numel(txt)
            % parse through all cells
            
            if length(txt{m}) > 1
                % the string is more than one character long
                
                % capitalize the first letter
                Txt{m} = [upper(txt{m}(1)) txt{m}(2:end)];
                
            else
                % input argument is only one character long

                % capitalize the first letter
                Txt{m} = upper(txt{m});

            end
            
        end
        
    elseif length(txt) > 1
        % the input argument is a character string of at least two characters
        
        % capitalize the first letter
        Txt = [upper(txt(1)) txt(2:end)];
        
    else
        % input argument is only one character long
        
        % capitalize the first letter
        Txt = upper(txt);
        
    end
    
end % end of function 'startwithcapital'