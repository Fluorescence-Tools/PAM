function [ date ] = get_date_modified(directory,filename)
%%% get modification date of raw data
listing = dir(directory);
table = {};
for ii = 1:size(listing,1)
    table = [table;{listing(ii,1).name},{listing(ii,1).date},{listing(ii,1).bytes}];
end
date= table{strcmp(table(:,1),filename),2};
