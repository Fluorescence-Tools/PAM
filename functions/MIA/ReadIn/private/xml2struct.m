function [S, clevel, txt, cntr] = xml2struct(txt, ix_lines, cntr, clevel, S)
    % txt2data returns the structure with all data based on the text
    
    
    % make sure that S exists
    if nargin == 1
        clevel = 0;
        cntr = 0;
        S = struct;
        
        [stop, start] = regexp(txt, [newline '\s*\<'], 'start', 'end');
        
        if isempty(stop)
            error('no xml')
            return
        end
        
        % construct ix_lines matrix to hold indices of start and stop of each line. As a result, each
        % row defined the start and stop of each line.
        ix_lines = [[1; start(1:end-1)'+1] stop'-1];
        
        
    elseif nargin < 5
        S = struct;
    end
    
%     % stop the function when all txt are parsed
%     if isempty(txt); return; end;
    
    % get the number of remaining lines
    level_initL = length(ix_lines) - cntr;
    
    % keep track of the number of iterations
    Nit = 0;
    
    % parse through all txt
    while level_initL > 0 && Nit <= level_initL && cntr < length(ix_lines)
        % increase the external iteration counter
        cntr = cntr + 1;
        
        % increase the iteration counter
        Nit = Nit + 1;
        
        % get the current element
        t = txt(ix_lines(cntr,1):ix_lines(cntr,2));
        
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
                [temp_struct, clevel, txt, cntr] = xml2struct(txt, ix_lines, cntr, clevel, temp_struct);

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
                else
                    S.(fieldname){N,1} = temp_struct;
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
        
        
        
%         t
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
