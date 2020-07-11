function [cm_data]=greens(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'Greens');