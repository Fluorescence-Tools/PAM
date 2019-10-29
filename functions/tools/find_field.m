function [value, str, n] = find_field(s, field, varargin)
% find_field returns the content of the specified field in the structure
	% ----------------------------------------------------------------------------------------------
    %
    %                                      find_field
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-09 14:17:53 +0100 (Tue, 09 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 12 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/find_field.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % [value, str] = find_field(s, field)
    % [value, str] = find_field(s, field, n)
    % [value, str] = find_field(..., '-depth', L)
    % [value, str, n_fields] = find_field(...)
    % 
    % DESCRIPTION
    % -----------
    % [value, str] = find_field(s, field) returns the content of the specified field in the
    % structure. str holds the string as would be regularly used to retrieve the information. s is
    % the structure and field is the fieldname of interest. The number of fields found in the
    % structure is unlimited. Also note that in case of a non-scalar structure, only the first
    % index is returned.
    %
    % [value, str] = find_field(s, field, n) limits the maximum number of matches to n.
    % 
    % [value, str] = find_field(..., '-depth', L) limits the recursion of the procedure to L levels,
    % where L is a positive scalar. The first fields of the structure are level 1.
    % 
    % [value, str, n_fields] = find_field(...) returns an extra output argument n_fields, specifying
    % the number of occurences of the field in the structure as returned by the function.
    % 
    % copyright 2018
    % ==============================================================================================
    
    
    % INITIALIZATION
    % --------------
    
    % set default values
    opts.n     = inf; % the maximum number of fields that should be returned
    opts.depth = inf; % the level to which the field has to be searched in.
    
    % check number of input and output arguments
    if nargin < 2 || nargin > 5 || nargout > 2
        % use chknarg to generate error
        chknarg(nargin, [2 5], nargout, [0 2], mfilename);
        
    elseif ~isstruct(s)
        % the first input argument has to be a structure
        errorbox('The first input argument has to be a valid structure.', 'Bad structure', [mfilename ':BadStruct']);
        
    elseif isempty(field) || ~ischar(field)
        % the field has to be a valid character string
        errorbox('The second input argument defining the field has to be a valid character string.', 'Bad field definition', [mfilename ':BadField']);
        
    elseif ~isempty(varargin)
        
        L = length(varargin); % total number of input arguments
        c = 0;                % counter to keep track of input argument
        
        while c < L
            % increase the counter
            c = c + 1;
            
            if isnumeric(varargin{c}) && isscalar(varargin{c})
                % this is the maximum number of instances of the field that has to be returned.
                opts.n = varargin{c};
                continue
            end               
            
            % parse through all remaining parameter - parameter value pairs
            switch lower(varargin{c})
                case {'depth' '-depth'}
                    % the level to which the field has to be searched in.
                    if isempty(varargin{c+1}) || (~isscalar(varargin{c+1}) || ~isnumeric(varargin{c+1}) || varargin{c+1}<0)
                        errorbox('The dimension option ''total_size'' should be a positive number.', 'Bad dimension option ''total_size''', [mfilename ':BadTotSize']);
                    else
                        opts.depth = round(varargin{c+1});
                        c = c + 1; % increase the counter
                    end
                    
                otherwise
                    % parameter not recognized
                    errorbox(['The parameter ''' varargin{c} ''' is not supported by ' mfilename '.'], 'Optional parameter not supported', [mfilename ':BadOptionalIpt']);
                    
            end
            
        end % end of while loop
        
    end % end of input parsing
    
    
    % EXECUTION
    % ---------
    
    found = fnd_field(s, field, {inputname(1)}, opts);
    
    if isempty(found)
        n = 0;
        value = [];
        str = '';
    else
        n = size(found,1);
        if n == 1
            b = [[found{1,2}; found{1,1}], num2cell(repmat({1}, found{1,3}+1,1))]';
            b(end) = {{}};
            value = getfield(s, b{:,2:end});
            str = strjoin([found{1,2}; found{1,1}], '.');
        else
            for m = 1 : n
                % get the value of this field
                b = [[found{m,2}; found{m,1}], num2cell(repmat({1}, found{m,3}+1,1))]';
                b(end) = {{}};
                value{m,1} = getfield(s, b{:,2:end});
                str{m,1} = strjoin([found{m,2}; found{m,1}], '.');
            end
        end
    end
    
    
end % end of function 'find_field'


%% -------------------------------------------------------------------------------------------------
function found = fnd_field(s, field, parents, opts, found, level, size_of_parent, last_field)
% fnd_field does the actual structure parsing
    
    if nargin == 4
        % define start values
        level = 1;
        size_of_parent = [1 1];
        found = cell(0,5); % No preallocation required
    end
    
    % get the fieldnames of the structure
    fields = fieldnames(s);
    
    % compare the fields
    tf = strcmp(field, fields);
    
    if any(tf)
        ix = find(tf);
        
        for m = ix'
            if size(found,1) == opts.n
                return
            end
            found(end+1,:) = {fields{m} parents level size_of_parent last_field}; %#ok<*AGROW>
        end
    end
    
    for m = 1 : length(fields)
        % parse through all field names
        
        if size(found,1) == opts.n
            return
        end
        
        if isstruct(s(1).(fields{m})) && level < opts.depth
            % get the info from the subfield.
            found = fnd_field(s(1).(fields{m}), field, [parents(:); fields(m)], opts, found, level + 1, size(s(1).(fields{m})), m == length(fields));
        end
    end
        
end % end of subfunction 'fnd_field'