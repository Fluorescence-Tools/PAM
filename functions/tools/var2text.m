function txt = var2text(var)
% var2text returns a string that describes the variable similar as returned by the display function
	% ----------------------------------------------------------------------------------------------
    %
    %                                         var2text
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/support%20fcns/var2text.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % txt = var2text(var)
    % 
    % DESCRIPTION
    % -----------
    % txt = var2text(var) returns a string that describes the variable similar as returned by the
    % display function.
    % 
    % copyright 2018
    % ==============================================================================================
    
    % INITIALIZATION
    % --------------
    
    % check number of output arguments
    if nargin ~= 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
    end
    
    
    % EXECUTION
    % ---------
    
    if ischar(var)
        % the input argument is a character string
        
        % replace newline characters with a symbol
        var(var==newline) = char(182);
        % set the maximum string length that will be displayed.
        N = 50;
        if length(var) > N
            txt = ['''' var(1:N) '...'''];
        else
            txt = ['''' var ''''];
        end
        
    elseif isnumeric(var)
        % the input argument is numeric
        if isscalar(var)
            txt = num2str(var);
            
        elseif isrow(var)
            for c = 1 : min(length(var),10)
                if c == 1
                    txt =  ['[' num2str(var(c))];
                elseif c == 10 || c == length(var)
                    if length(var) > 10
                        txt = [txt ' ' num2str(var(c)) ' ...]'];
                    else
                        txt = [txt ' ' num2str(var(c)) ']'];
                    end
                    break
                else
                    txt = [txt ' ' num2str(var(c))];
                end
            end
            
        elseif iscolumn(var)
            for c = 1 : min(length(var),10)
                if c == 1
                    txt = ['[' num2str(var(c))];
                elseif c == 10 || c == length(var)
                    if length(var) > 10
                        txt = [txt '; ' num2str(var(c)) ' ...]'];
                    else
                        txt = [txt '; ' num2str(var(c)) ']'];
                    end
                    break
                else
                    txt = [txt '; ' num2str(var(c))];
                end
            end
            
        else
            dims = size(var);
            for m = 1 : length(dims)
                if m == 1
                    txt = ['[' num2str(dims(m))];
                else
                    txt = [txt char(215) num2str(dims(m))];
                end
            end
            txt = [txt ' ' class(var) ']'];
            
        end
        
    elseif islogical(var) && isscalar(var)
        % the input argument is a logical
        if var
            txt = 'true';
        else
            txt = 'false';
        end
        
    elseif iscell(var)
        % the input argument is a cell array
        if isscalar(var)
            txt = ['{' var2text(var{1}) '}'];
        elseif isrow(var) && length(var)<=5
            for c = 1 : min(length(var),5)
                if c == 1
                    txt =  ['{' var2text(var{c})];
                else
                    txt = [txt ' ' var2text(var{c})];
                end
            end
            txt = [txt '}'];
        else
            dims = size(var);
            for m = 1 : length(dims)
                if m == 1
                    txt = ['{' num2str(dims(m))];
                else
                    txt = [txt char(215) num2str(dims(m))]; %#ok<*AGROW>
                end
            end
            txt = [txt ' cell}'];
        end
        
    else
        txt = '';
    end


end % end of function 'var2text'