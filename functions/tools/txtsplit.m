function [stringarray, string] = txtsplit(txt, N)
% txtsplit splits a character string into a cell array with a given maximum number of characters per cell
    % ----------------------------------------------------------------------------------------------
    %
    %                                        txtsplit
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/txtsplit.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % stringarray = txtsplit(text, maxChar)
    % [stringarray string] = txtsplit(text, maxChar)
    %
    % DESCRIPTION
    % -----------
    % stringarray = txtsplit(text, maxChar) splits the character string text into substrings with a
    % maximum lenght of maxChar. These substrings are returned as a cell array. New line characters
    % and carriage return characters are always considered as a break point. Whitespaces and bars
    % are considered as putative break points. Words longer than the maximum allowed number of
    % characters per substring are left as they are.
    % 
    % [stringarray, string] = txtsplit(text, maxChar) returns also a string with new line delimited
    % substrings. This resulting string can directly be used.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2016
    % ==============================================================================================

    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin ~= 2 || nargout > 2
        % use chknarg to generate error
        chknarg(nargin, 2, nargout, [1 2], mfilename);
    
    elseif ~ischar(txt)
        % the first input argument has to be a character string
        
        errorbox('The first input argument has to be a character string.', 'Bad character string', 'id', [mfilename ':BadChar'])
        
    elseif ~isscalar(N) || N <= 0
        % The second input argument has to be a positive scalar
        
        errorbox('The second input argument has to be a positive scalar indicating the number of characters per substring.', 'Bad second input argument', 'id', [mfilename ':BadSecIpt'])
    
    end
    
    % EXECUTION
    % ---------
    
    % remove leading and trailing whitespaces
    txt = strtrim(txt);
    
    % make sure N is a positive integer
    N = max(1, round(N));
    
    % convert cariage return characters to new line characters.
    txt = regexprep(txt, [char(13) '|' char([10 13]) '|' char([13 10])], char(10));
    
    % find all putative break points
    % whitespaces
    ws = txt == char(32);
    % '-'
    bar = txt == '-';
        
    % find all forced break points concerning new line characters
    br = txt == char(10);
    
    % the string will always be split at a new line character
    split_tf = br;
    
    if ~any(split_tf)
        % no new line characters present
        
        % split the text, if necessary, at the whitespaces
        split_tf = splitws(txt, ws, bar, N);
        
    else
        % find the indices of these break points
        br_ix = find(br);
        
        % get the length of the residual string after breaking at the new line
        % characters and after removal of this character
        br_length = [br_ix(1)-1 diff(br_ix)-1 length(txt)-br_ix(end)];
        
        % get the substrings that are longer than the allowed length
        tf_splitfurther = br_length > N;
        
        % find the number of substrings
        max_m = length(br_length);
        
        for m = find(tf_splitfurther)
            % parse through the substrings that are to long
            
            if m == max_m
                % the last substring
                
                % from the last new line character to the end of the string
                ix = br_ix(m-1)+1:length(txt);
                
                % split at whitespaces
                split_tf(ix) = splitws(txt(ix), ws(ix), bar(ix), N);
                                
            elseif m == 1
                % the first substring
                
                % from the start of the string to the first new line
                % character
                ix = 1:br_ix(m)-1;
                
                % split at whitespaces
                split_tf(ix) = splitws(txt(ix), ws(ix), bar(ix), N);
                
                
            else
                % other substrings
                
                % between two new line characters
                ix = br_ix(m-1)+1:br_ix(m)-1;
                
                % split at whitespaces
                split_tf(ix) = splitws(txt(ix), ws(ix), bar(ix), N);
                
            end
            
            
        end
        
    end
    
    % find the indices of all breakpoints
    ix = find(split_tf);
    
    if isempty(ix)
        % no break point
        
        stringarray{1} = txt;
        string = txt;
        
    else
        % several break points found
        
        % allocate memory
        stringarray = cell(length(ix)+1, 1);
        
        for m = 1 : length(ix)+1
            % parse through all substrings
            
            if m == 1
                % the first substring
                stringarray{m} = txt(1:ix(m));
                
            elseif m == length(ix)+1
                % the last substring
                stringarray{m} = txt(ix(m-1):end);
                
            else
                % other substrings
                stringarray{m} = txt(ix(m-1):ix(m));
                
            end
            
        end
        
        % remove leading and strailing whitespaces of each substring
        stringarray = strtrim(stringarray);
        
        % create string in which substrings are separated using new line
        % characters
        temp = [stringarray(:, 1)'; repmat({char(10)}, 1, length(ix)) {''}];
        string = horzcat(temp{:});
        
    end
    
end % end of function 'txtsplit'


%% -------------------------------------------------------------------------------------------------
function split_tf = splitws(txt, ws, bar, N)
    % splitws splits the text at white spaces and bars if necessary
    
    % construct false logical vector
    split_tf = false(size(txt));
    
    % get putative breakpoints
    ws_bar_ix = find(ws|bar);
    
    if nnz(ws_bar_ix) < 1
        % no available breakpoint
        
        return
        
    end
    
    % construct the length of each substring of the string
    ws_bar_length = [ws_bar_ix length(txt)];
    
    if nnz(bar)> 0
        % bars are present
        
        % find the indices
        bar_ix = find(bar);
        
        % deminish the substring length with 1 if it has a trailing
        % whitespace
        ws_bar_length([ws_bar_ix~=bar_ix false]) = ws_bar_length([ws_bar_ix~=bar_ix false])-1;
        
    else
        % deminish the substring length with 1 if it has a trailing
        % whitespace
        ws_bar_length(1:end-1) = ws_bar_length(1:end-1)-1;
        
    end
    
    % find the string that is too long
    ws_bar_split = ws_bar_length > N;
    
    % set old index to 0;
    old_ix = 0;
    
    % get the number of putative breakpoints
    L = length(ws_bar_ix);
    
    while any(ws_bar_split)
        % loop untill every substring is short enough
        
        % find the index of the last whitespace that marks the string that
        % is short enough
        ix = find(~ws_bar_split, 1, 'last');
        
        if isempty(ix)
            % no such position found
            
            if length(ws_bar_split) > 1
                ix = 1;
                
                % indicate the position at which the substring ends
                split_tf(ws_bar_ix(ix)) = true;
                
                % calculate the length of the remaining string
                ws_bar_length = ws_bar_length - ws_bar_length(ix);
                
                % find the string that is too long
                ws_bar_split = ws_bar_length > N;
                
                % remember old index
                old_ix = ix;
                
            end
            
        elseif ix == old_ix
            % it is the same index as the previous one
            
            if ix < L
                ix = ix + 1;
                
            end
            
            % indicate the position at which the substring ends
            split_tf(ws_bar_ix(ix)) = true;
            
            % calculate the length of the remaining string
            ws_bar_length = ws_bar_length - ws_bar_length(ix);
            
            % find the string that is too long
            ws_bar_split = ws_bar_length > N;
            
            % remember old index
            old_ix = ix;
                
        else
            % indicate the position at which the substring ends
            split_tf(ws_bar_ix(ix)) = true;
            
            % calculate the length of the remaining string
            ws_bar_length = ws_bar_length - ws_bar_length(ix);
            
            % find the string that is too long
            ws_bar_split = ws_bar_length > N;
            
            % remember old index
            old_ix = ix;
            
        end
    end
    
end % end of function 'splitws'