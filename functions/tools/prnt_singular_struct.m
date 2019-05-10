function txt = prnt_singular_struct(s)
    
    level = 0;
    txt = sprintf('structure\n |\n |\n');
    txt = get_txt(s, level, txt, '');
    
end % end of subfunction 'prnt_singular_struct'

function txt = get_txt(s, level, txt, prefix)
    
    f_list = fieldnames(s);
    level = level + 1;
    for m = 1 : length(f_list)
        if m == length(f_list)
            if isstruct(s.(f_list{m}))
            txt = [txt sprintf('%s%s%s\n', [prefix], ' +--> ', f_list{m})];
%             if isstruct(s.(f_list{m}))
                txt = get_txt(s.(f_list{m}), level, txt, [prefix '    ']);
            end
        else
            if isstruct(s.(f_list{m}))
            txt = [txt sprintf('%s%s%s\n', [prefix], ' +--> ', f_list{m})];
%             if isstruct(s.(f_list{m}))
%                 level = level + 1;
                txt = get_txt(s.(f_list{m}), level, txt, [prefix ' |  ']);
            end
        end
    end
    
end % end of subfunction 'get_txt'