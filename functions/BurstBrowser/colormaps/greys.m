function [cm_data]=greys(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'Greys');