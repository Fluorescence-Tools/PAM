function [cm_data]=bluepurple(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'BuPu');