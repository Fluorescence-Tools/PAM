function dark_mode(handle)
% Changes normal figure to "dark mode" by changing black->white and
% white->black and setting the background transparent.
% Call this function by passing the figure handle.

if nargin == 0 % no input specified
    handle = gcf;
end

if any(strcmp(handle.Type,'figure')) %%% top level figure, change background to transparent
    handle.Color = 'none';
end

% Change the colors
fields = fieldnames(handle);
for i = 1:numel(fields)
    if any(strcmp(fields{i},{'Color','BackgroundColor','ForegroundColor','EdgeColor','XColor','YColor','ZColor','GridColor','MinorGridColor','TextColor'}))
        if ~strcmp(handle.(fields{i}),'none')
            if all(handle.(fields{i}) == [1 1 1]) && ~strcmp(handle.Type,'uibuttongroup')
                % make transparent
                handle.(fields{i}) = 'none';
            else
                 % invert color
                handle.(fields{i}) = [1 1 1] - handle.(fields{i});
            end
        end
    end
end

for i = 1:numel(handle.Children)
    if any(strcmp(handle.Children(i).Type,{'axes','legend','text','uibuttongroup','colorbar'}))
        dark_mode(handle.Children(i)); % recursive looping over children
    end
end

