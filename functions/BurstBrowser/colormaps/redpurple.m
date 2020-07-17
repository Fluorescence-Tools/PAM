function [cm_data]=redpurple(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'RdPu');