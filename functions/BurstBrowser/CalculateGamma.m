function CalculateGamma(obj,~)
%%% read out the data from the table and calculate gamma
t = findobj('Tag','CalculateGammaTable');
data = t.Data;
%%% remove NaNs
for i = 1:numel(data)
    if isnan(data{i})
        data{i} = [];
    end
end
try
    data = cell2mat(data);
catch
    m = msgbox('Input data has the wrong format.');
end
if size(data,2) < 4 %%% no error specified
    gamma_from_ES(data(:,1),data(:,2));
else
    gamma_from_ES(data(:,1),data(:,2),data(:,3),data(:,4));
end