function [cm_data]=redgray(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'RdGy');