function print_struct(s)
% print_struct displays all fields of the defined structure in the command window
	% ----------------------------------------------------------------------------------------------
    %
    %                                     print_struct
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/print_struct.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % print_struct(s)
    % 
    % DESCRIPTION
    % -----------
    % print_struct displays the defined structure in the command window as a tree, including
    % hyperlinks to each field and their values.
    % 
    % copyright 2017-2018
    % ==============================================================================================
     
    % INITIALIZATION
    % --------------
    
    % check number of output arguments
    if nargin ~= 1 || nargout > 0
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, 0, mfilename);
    elseif ~isstruct(s)
        error([mfilename ':NoStruct'], ['The input argument ''' inputname(1) ''' is not a valid structure.']);
    end
    
    
    % EXECUTION
    % ---------
    
    use_node_obj = false;
    
    % get the name of the structure
    structname = inputname(1);
    if length(structname) < 2
        txt = [newline structname newline char(124) newline];
    else
        txt = [newline structname newline ' ' char(124) newline];
    end
    
    if use_node_obj
        
        % get all fields of structure
        nodes = struct2nodes(s);
        
        % adjust the name of the first node
        nodes.name = structname;
        
        % parse through all entries
        while ~isempty(nodes.next_serial_node)
            nodes = nodes.next_serial_node;
            
            level = nodes.level;
            if level == 1
                if length(structname) < 2
                    prefix{1} = '';
                else
                    prefix{1} = ' ';
                end
            elseif isempty(nodes.parent.next)
                prefix{level+1} = '    ';
            else
                prefix{level+1} = [char(124) '   '];
            end
            
            % construct the path to this field in the variable workspace
            structstr = strjoin([{nodes.ancestors.name}'; {nodes.name}], '.');
            name = ['<a href="matlab: openvar(''' structstr ''')">' nodes.name '</a>'];
            
            % get the value of this field
            b = [[{nodes.ancestors.name}'; nodes.name], num2cell(repmat({1}, level+1,1))]';
            b(end) = {{}};
            try
                val = getfield(s, b{3:end});
            catch
                val = '';
            end
            
            if isstruct(val)
                % the value is a structure. Show its size when it is not a scalar
                if ~isscalar(val)
                    dims = size(val);
                    name = [name ' (' num2str(dims(1)) char(215) num2str(dims(2)) ' struct)'];
                end
                
%             elseif prod(list{m,4}) > 1 && nnz(list{m,4}>1) == 1
%                 % the parent structure is not scalar
%                 
%                 vartxt = {};
%                 for k = 1 : max(list{m,4})
%                     b{2,end-1} = {k};
%                     vartxt{k,1} = var2text(getfield(s, b{:,2:end}));
%                 end
%                 vartxt = strjoin(vartxt, ' | ');
%                 if ~isempty(vartxt)
%                     name = [name ': ' vartxt];
%                 end
                
            else
                vartxt = var2text(val);
                if ~isempty(vartxt)
                    name = [name ': ' vartxt];
                end
            end
            
            txt = [txt prefix{1:level+1} '+-- ' name newline];
            
        end
        
        fwrite(1, txt)
    
    
    else
        % use cell array approach
        
        % get all fields of structure as a cell array, with optional information
        list = get_all_fieldnames_from_struct(s);
        
        % replace the first entry in each cell array in the second column of list to the name of the
        % structure
        for m = 2 : size(list,1)
            list{m,2}{1} = structname;
        end
        
        % parse through all entries
        for m = 2 : size(list,1)
            
            % set the prefix
            if list{m,3} == 1
                if length(structname) < 2
                    prefix{1} = '';
                else
                    prefix{1} = ' ';
                end
            elseif list{m,5}
                % this is the last field in the current series
                prefix{list{m,3}} = '    '; %#ok<*AGROW>
            else
                prefix{list{m,3}} = [char(124) '   '];
            end
            
            % construct the path to this field in the variable workspace
            structstr = strjoin([list{m,2}; list(m,1)], '.');
            name = ['<a href="matlab: openvar(''' structstr ''')">' list{m,1} '</a>'];
            
            % get the value of this field
            b = [[list{m,2}; list{m,1}], num2cell(repmat({1}, list{m,3}+1,1))]';
            b(end) = {{}};
            try
                val = getfield(s, b{:,2:end});
            catch
                val = '';
            end
            
            if isstruct(val)
                % the value is a structure. Show its size when it is not a scalar
                if ~isscalar(val)
                    dims = size(val);
                    name = [name ' (' num2str(dims(1)) char(215) num2str(dims(2)) ' struct)'];
                end
                
            elseif prod(list{m,4}) > 1 && nnz(list{m,4}>1) == 1
                % the parent structure is not scalar
                
                vartxt = {};
                for k = 1 : max(list{m,4})
                    b{2,end-1} = {k};
                    vartxt{k,1} = var2text(getfield(s, b{:,2:end}));
                end
                vartxt = strjoin(vartxt, ' | ');
                if ~isempty(vartxt)
                    name = [name ': ' vartxt];
                end
                
            else
                vartxt = var2text(val);
                if ~isempty(vartxt)
                    name = [name ': ' vartxt];
                end
            end
            
            txt = [txt prefix{1:list{m,3}} '+-- ' name newline];
            
        end
        
        % print the info in the command window
        fwrite(1, txt)
        
    end
    
end % end of function 'print_struct'