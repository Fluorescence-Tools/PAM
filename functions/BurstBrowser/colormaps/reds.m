function [cm_data]=reds(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'Reds');