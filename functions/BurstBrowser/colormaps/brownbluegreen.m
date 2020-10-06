function [cm_data]=brownbluegreen(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'BrBG');