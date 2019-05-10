%%% Export the currently selected data to csv file
function write_to_csv(obj,~)
global BurstData
h = guidata(obj);
%%% loop through all files and write DataArray to csv
for b = 1:numel(BurstData)
    Progress((b-1)/numel(BurstData),h.Progress_Axes,h.Progress_Text,['Converting File to CSV (' num2str(b) ' of ' num2str(numel(BurstData)) ')']);
    filename = [BurstData{b}.PathName filesep BurstData{b}.FileName(1:end-3) 'csv'];
    %%% write to csv
    delimiter = ',';
    fid = fopen(filename,'w');
    if fid ~= -1
        fprintf(fid,'%s',BurstData{b}.NameArray{1});
        for i = 2:numel(BurstData{b}.NameArray)
            fprintf(fid,[delimiter '%s'],BurstData{b}.NameArray{i});
        end
        fprintf(fid,'\n');
        fclose(fid);
        dlmwrite(filename,BurstData{b}.DataCut,'Delimiter',delimiter,'-append');
    end
end
Progress(1,h.Progress_Axes,h.Progress_Text);