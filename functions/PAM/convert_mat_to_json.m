%%% Function to convert mat files to json files for transition to
%%% json-based UserValues structure
function convert_mat_to_json(filenames)
disp('Converting profiles to json files...')
if ~iscell(filenames)
    filenames = {filenames};
end
for i = 1:numel(filenames)
    [path,file,ext] = fileparts(filenames{i});
    S = load(filenames{i},'-mat');
    json = savejson(S);
    fid = fopen([path filesep file '.json'],'w');
    if fid ~= -1
        fprintf(fid,'%s',json);
        success = true;
    else
        success = false;
    end

    if success
        %%% delete mat file
        delete(filenames{i});
    end
    disp(sprintf('%i of %i files',i,numel(filenames)));
end
disp('Done!');