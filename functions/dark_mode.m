function dark_mode(handle)
% Changes normal figure to "dark mode" by changing black->white and
% white->black and setting the background transparent.
% Call this function by passing the figure handle.

if any(strcmp(handle.Type,'figure')) %%% top level figure, change background to transparent
    handle.Color = 'none';
end

% Change the colors
fields = fieldnames(handle);
for i = 1:numel(fields)
    if any(strcmp(fields{i},{'Color','BackgroundColor','ForegroundColor','EdgeColor','XColor','YColor','ZColor','GridColor','MinorGridColor','TextColor'}))
        if ~strcmp(handle.(fields{i}),'none')
            % invert color
            handle.(fields{i}) = [1 1 1] - handle.(fields{i});
        end
    end
end

for i = 1:numel(handle.Children)
    if any(strcmp(handle.Children(i).Type,{'axes','legend','text'}))
        dark_mode(handle.Children(i)); % recursive looping over children
    end
end

