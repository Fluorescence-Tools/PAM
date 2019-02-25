function obj = struct2nodes(s, obj)
    
    % list is a cell array: name, cell array of parents, level (0 based), size of parent
    if nargin == 1
        obj = node_obj(inputname(1));
    end
    
    if isstruct(s)
        temp = fieldnames(s);
        
        for m = 1 : length(temp)
            try
                 c_obj = obj.append_child(temp{m});
            catch ME2
                ME2
                'boe2'
            end
            
            if isstruct(s(1).(temp{m}))
            try
                struct2nodes(s(1).(temp{m}), c_obj);
            catch ME
                ME
                'boe'
            end
            else
                c_obj.value = s(1).(temp{m});
                
            end
        end
        
    else
        obj.value = s;
        
    end
    
end % end of function 'struct2node'