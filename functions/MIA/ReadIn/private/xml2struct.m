function [S] = xml2struct(xml)
% xml2struct converts xml data into a matlab structure

% '<' and '>' should never be used except for markup language
    
    % create a structure to save the data to
    S = struct;
    
    % find all opening brackets 
    start = strfind(xml , '<');

    % find all closing brackets 
    stop = strfind(xml , '>');
    
    if numel(start) ~= numel(stop)
        errorbox(['There should be an equal amount of opening and closing brackets. However, in this text ' num2str(numel(start)) ' opening and ' num2str(numel(stop)) ' closing brackets are found.'], [mfilename ':BadNBrackets']);
        
    end
    
    % construct ix_lines matrix to hold indices of start and stop of each line. As a result, each
    % row defined the start and stop of each line. Also include text in between closing and starting
    % bracket. This approach is preferred above sorting to save time.
    ix_lines = [reshape([start(1:end-1); stop(1:end-1); stop(1:end-1); start(2:end)], 2, [])'; start(end) stop(end)]; 
        
    % create a cell array to keep track of levels and indices
    levels = {};

    for m = 1 : size(ix_lines,1)
        % get the current element, but get rid of the first '<' and last '>'
        
        if ix_lines(m,2)-ix_lines(m,1) <= 1
            % text is shorter than 1 character. Skip it to save time
            continue
        end
        txt = xml(ix_lines(m,1)+1:ix_lines(m,2)-1);
        
        if txt(1) == '/'
            % the current level was closed
            % go back 1 level
%             levels
            levels(:,end) = [];
            continue
            
        elseif all(txt == char(32) | txt == char(9) | txt == char(13) | txt == char(10)) %#ok<*CHARTEN>
            % skip text that only has whitespace characters
            continue
            
        % treat text between brackets different than values outside brackets    
        elseif rem(m,2) == 1
            
            if txt(end) == '/'
                txt(end) = [];
                endlevel = true;
            else
                endlevel = false;
            end
            
            % find the first whitespace. The text before the first whitespace is the name of the
            % current element
            ix = strfind(txt, ' ');
            if isempty(ix)
                name = txt;
                rest = '';
            else
                name = txt(1:ix-1);
                rest = txt(ix+1:end);
            end
            name = lower(name);
%             name
%             rest
%             if strcmpi(name, 'Data')
%                                 'stop hier'
%                             end
            
            
            if ~isempty(rest)
                if isempty(levels)
                    current_index = 1;
                else
                    try
%                         if strcmpi(name, 'data')
%                             levels{1,end}
%                             'stop'
%                         end
                        f = getfield(S, levels{:,1:end-1}, levels{1,end});
                        
                        if isfield(f, name)
                            
                            if isempty(f.(name))
                                current_index = 1;
                            else
                                current_index = length(f.(name))+1;
                            end
%                             if strcmpi(name, 'Element')
%                                 'stop';
%                             end
                        else
                            current_index = 1;
                        end
                    catch
                        current_index = 1;
                    end
                end
                
                ix = [-1 find(rest == '"')];
                
                if rem(length(ix),2) ~= 1
                    error('Not allowed. Apostrophs should come in pairs.')
                end
                
                
                for a = 1 : length(ix)/2
                    at_val = rest(ix(a*2)+1:ix((a*2)+1)-1);
                    if isempty(at_val) || ~isdigit(at_val(1))
%                         temp{4}
                        if any(strcmpi(at_val, {'false', 'true'}))
                            if length(at_val) == 4
                                at_val = true;
                            else
                                at_val = false;
                            end
                        end
                        
                    else
                        val = str2double(at_val);
                        if isnan(val)
                            if any(strcmpi(at_val, {'false', 'true'}))
                                if length(at_val) == 4
                                    at_val = true;
                                else
                                    at_val = false;
                                end
                            end
                        else
                            at_val = val;
                        end
                    end
%                     rest
%                     rest(ix((a-1)*2+1)+2:ix(a*2)-2)
                    
                    S = setfield(S, levels{:}, name, {current_index}, rest(ix((a-1)*2+1)+2:ix(a*2)-2), {1:length(at_val)}, at_val);
                end
            else
                if isempty(levels)
                    current_index = 1;
                else
                    try
%                         if strcmpi(name, 'data')
%                             levels{1,end}
%                             'stop'
%                         end
                        f = getfield(S, levels{:,1:end-1}, levels{1,end});
                        
                        if isfield(f, name)
                            
                            if isempty(f.(name))
                                current_index = 1;
                            else
                                current_index = length(f.(name))+1;
                            end
%                             if strcmpi(name, 'Element')
%                                 'stop';
%                             end
                        else
                            current_index = 1;
                        end
                    catch
                        current_index = 1;
                    end
                end
            end
            
            
            
            
            if ~endlevel
                % start a new level
%                 levels
%                 txt
                levels(:,end+1) = {name; {current_index}};
            end
        else
            at_val = txt;
                    if isempty(at_val) || ~isdigit(at_val(1))
%                         temp{4}
                        if any(strcmpi(at_val, {'false', 'true'}))
                            if length(at_val) == 4
                                at_val = true;
                            else
                                at_val = false;
                            end
                        end
                        
                    else
                        val = str2double(at_val);
                        if isnan(val)
                            if any(strcmpi(at_val, {'false', 'true'}))
                                if length(at_val) == 4
                                    at_val = true;
                                else
                                    at_val = false;
                                end
                            end
                        else
                            at_val = val;
                        end
                    end
%                     rest
%                     rest(ix((a-1)*2+1)+2:ix(a*2)-2)
                    
                    try
                        S = setfield(S, levels{1:end-1}, {1:length(at_val)}, at_val);
                    catch
                        try s = getfield(S, levels{:});
                            S = setfield(S, levels{:}, 'value', {1:length(at_val)}, at_val);
                        catch
                            S = setfield(S, levels{1:end-1}, {1:length(at_val)}, at_val);
                        end
                    end
              
            
            % this is pure text, in between 2 xml items
%             txt
%             txt
%             txt = xml(ix_lines(m,1)-10:ix_lines(m,2)+10)
        
    end
        
        
            

    end % end of for loop
        
    
    
    return
        if t(2) == '/'
            % closing of group
            % return the function
            return
            
        else
            
            if numel(strfind(t, '>')) == 1
                temp = regexp(t, '\<(\w*)\s*([\d\w\s\.\|\-\_\:\$\+\(\)\=\"]*)?(\/)?\s*[\>]', 'tokens', 'once');
                % insert empty element in the cell array
                temp{5} = [];
            else
                % interpret the xml element
                temp = regexp(t, '\<(\w*)\s*([\d\w\s\.\|\-\_\:\$\+\(\)\=\\/"]*)?(\/)?\s*[\>]([\#\d\w\s\.\|\-\_\:\;\$\+\(\)\=\&\#\"\,\/]*)?[\<]?(\/)?(\w*)?[\>]', 'tokens', 'once');
            end
            
            % temp = {groupname, options, end, value, end, groupname};
            % Does the xml element end in this line
            closed_tf = ~isempty(temp{3}) || ~isempty(temp{5});
            
            % get a valid fieldname from the groupname.
            fieldname = matlab.lang.makeValidName(lower(temp{1}));
            
            if ~isempty(temp{4})
                % a value is defined
                if closed_tf && isempty(temp{2})
                    % there are no children and no options defined. value will be the only content
                    
                    % convert the value to a matlab format
                    if isempty(temp{4}) || ~isdigit(temp{4}(1))
%                         temp{4}
                        if any(strcmpi(temp{4}, {'false', 'true'}))
                            if length(temp{4}) == 4
                                temp_struct = true;
                            else
                                temp_struct = false;
                            end
                        else
                            temp_struct = temp{4};
                        end
                        
                    else
                        val = str2double(temp{4});
                        if isnan(val)
                            if any(strcmpi(temp{4}, {'false', 'true'}))
                                if length(temp{4}) == 4
                                    temp_struct = true;
                                else
                                    temp_struct = false;
                                end
                            else
                                temp_struct = temp{4};
                            end
                        else
                            temp_struct = val;
                        end
                    end
                    
                else
                    % try to convert to double.
                    % convert the value to a matlab format
                    if isempty(temp{4}) || ~isdigit(temp{4}(1))
%                         temp{4}
                        if any(strcmpi(temp{4}, {'false', 'true'}))
                            if length(temp{4}) == 4
                                temp_struct.value = true;
                            else
                                temp_struct.value = false;
                            end
                        else
                            temp_struct.value = temp{4};
                        end
                        
                    else
                        val = str2double(temp{4});
                        if isnan(val)
                            if any(strcmpi(temp{4}, {'false', 'true'}))
                                if length(temp{4}) == 4
                                    temp_struct.value = true;
                                else
                                    temp_struct.value = false;
                                end
                            else
                                temp_struct.value = temp{4};
                            end
                        else
                            temp_struct.value = val;
                        end
                    end
                end
            else
                % No value
                temp_struct = ([]);
            end
            
            
            if ~isempty(temp{2})
                % there are options defined
                temp_struct = options2struct(temp{2}, temp_struct);
            end
            
            
            if ~closed_tf
                % there are children present
                [temp_struct, clevel, xml, cntr] = xml2struct(xml, ix_lines, cntr, clevel, temp_struct);

            end

            if isfield(S, fieldname)
                % the field already exists. Try to create an array of structures. This assumes that
                % the structure is always the same.
                N = length(S.(fieldname))+1;
                
                if isstruct(S.(fieldname))
                    try
                        S.(fieldname)(N,1) = temp_struct;
                    catch
                        S.(fieldname) = {S.(fieldname)};
                        S.(fieldname){N,1} = temp_struct;
                    end
                elseif iscell(S.(fieldname))
                    S.(fieldname){N,1} = temp_struct;
                else
                    S.(fieldname)(N,1) = temp_struct;
                end
%                 fieldname
%                 S.(fieldname)
            else
                % the fieldname does not exist yet
                
                try
                    S.(fieldname) = temp_struct;
                    
                catch ME
                    if ~iscell(S)
                        k.unknown = S;
                        S = k;
                        S.(fieldname) = temp_struct;
                    else
                        throw(ME)
                    end
                        
                end
            end
            
        end
        
        
        
    
    
end % end of function 'xml2struct'


%% -------------------------------------------------------------------------------------------------
function S = options2struct(txt, S)
% options2struct parses the properties of the xml element and converts them to a matlab structure
    
    % use regexp to convert the properties
    temp = regexp(txt, '([^\=]*)\="([^\"]*)"\s*', 'tokens');
    
    % alter the cell array dimensions into an easy to parse configuration
    temp = cat(1,temp{:});
        
    for m = 1 : size(temp,1)
        % create a valid field name
        name = matlab.lang.makeValidName(temp{m,1});
        
        if isempty(temp{m,2}) || ~isdigit(temp{m,2}(1))
            if any(strcmpi(temp{m,2}, {'false', 'true'}))
                if length(temp{m,2}) == 4
                    S.(name) = true;
                else
                    S.(name) = false;
                end
            else
                S.(name) = temp{m,2};
            end
            continue
        else
            val = str2double(temp{m,2});
            if isnan(val)
                
                if any(strcmpi(temp{m,2}, {'false', 'true'}))
                    if length(temp{m,2}) == 4
                        S.(name) = true;
                    else
                        S.(name) = false;
                    end
                    
                else
                    S.(name) = temp{m,2};
                end
            else
                S.(name) = val;
            end
        end
        
    end
end % end of subfunction 'options2struct'
