function [cm_data]=oranges(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'Oranges');