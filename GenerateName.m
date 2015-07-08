
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generates windows-compatible file names and adds increment %%%%%%%%%%%%
%%% when overwriting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filename = GenerateName(filename)
% works only if extension == 3 digits!


% take only the outer parts of the filename if filename is too long (> 256 characters, path + name) for windows
if numel(filename) > 251
    disp('Sum of filename+filepath was too long for windows. Center part of filename was deleted.')
    a = find(filename == filesep);
    filestart = filename(1:a(end));
    fileend = filename(a(end)+1:end);
    while numel(filename) > 251
        if numel(fileend) > 30
            %keep the outer parts of the filename
            fileend = [fileend(1:floor(end/2)-5) fileend(floor(end/2)+5:end)];
            filename = [filestart fileend];
        else
            msgbox('FileName cannot be shortened, move file some folders up to render the "Filename + filepath" string shorter than 256 characters')
            return
        end
    end
end
% add an underscore if filename existed
if exist(filename, 'file')
    k = 1;
    while exist([filename(1:end-4) '_' num2str(k) filename(end-3:end)], 'file')
        k = k+1;
    end
    filename = [filename(1:end-4) '_' num2str(k) filename(end-3:end)];
end