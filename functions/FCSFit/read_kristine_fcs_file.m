function [C, mCountRate, duration] = read_kristine_fcs_file(fname)
% read_zeiss_fcs_file reads FCS data that has been stored in a Kristine
% *.fcs file from the Seidel software package
 if nargin < 1
    return;
end
fileID = fopen(fname);
if fileID == -1
    return;
end   
% read whole file at once
C = textscan(fileID, '%f %f %f %f', 'delimiter','\n');
fclose(fileID);

duration = C{1,3}(1);
mCountRate = C{1,3}(2);
C{3} = [];
C = horzcat(C{:});