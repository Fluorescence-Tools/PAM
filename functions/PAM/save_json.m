%%% Wrapper function to save matlab structure as json file
function success = save_json(filename,obj,name)
json = savejson(name,obj);
fid = fopen(filename,'w');
if fid ~= -1
    fprintf(fid,'%s',json);
    success = true;
else
    success = false;
end

