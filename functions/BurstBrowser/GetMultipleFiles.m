function Files = GetMultipleFiles(FilterSpec,Title,PathName)
FileName = 1;
count = 0;
PathName= fullfile(PathName,'..',filesep);%%% go one layer above since .*bur files are nested
Files = [];
while FileName ~= 0
    [FileName,PathName] = uigetfile(FilterSpec,Title, PathName, 'MultiSelect', 'on');
    if ~iscell(FileName)
        if FileName ~= 0
            count = count+1;
            Files{count,1} = FileName;
            Files{count,2} = PathName;
        end
    elseif iscell(FileName)
        for i = 1:numel(FileName)
            if FileName{i} ~= 0
                count = count+1;
                Files{count,1} = FileName{i};
                Files{count,2} = PathName;
            end
        end
        FileName = FileName{end};
    end
    PathName= fullfile(PathName,'..',filesep);%%% go one layer above since .*bur files are nested
end
