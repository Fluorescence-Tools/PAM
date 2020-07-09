function [cm_data]=redyellowblue(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'RdYlBu');