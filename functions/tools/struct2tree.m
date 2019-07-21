function mtree = struct2tree(s)

%     % Fruits
% fruits = uitreenode('v0', 'Fruits', 'Fruits', [], false);
% fruits.add(uitreenode('v0', 'Apple',  'Apple',  [], true));
% fruits.add(uitreenode('v0', 'Pear',   'Pear',   [], true));
% fruits.add(uitreenode('v0', 'Banana', 'Banana', [], true));
% fruits.add(uitreenode('v0', 'Orange', 'Orange', [], true));
%  
% % Vegetables
% veggies = uitreenode('v0', 'Veggies', 'Vegetables', [], false);
% veggies.add(uitreenode('v0', 'Potato', 'Potato', [], true));
% veggies.add(uitreenode('v0', 'Tomato', 'Tomato', [], true));
% veggies.add(uitreenode('v0', 'Carrot', 'Carrot', [], true));
%  
% % Root node
% root = uitreenode('v0', 'Food', 'Food', [], false);
% root.add(veggies);
% root.add(fruits);
%  
% % Tree
% figure('pos',[300,300,150,150]);
% mtree = uitree('v0', 'Root', root);
    root = uitreenode('v0', 'Structure', 'Structure', [], false);
    root = mknode(s, root);
    
    mtree = uitree('v0', 'Root', root);
end % end of function 'struct2tree'


function root = mknode(s, root)
    
    f_list = fieldnames(s);
    
    for m = 1 : length(f_list)
        current = uitreenode('v0', f_list{m}, f_list{m}, [], false);
%         f_list{m}
%         s.(f_list{m})
        if numel(s.(f_list{m})) > 1
            
        elseif isstruct(s.(f_list{m}))
            
            current = mknode(s.(f_list{m})(1), current);
%             for m = 1 : length(s.(f_list{m}))
%                 if isstruct(s.(f_list{m}))
%                     current = mknode(s.(f_list{m}), current);
%                 end
%             end
        end
        root.add(current);
        
    end
    
end % end of subfunction 'get_txt'