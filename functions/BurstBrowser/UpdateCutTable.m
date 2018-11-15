%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates/Initializes the Cut Table in GUI with stored Cuts  %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateCutTable(h)
global BurstData BurstMeta
file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;

if all(species == [0,0])
    data = {'','','',false,false};
    %rownames = {''};
else
    if ~isempty(BurstData{file}.Cut{species(1),species(2)})
        data = vertcat(BurstData{file}.Cut{species(1),species(2)}{:});
        data(:,1) = cellfun(@(x) ['<html><font size=4><b>' x '</b></font></html>'],data(:,1),'UniformOutput',false);
        %rownames = data(:,1);
        %data = data(:,2:end);
    else %data has been deleted, reset to default values
        data = {'','','',false,false};
        %rownames = {''};
    end
end

if size(data,1) == size(h.CutTable.Data,1)
    h.CutTable.Data(:,1:5) = data;
elseif size(data,1) < size(h.CutTable.Data,1) 
    h.CutTable.Data = [data, h.CutTable.Data(1:size(data,1),6)];
elseif size(data,1) > size(h.CutTable.Data,1)
    h.CutTable.Data = [data, vertcat(h.CutTable.Data(:,6),num2cell(false(size(data,1)-size(h.CutTable.Data,1),1)))];
end
%h.CutTable.RowName = rownames;
