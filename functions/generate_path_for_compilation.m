% execute this script from PAM's root folder to obtain a shell script with
% compilation instructions

% get folders
if ~ispc
    folders = strsplit(genpath('functions'),':');
else
    folders = strsplit(genpath('functions'),';');
end
% exclude C_Files folder as it causes an error
remove = find(cell2mat(cellfun(@(x) ~isempty(strfind(x,'C_Files')),folders,'UniformOutput',false)));
folders(remove) = [];

% basic command
command = 'mcc -o PAM -W main:PAM -T link:exe -d PAM_compiled -v Launcher.m -a functions/Custom_Read_Ins -a images -a Models -a functions/bfmatlab/bioformats_package.jar';

% add additonal folders
for i = 1:numel(folders)
    if ~isempty(folders{i})
        command = [command ' -I "' folders{i} '"'];
    end
end

% write bash script
fid = fopen('compile_PAM.sh','w');
fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'%s',command);
fclose(fid);