function [cm_data]=bluegreen(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'BuGn');