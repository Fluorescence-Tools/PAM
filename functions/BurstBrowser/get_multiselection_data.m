function [data_concat, data] = get_multiselection_data(h,param)
%%% return concatenated data for parameter over all selected species
%%% if only one argument is supplied, gives out the total data array over
%%% all parameters
global BurstData
[file_n,species_n,subspecies_n] = get_multiselection(h);

if nargin > 1
    par = cell(numel(file_n),1);
    for i = 1:numel(file_n) %%% read out parameter positions for every species
        par{i} = find(strcmp(BurstData{file_n(i)}.NameArray,param));
    end
    valid = ~(cellfun(@isempty,par));
    par = par(valid);
    file_n = file_n(valid); species_n = species_n(valid); subspecies_n = subspecies_n(valid);
end

num_species = numel(file_n);
data = cell(num_species,1);
for i = 1:num_species
    [~,data{i}] = UpdateCuts([species_n(i),subspecies_n(i)],file_n(i));
    if nargin > 1
        data{i} = data{i}(:,par{i});
    end
end
data_concat = vertcat(data{:});