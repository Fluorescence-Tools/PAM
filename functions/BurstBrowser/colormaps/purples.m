function [cm_data]=purples(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'Purples');