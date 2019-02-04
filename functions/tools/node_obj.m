classdef node_obj < handle
    
    properties
        name@char
        value
        next@node_obj = node_obj.empty
        previous@node_obj = node_obj.empty
        children@node_obj = node_obj.empty
        parent@node_obj = node_obj.empty
    end
    
    properties (Dependent)
        ancestors
        ancestor
        siblings
        next_serial_node
        previous_serial_node
        level
    end
    
    methods
        
        %% -----------------------------------------------------------------------------------------
        function obj = node_obj(varargin)
            % node_obj is the constructor function and returns a node object
            
            if nargin == 1
                % only 1 input argument defined. This has to be the name of the node
                obj.name = varargin{1};
            end
            
        end % end of constructor function 'node_obj'
        
        
        %% -----------------------------------------------------------------------------------------
        function child = append_child(obj,varargin)
            % append_child appends a node object to the list of children
            
            child = node_obj(varargin{:});
            % add the current object as the parent
            child.parent = obj;
            
            if ~isempty(obj.children)
                obj.children(end+1,1) = child;
                obj.children(end-1,1).next = child;
                child.previous = obj.children(end-1,1);
            else
                obj.children(end+1,1) = child;
            end
            
        end % end of subfunction 'append_child'
        
        
        %% -----------------------------------------------------------------------------------------
        function next = append_next(obj,varargin)
            % append_next appends a node object to the list of nodes
            
            next = node_obj(varargin{:});
            % add the current object as the next node
            obj.next = next;
            next.parent = obj.parent;
            next.previous = obj;
            
        end % end of subfunction 'append_next'
        
        
        %% -----------------------------------------------------------------------------------------
        function obj_list = get.ancestors(obj)
            obj_list = node_obj.empty(0,1);
            while ~isempty(obj.parent)
                obj = obj.parent;
                obj_list(end+1,1) = obj.name;
            end
            
            if numel(obj_list) > 1
                obj_list = obj_list(end:-1:1,1);
            end
            
        end % end of subfunction 'get.ancestors'
        
        
        
        %% -----------------------------------------------------------------------------------------
        function obj_list = get.siblings(obj)
            obj_list = node_obj.empty(0,1);
            if ~isempty(obj.parent)
                obj_list = obj.parent.children;
            end
            
        end % end of subfunction 'get.siblings'
        
        
        %% -----------------------------------------------------------------------------------------
        function ancestor = get.ancestor(obj)
            ancestor = obj;
            while ~isempty(ancestor.parent)
                ancestor = ancestor.parent;
            end
            
        end % end of subfunction 'get.ancestors'
        
        
        function node = get.next_serial_node(obj)
            % next_serial_node returns the next node, thereby ignoring the different nesting levels
            
            if ~isempty(obj.children)
                node = obj.children(1);
            elseif ~isempty(obj.next)
                node = obj.next;
            else
                while true
                    if ~isempty(obj.parent)
                        obj = obj.parent;
                        if ~isempty(obj.next)
                            node = obj.next;
                            break
                        end
                    else
                        node = node_obj.empty;
                        break
                    end
                end
            end
            
        end % end of subfunction 'next_serial_node'
        
        function level = get.level(obj)
            
            level = numel(obj.ancestors);
            
        end % end of subfunction 'get.level'
        
    end
    
end % end of object 'node'