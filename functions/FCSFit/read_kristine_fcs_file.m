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