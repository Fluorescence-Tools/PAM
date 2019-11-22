function [C, mCountRate, duration] = read_kristine_fcs_file(fname)
% read_zeiss_fcs_file reads FCS data that has been stored in a Kristine
% *.fcs file from the Seidel software package
 if nargin < 1
    return;
 end
if exist(fname,'file')
    % read whole file at once
    C = dlmread(fname);
    duration = C(1,3);
    mCountRate = C(2,3);
    % check if error given
    if size(C,2) == 4 %%% error specified
        C(:,3) = [];
    elseif size(C,2) == 3 %%% no error specified
        C(:,3) = 1;
    end
else
    disp(sprintf('File not found: %s',fname));
end


function merge_kirstine_fcs_file()
%% this function merges kristine fcs files and keeps the error estimates
[fn, pn] = uigetfile('.cor','Select Kirstine *.cor files','MultiSelect','on');
%% load files
for i = 1:numel(fn)
    C{i} = dlmread(fullfile(pn,fn{i}));
    % get time and countrate
    t(i) = C{i}(1,3);
    cr(i) = C{i}(2,3);
end
% calculate the intensity fractions
f = t.*cr./sum(t.*cr);

% get the common time axis
len = cell2mat(cellfun(@(x) size(x,1),C,'UniformOutput',false));
if unique(len) > 1
    % different length of time axis used we have a problem...
end
C_res = zeros(size(C{1}));
C_res(:,1) = C{1}(:,1);

for i = 1:numel(C)
    % calculate weigted-average correlation function
    C_res(:,2) = C_res(:,2) + f(i).*C{i}(:,2);
    % calculate the weighted-average SEM
    % --> weighted average of variance sigma^2
    C_res(:,4) = C_res(:,4) + f(i).*C{i}(:,4).^2;
end
% variance -> std
C_res(:,4) = sqrt(C_res(:,4));

% fill in the metadatas
C_res(1,3) = sum(t);
C_res(2,3) = sum(t.*cr)./sum(t);

% save as new file
[~,file,~] = fileparts(fn{1});
dlmwrite(fullfile(pn,[file '_merged.cor']),C_res);