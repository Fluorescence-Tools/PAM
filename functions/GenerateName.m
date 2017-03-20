function name = GenerateName(name, mode)
if nargin < 2
    mode = 1;
end
if mode == 1
    %% Generate unique file name
    % Generates windows-compatible file names and adds increment when overwriting
    % works only if extension == 3 digits!
    % take only the outer parts of the filename if filename is too long (> 256 characters, path + name) for windows
    if numel(name) > 251
        disp('Sum of filename+filepath was too long for windows. Center part of filename was deleted.')
        a = find(name == filesep);
        filestart = name(1:a(end));
        fileend = name(a(end)+1:end);
        while numel(name) > 251
            if numel(fileend) > 30
                %keep the outer parts of the filename
                fileend = [fileend(1:floor(end/2)-5) fileend(floor(end/2)+5:end)];
                name = [filestart fileend];
            else
                msgbox('FileName cannot be shortened, move file some folders up to render the "Filename + filepath" string shorter than 256 characters')
                return
            end
        end
    end
    % add an underscore if filename existed
    if exist(name, 'file')
        k = 1;
        while exist([name(1:end-4) '_' num2str(k) name(end-3:end)], 'file')
            k = k+1;
        end
        name = [name(1:end-4) '_' num2str(k) name(end-3:end)];
    end
elseif mode == 2
%% Generate unique directory name
    i = 1;
    while i ~= 0
        if ~isdir(name)
            i = 0;
        else
            while exist([name '_' num2str(i)], 'dir')
                i = i+1;
            end
            name = [name '_' num2str(i)];
        end
    end
    mkdir(name)   
end
