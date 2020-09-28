function [cm_data]=purplered(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'RdPu');